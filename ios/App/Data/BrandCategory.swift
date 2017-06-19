//
//  BrandCategory.swift
//
//
//  Created by Joel Teply on 6/7/16.
//
//

import Foundation
import RealmSwift

class BrandCategory : Object {
    
    override static func ignoredProperties() -> [String] {
        return ["paint", "childPaints", "_cachedChildPaints", "defaultCategory", "view", "_view"]
    }
    
    dynamic var categoryID = UUID().uuidString
    dynamic var parentCategory: BrandCategory? = nil
    
    override class func primaryKey() -> String? { return "categoryID"}
    
    //drawable
    dynamic var assetPath = ""
    dynamic var isIndoor = true
    dynamic var isOutdoor = false
    dynamic var name = ""
    dynamic var orderIndex = 0
    dynamic var selectedItem: BrandItem? = nil
    
    let items = List<BrandItem>()
    let subCategories = List<BrandCategory>()
}
