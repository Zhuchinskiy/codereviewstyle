//
//  MTModifyPricePlanViewController.swift
//  Mitt
//
//  Created by Alexandr Zhuchinskiy on 1/19/15.
//  Copyright (c) 2016. All rights reserved.
//

import UIKit

@objc enum BackwardState: Int {
    case Ssn = 0
    case ManagePlan
}

class MTModifyPricePlanViewController: MTViewController {
    
    enum CellID: String {
        case ChangeDataCell = "ChangeDataCell"
        case HeaderCell  = "HeaderCell"
        case SelectCategoryCell  = "SelectCategoryCell"
        case SelectDataPackageCell  = "SelectDataPackageCell"
    }
    
    fileprivate lazy var headerCell: MTManangePlanValuePerMonthCell? = { [weak self] in
        self?.tableView.register(UINib(nibName: "MTManangePlanValuePerMonthCell", bundle: nil), forCellReuseIdentifier: CellID.HeaderCell.rawValue)
        var cell: MTManangePlanValuePerMonthCell? = self?.tableView.dequeueReusableCell(withIdentifier: CellID.HeaderCell.rawValue) as? MTManangePlanValuePerMonthCell
        cell?.useHeightGap = true
        return cell
    }()
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var footerView: UIView!
    @IBOutlet var button: UIButton! {
        didSet {
            button.setTitle(NSLocalizedString("Edit", comment: ""), for: UIControlState())
        }
    }
    
    @IBOutlet var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    
    fileprivate let overviewService: MTOverviewService = MTOverviewService()
    fileprivate var perMonthCellModel: MTManangePlanValuePerMonthCellModel?
    fileprivate var subscriptionConfigurations: MTPossibleSubscriptionConfigurationsModel?
    fileprivate var subscriptionType: MTPricePlan?
    
    fileprivate var selectedPricePlan: MTPricePlanDataPackage? {
        didSet {
            setupFooterView()
        }
    }
    
    fileprivate var currentPricePlan: MTPricePlanDataPackage?
    
    var downgradeDate: Date?
    var backwardState: BackwardState = .ManagePlan

    fileprivate let numberFormatter = NumberFormatter.mtNumberFormatter(withRoundIncrement: 2)
    
    fileprivate var blocksAfterViewDidAppear: [() -> ()] = []
    fileprivate var viewDidAppearHappened: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFooterView()
        setupHeaderCell()
        
        headerView.backgroundColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        mtStartLoading()
        overviewService.possibleSubscriptionConfigurations { [weak self] (perMonthCellModel, subscriptionConfigurations, downgradeDate, error) in
            if let strongSelf = self {
                strongSelf.mtStopLoading()
                if error == nil {
                    if let navController = strongSelf.navigationController as? MTNavigationController {
                        navController.setDate(Date(), for: strongSelf)
                    }
                    
                    strongSelf.downgradeDate = downgradeDate
                    strongSelf.perMonthCellModel = perMonthCellModel
                    strongSelf.subscriptionConfigurations = subscriptionConfigurations
                    strongSelf.currentPricePlan = subscriptionConfigurations?.currentPricePlan
                    strongSelf.setupHeaderCell()
                    strongSelf.tableView.reloadData()
                    strongSelf.setupTitle()
                } else {
                    strongSelf.addBlockToQueueAfterViewDidAppear {
                        _ = self?.navigationController?.popViewController(animated: true)
                        return
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerCell?.frame = headerView.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for block in blocksAfterViewDidAppear {
            block()
        }
        viewDidAppearHappened = true
    }
    
    /// If viewDidAppear() was already called - block executes immediately. If not - after viewDidAppear()
    fileprivate func addBlockToQueueAfterViewDidAppear(_ block: @escaping () -> ()) {
        if viewDidAppearHappened {
            block()
        } else {
            blocksAfterViewDidAppear.append(block)
        }
    }
    
    // MARK: Updating UI
    
    fileprivate func setupTitle() {
        title = NSLocalizedString("MTModifyPricePlanViewController:ChangeDataPackageTitle", comment: "")
    }
    
    fileprivate func setupHeaderCell() {
        if headerCell?.superview == nil {
            headerView.addSubview(headerCell!)
        }
        
        if let selectedPricePlan = selectedPricePlan {
            perMonthCellModel?.subtitle = selectedPricePlan.titleName;
            perMonthCellModel?.monthlyPrice = NSNumber(value: selectedPricePlan.overallMonthlyFee as Int);
        }
        
        perMonthCellModel?.title = NSLocalizedString("MTModifyPricePlanViewController:PerMonthHeaderTitle", comment: "")
        
        perMonthCellModel?.setupCell(headerCell)
        headerViewHeightConstraint.constant = perMonthCellModel?.cellHeightInTableView(tableView, cellIdentifier: CellID.HeaderCell.rawValue, useHeightGap: true) ?? 0
    }
    
    fileprivate func addBounceAnimationToLabel(_ label: UILabel?) {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "position.y")
        let currentPosition = label?.layer.position.y ?? 0.0
        bounceAnimation.values = [currentPosition, currentPosition - 3, currentPosition + 3, currentPosition - 3, currentPosition]
        bounceAnimation.keyTimes = [0, NSNumber(value: 1.0 / 6.0),  NSNumber(value: 3.0 / 6.0),  NSNumber(value: 5.0 / 6.0), 1]
        bounceAnimation.duration = 0.2
        label?.layer.add(bounceAnimation, forKey: "bounceAnimation")
    }
    
    fileprivate func headerTextForSection(_ section: Int) -> String? {
        return NSLocalizedString("MTModifyPricePlanViewController:BlackLabelTitle:SelectNewDataPackage", comment: "")
    }
    
    fileprivate func setupFooterView() {
        tableView.tableFooterView = footerView
        footerView.mtUpdateConstrainedViewSize()
        
        button.isEnabled = selectedPricePlan == nil ? false : true
    }
    
    @IBAction func changeSubscriptionAction(_ sender: UIButton!) {
        if bumpOfflineViewIfNoInternetConnection() == false { return }
        
        guard let selectedPricePlan = selectedPricePlan else { return }
        
        if selectedPricePlan.isPurchasble {
            presentConfirmAlert()
        } else {
            presentDowngradeAlert()
        }
    }
    
    // MARK: - Alerts presentation
    
    fileprivate func presentConfirmAlert() {
        let formatter = NumberFormatter.mtNumberFormatter(withRoundIncrement: 2)
        guard let selectedPricePlan = selectedPricePlan,
            let selectedPricePlanVolumeValue = selectedPricePlan.volume?.value,
            let selectedPricePlanVolumeValueString = formatter?.string(from: NSNumber(value: selectedPricePlanVolumeValue as Double)),
            let selectedPricePlanVolumeUnitType = selectedPricePlan.volume?.unitType else { return }
        
        let titleText = NSLocalizedString("MTManagePlanViewController:ChangeSubscriptionTextForFOXUsers", comment: "")
        let pricePlanNameText = selectedPricePlanVolumeValueString + " " + selectedPricePlanVolumeUnitType
        
        let overallMonthlyFee = selectedPricePlan.additionalMonthlyFee
        let overallMonthlyFeeText = NSString(format: NSLocalizedString("%.f kr", comment: "") as NSString, CGFloat(overallMonthlyFee))
        
        let confirmationAlertDescriptionText = NSLocalizedString("MTManagePlanViewController:ConfirmationAlert:Description", comment: "")
        let descriptionText = NSString(format: confirmationAlertDescriptionText as NSString, pricePlanNameText, overallMonthlyFeeText) as String
        
        let confirmationAlert = UIAlertController(title: titleText, message: descriptionText, preferredStyle: .alert)
        
        let changeAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: { [weak self] (UIAlertAction) in
            self?.changeSubscription()
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (UIAlertAction) in
            confirmationAlert.dismiss(animated: true, completion: nil)
        })
        
        confirmationAlert.addAction(changeAction)
        confirmationAlert.addAction(cancelAction)
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    fileprivate func presentDowngradeAlert() {
        let titleText = NSLocalizedString("MTManagePlanViewController:UnavaialableDowngradeAlert:Title", comment: "")
        let descriptionCopyText = NSLocalizedString("MTManagePlanViewController:UnavaialableDowngradeAlert:DescriptionText", comment: "")
        let dateText = (downgradeDate as NSDate?)?.mtDefaultDateString() ?? ""
        let descriptionText = NSString(format: descriptionCopyText as NSString, dateText) as String
        
        let downgradeAlertController = UIAlertController(title: titleText, message: descriptionText, preferredStyle: .alert)
        
        let dissmisAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (alert: UIAlertAction!) -> Void in
            downgradeAlertController.dismiss(animated: true, completion: nil)
        }
        
        downgradeAlertController.addAction(dissmisAction)
        present(downgradeAlertController, animated: true, completion: nil)
    }
    
    // MARK: Helpers
    
    fileprivate func changeSubscription() {
        guard let selectedProductId = selectedPricePlan?.productId else { return }
        
        mtStartLoading()
        button.isEnabled = false
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItems = nil
        
        let beginDateForVCLoading = Date()
        
        overviewService.changeSubscription(withPricePlanId: selectedProductId) {[weak self] (error) in
            if let strongSelf = self {
                strongSelf.mtStopLoading()
                
                MTGAIService.sharedInstance().reportOnLoadTime(for: strongSelf, begin: beginDateForVCLoading, end: Date(), error: error)
                
                if error == nil {
                    strongSelf.performSegue(withIdentifier: "MTModifyPricePlanToConfirmSegueID", sender: nil)
                }
                
                strongSelf.button.isEnabled = true
            }
        }
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let confirmViewController = segue.destination as? MTModifyPricePlanConfirmViewController {
            confirmViewController.confirmationType = .changeDataPackage
        }
    }
    
    // MARK: TableViewCells appearance
    
    /// Setup cell. If value or valueType equals nil -> only string will be used for subtitle label.
    fileprivate func setupSubtitleCell(_ cell: MTTableViewSubtitleCell, value: Float?, valueType: String?, string: String) {
        if let subtitleValue = value {
            if let subtitleValueType = valueType {
                let numberFormatter = NumberFormatter.mtNumberFormatter(withRoundIncrement: 2)
                let valueString = (numberFormatter?.string(from: NSNumber(value: subtitleValue as Float)) ?? "") + " "
                let descriptionString = subtitleValueType + ". " + string
                let completeString = valueString + descriptionString
                
                let firstRange = (completeString as NSString).range(of: valueString)
                let secondRange = (completeString as NSString).range(of: descriptionString)
                
                let completeMutableString = NSMutableAttributedString(string: completeString)
                completeMutableString.setAttributes([NSFontAttributeName: UIFont.mtMediumFont(withSize: 14.0)], range: firstRange)
                completeMutableString.setAttributes([NSFontAttributeName: UIFont.mtRegularFont(withSize: 14.0)], range: secondRange)
                
                cell.subtitleLabel?.attributedText = completeMutableString
                
                return
            }
        }
        
        cell.subtitleLabel?.font = UIFont.mtRegularFont(withSize: 14.0)
        cell.subtitleLabel?.text = string
    }
    
    fileprivate func setupSelectDataPackageCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MTModifyPricePlanCell.cellID, for: indexPath) as! MTModifyPricePlanCell
        
        if let dataPackage = subscriptionConfigurations?.pricePlans[indexPath.row] {
            if let selectedPricePlan = selectedPricePlan {
                cell.selectedPricePlanImage = selectedPricePlan.isEqual(to: dataPackage) ? UIImage(named: "selected") : nil
            } else {
                cell.selectedPricePlanImage = nil
            }
            
            let isCurrentPricePlan = dataPackage.productId == currentPricePlan?.productId
            let currentPricePlanText = NSLocalizedString("MTModifyPricePlanViewController:ActiveDataPackage", comment: "")
            
            let grayColor = UIColor.mtColor(with: .darkGray)
            
            cell.pricePlanNameLabel?.textColor = isCurrentPricePlan ? grayColor : UIColor.black
            cell.pricePlanValueLabel?.textColor = isCurrentPricePlan ? grayColor : UIColor.black
            cell.currentPricePlanLabel?.textColor = isCurrentPricePlan ? grayColor : UIColor.black
            cell.currentPricePlanLabel?.text = isCurrentPricePlan ? currentPricePlanText : nil
            
            cell.pricePlanNameLabel.text = isCurrentPricePlan ? currentPricePlan?.titleName : dataPackage.pricePlanName
            cell.pricePlanValueLabel.text = "\(isCurrentPricePlan ? currentPricePlan?.overallMonthlyFee ?? 0 : dataPackage.additionalMonthlyFee) " + NSLocalizedString("kr/month", comment: "")
            
            cell.selectionStyle = .default
        }
        
        return cell
    }
}

extension MTModifyPricePlanViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriptionConfigurations?.pricePlans.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = MTBlackLabel()
        label.text = headerTextForSection(section)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let label = MTBlackLabel()
        label.text = headerTextForSection(section)
        let size = label.sizeThatFits(CGSize(width: tableView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        return size.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return setupSelectDataPackageCell(tableView: tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let pricePlan = subscriptionConfigurations?.pricePlans[indexPath.row]
        let isCurrentPricePlan = pricePlan?.productId == currentPricePlan?.productId
        return isCurrentPricePlan ? false : true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = indexPath.row
        
        guard let count = subscriptionConfigurations?.pricePlans?.count,
            row < count,
            let dataPackage = subscriptionConfigurations?.pricePlans?[row] else { return }
        
        if dataPackage.productId != currentPricePlan?.productId {
            selectedPricePlan = dataPackage
            //addBounceAnimationToLabel(headerCell?.subtitleLabel)
            //addBounceAnimationToLabel(headerCell?.descriptionLabel)
            //setupHeaderCell()
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
}
