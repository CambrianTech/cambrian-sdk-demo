//
//  BrandMaterial.swift
//
//
//  Created by Joel Teply on 6/7/16.
//
//

import Foundation
import RealmSwift

class BrandItem : Object {
    
    override static func ignoredProperties() -> [String] {
        return ["storeURL", "_view", "view", "color", "text"]
    }
    
    dynamic var itemID: String = ""
    override class func primaryKey() -> String? { return "itemID"}
    
    convenience init(key: String) {
        self.init()
        self.itemID = key
    }
    
    dynamic var parentCategory: BrandCategory? = nil
    dynamic var name = ""
    dynamic var itemCode = ""
    dynamic var orderIndex = 0
    dynamic var storeID = ""
    
    //material, model specific
    dynamic var assetPath = ""
    dynamic var scale: Float = 1.0
    dynamic var reflectivity: Float = 5.0
    
    //paint specific
    dynamic var red = 0
    dynamic var green = 0
    dynamic var blue = 0
    
    dynamic var hue = 0
    dynamic var saturation = 0
    dynamic var brightness = 0
    dynamic var info: String?
    
    dynamic var opacity = 255
    
    @objc enum BrandItemType: Int {
        case Paint
        case Texture
        case Model
    }
    
    dynamic var itemType = BrandItemType.Paint
}
