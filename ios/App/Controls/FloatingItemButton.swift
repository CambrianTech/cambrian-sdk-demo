//
//  FloatingItemButton.swift
//
//  Created by joseph on 5/1/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation
import Kingfisher

class FloatingItemButton: UIButton {
    
    
    var item: BrandItem? {
        didSet {
            if let item = item {
                update(item)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
        self.isUserInteractionEnabled = true
    }
    
    func update(_ item: BrandItem) {
        self.setColor(item.color)
        self.enableLogo(true)
        self.isHidden = false
    }
    
    func setColor(_ color: UIColor) {
        self.layer.contents = nil
        self.layer.backgroundColor = color.cgColor
    }
    
    func enableLogo(_ enable: Bool) {
        if(enable) {
            self.setImage(UIImage(named: "ic_cart"), for: .normal)
        } else {
            self.setImage(nil, for: .normal)
        }
    }
}
