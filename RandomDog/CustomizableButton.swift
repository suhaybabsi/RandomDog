//
//  CustomizableButton.swift
//  RandomDog
//
//  Created by Suhayb Al-Absi on 8/29/18.
//  Copyright © 2018 Suhayb Al-Absi. All rights reserved.
//

import UIKit


@IBDesignable class CustomizableButton: UIButton {
    
    @IBInspectable var borderColor:UIColor? = nil{
        
        didSet {
            self.layer.borderColor = self.borderColor?.cgColor
        }
    }
    
    @IBInspectable var borderWidth:CGFloat = 0.0 {
        
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
    }
    
    
    @IBInspectable var cornerRadius:CGFloat = 0.0 {
        
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
}
