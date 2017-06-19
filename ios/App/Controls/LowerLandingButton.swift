//
//  LowerLandingButton.swift
//
//  Created by Jaremy Longley on 4/21/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation

class LowerLandingButton: UIButton {
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageView = self.imageView, let titleLabel = self.titleLabel {
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: self.frame.width,
                                     height: self.frame.height * 0.6)
            
            titleLabel.frame = CGRect(x: 0,
                                      y: self.frame.height * 0.5,
                                      width: self.frame.width,
                                      height: self.frame.height * 0.4)

            titleLabel.textAlignment = NSTextAlignment.center
            self.clipsToBounds = true
        }
    }
    
}
