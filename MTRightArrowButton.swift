//
//  MTRightArrowButton.swift
//  Mitt
//
//  Created by Alexandr Zhuchinskiy on 6/21/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

@IBDesignable class MTRightArrowButton: MTIncreaseTouchAreaButton {
    
    fileprivate let labelRightOffset: CGFloat = 2

    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    fileprivate func customInit() {
        deltaTouchSize = CGSize(width: 500.0, height: 500.0)
        
        titleLabel?.numberOfLines = 1
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.lineBreakMode = .byClipping
                
        titleLabel?.textColor = UIColor.mtColor(with: .black)
        titleLabel?.font = UIFont.mtRegularFont(withSize: 13)
        
        setTitleColor(UIColor.black, for: UIControlState())
        setTitleColor(UIColor.mtColor(with: .lightGraySelected), for: .highlighted)
        
        setupImage()
    }
    
    fileprivate func setupImage() {
        var image: UIImage? = nil
        var selectedImage: UIImage? = nil
        
        #if TARGET_INTERFACE_BUILDER
            if #available(iOS 8.0, *) {
                image = UIImage(named: "disclosure_small",
                                inBundle: NSBundle(forClass: MTRightArrowButton.classForCoder()), compatibleWithTraitCollection: nil)
                
                selectedImage = UIImage(named: "disclosure_small_highlighted",
                                        inBundle: NSBundle(forClass: MTRightArrowButton.classForCoder()), compatibleWithTraitCollection: nil)
            }
        #else
            image = UIImage(named: "disclosure_small")
            selectedImage = UIImage(named: "disclosure_small_highlighted")
        #endif
        
        setImage(image, for: UIControlState())
        setImage(selectedImage, for: .highlighted)
        
        imageView?.contentMode = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = imageView {
            let imageViewWitdh = imageView.frame.width
            let imageViewHeight = imageView.frame.height
            
            var labelFrame = frame
            labelFrame.size.width = frame.width - imageViewWitdh - labelRightOffset
            labelFrame.origin = CGPoint(x: 0, y: 0)
            titleLabel?.frame = labelFrame
            
            imageView.frame = CGRect(x: frame.size.width - imageViewWitdh, y: imageView.frame.origin.y, width: imageViewWitdh, height: imageViewHeight)
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + labelRightOffset, height: size.height)
    }
    
    override func prepareForInterfaceBuilder() {
        customInit()
    }
    
}

