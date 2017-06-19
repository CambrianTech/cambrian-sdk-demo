//
//  LayersViewController.swift
//
//  Created by joseph on 4/17/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation
import RealmSwift
import Kingfisher


internal protocol AssetDelegate: NSObjectProtocol {
    func appendPaint(_ paint:CBRemodelingPaint)
    func appendFloor(_ floor:CBRemodelingFloor)
    func assetSelected(_ asset:Asset)
    func removeAsset(_ asset:Asset)
    func assetUpdated(_ asset: Asset)
}


class AssetsViewController: UIViewController {
    
    @IBOutlet weak var addButton: RoundButton!
    
    weak internal var delegate: AssetDelegate?
    
    var image: VisualizerImage!
    var assets = List<Asset>()
    var layerViews = [RoundImageBordered]()
    var selectedIndex: Int = 0
    var isSample:Bool = false
    
    var maxAssets = 4
    
    var size = 55

    func setup(image: VisualizerImage) {
        self.image = image
        self.assets = image.assets
        
        //add a random color as initial asset if there are none on the image
        if assets.isEmpty {
            self.append(BrandItem.randomPaint()!)
        }
        initViews()
    }
    
    func initViews() {
        for i in 0..<4 {
            addLayerView(index: i)
        }
        
        if(assets.count > 0) {
            self.selectedIndex = assets.count-1
        } else { self.selectedIndex = 0 }
        
        assetSelected(index: selectedIndex)
        
        refresh()
    }
    
    func refresh() {
        addButton.isHidden = false
        for i in layerViews.indices {
            let layer = layerViews[i]
            if(i < assets.count) {
                layer.isHidden = false
                if let item = assets[i].getItem() {
                    layer.setColor(item.color)
                }
            } else {
                layer.isHidden = true
            }
            layer.isSelected = (i == selectedIndex)
        }
        if(assets.count >= layerViews.count || isSample) {
            addButton.isHidden = true
        }
        let pos = (assets.count * size) + 10
        addButton.frame.origin.y = CGFloat(pos)
    }
    

    func addLayerView(index: Int) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.assetPressed(_:)))
        let long = UILongPressGestureRecognizer(target: self, action: #selector(self.assetLongPressed(_:)))
        let layerView = RoundImageBordered(frame: CGRect(x:0, y: size*index, width: size, height: size))
        layerView.setColor(UIColor.gray)
        layerView.tag = index
        layerView.addGestureRecognizer(tap)
        layerView.addGestureRecognizer(long)
        self.view.addSubview(layerView)
        layerViews.append(layerView)
    }
    
    
    @IBAction func addPressed(_ sender: Any) {
        if let item = assets.last?.getItem() {
            append(item)
        }
    }
    
    func canAppend(_ newItem: BrandItem? = nil) -> Bool {
        if (assets.count >= maxAssets) {
            return false
        }
        
        return true
    }
    
    func append(_ newItem: BrandItem) {
        
        //asset for realm
        let asset = Asset(UUID().uuidString)
        asset.itemID = newItem.itemID
        if let realm = image.realm {
            try! realm.write {
                assets.append(asset)
            }
        } else {
            assets.append(asset)
        }
        
        selectedIndex = assets.count - 1
        refresh()
        
        
        if(newItem.itemType == .Paint) {
            let paint = CBRemodelingPaint(assetID: asset.assetID)
            paint.color = newItem.color
            self.delegate?.appendPaint(paint)
        }
        self.delegate?.assetSelected(asset)
        self.delegate?.assetUpdated(asset)
    }
    
    func selectedItem(_ item: BrandItem) {
        
        if (canAppend(item)) {
            append(item)
        } else {
            setAssetItem(item)
        }
    }

    func setAssetItem(_ item: BrandItem) {
        if(selectedIndex < assets.count && selectedIndex >= 0) {
            if let realm = image.realm {
                try! realm.write {
                    assets[selectedIndex].itemID = item.itemID
                }
            } else {
                assets[selectedIndex].itemID = item.itemID
            }
            refresh()
        }
        
        self.delegate?.assetUpdated(assets[selectedIndex])
    }
    
    func removeLayer(index: Int) {
        if assets.count > index {
            // remove from visualizer
            self.delegate?.removeAsset(assets[index])
            
            //remove from realm or memory
            if let realm = image.realm {
                try! realm.write {
                    assets.remove(at: index)
                }
            } else {
                assets.remove(at: index)
            }
            
            //select new item after deletion
            selectedIndex = 0
            assetSelected(index: 0)
        }
        refresh()
    }
    
    func undo(_ assetID: String, userData: [String: String]) {
        if let containedID = userData["ID"],
            let asset = image.assets.filter({ $0.assetID == assetID}).first,
            let item = BrandItem.itemForID(containedID) {
            
            if let realm = image.realm {
                try! realm.write {
                    asset.itemID = item.itemID
                }
            } else {
                asset.itemID = item.itemID
            }
            
            if let index = assets.index(of: asset) {
                assetSelected(index: index)
            }
            refresh()
        }
    }
    
    
    func assetSelected(index: Int) {
        if assets.count > index {
            selectedIndex = index
            self.delegate?.assetSelected(assets[index])
            refresh()
        }

    }
    
    func assetPressed(_ sender: UITapGestureRecognizer) {
        let index = sender.view!.tag
        assetSelected(index: index)
    }
    
    func assetLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began { return }
        let index = sender.view!.tag
        
        let alert = UIAlertController(title: "", message: "Delete this color?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
            self.removeLayer(index: index)
            if self.assets.count == 0 {
                self.append(BrandItem.randomPaint()!)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
