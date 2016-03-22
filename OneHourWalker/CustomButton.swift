//
//  CustomButton.swift
//  OneHourWalker
//
//  Created by Matthew Maher on 2/18/16.
//  Copyright © 2016 Matt Maher. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    override func awakeFromNib() {
        layer.cornerRadius = 23.0
        layer.borderColor = UIColor(red: 255/255, green: 128/255, blue:0/255, alpha: 1.0).CGColor
        layer.borderWidth = 3.0
    }
}
