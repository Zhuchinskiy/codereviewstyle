//
//  MTIncreaseTouchAreaButton.swift
//  Mitt
//
//  Created by Alexandr Zhuchinskiy on 8/8/16.
//  Copyright © 2016 Tele2. All rights reserved.
//

import UIKit

class MTIncreaseTouchAreaButton: UIButton {
    
    var deltaTouchSize: CGSize = CGSize(width: 10.0, height: 10.0)
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newBound = CGRect(x: bounds.origin.x - deltaTouchSize.width/2.0,
                              y: bounds.origin.y - deltaTouchSize.height/2.0,
                              width: bounds.width + deltaTouchSize.width,
                              height: bounds.height + deltaTouchSize.height
        )
        return newBound.contains(point)
    }
}
