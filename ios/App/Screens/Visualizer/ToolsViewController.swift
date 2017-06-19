//
//  ToolsViewController.swift
//
//  Created by joseph on 3/30/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation
import RealmSwift

internal protocol ToolDelegate : NSObjectProtocol {
    func setToolMode(_ mode: CBToolMode)
    func setLightingMode(_ light: CBLightingType)
    func lightingStart() -> CBLightingType
    func toolsFinish()
}


class ToolsViewController: UIViewController, OptionsDelegate {
    
    weak internal var delegate: ToolDelegate?
    
    @IBOutlet weak var listContainer: UIView!
    @IBOutlet weak var listBottomToBottom: NSLayoutConstraint!
    
    @IBOutlet weak var toolsContainer: UIView!
    @IBOutlet weak var paintContainer: UIView!
    
    @IBOutlet weak var lightingButton: RoundButton!
    @IBOutlet weak var eraserButton: UIButton!
    @IBOutlet weak var brushButton: UIButton!
    
    var currentLighting: CBLightingType = .none
    
    var isActive: Bool = false
    var toolMode: CBToolMode = CBToolMode.fill
    var isLiveMode: Bool = false {
        didSet {
            self.paintContainer.isHidden = isLiveMode
        }
    }
    var pos = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listContainer.isHidden = true
        showOptionsList(false, duration: 0)
        self.setToolColors(nil)
        
        self.paintContainer.layer.cornerRadius = self.paintContainer.frame.width / 2
    }
    
    override func viewDidLayoutSubviews() {
        self.toolsContainer.frame.origin = pos
    }
    
    
    @IBAction func lightingPressed(_ sender: Any) {
        if let delegate = delegate {
            currentLighting = delegate.lightingStart()
            self.showTools(false)
            self.showOptionsList(true)
            self.isActive = true
        }
    }
    
    @IBAction func brushPressed(_ sender: Any) {
        if toolMode == .paintbrush {
            toolMode = .fill
            self.delegate?.setToolMode(toolMode)
            setToolColors(nil)
        } else {
            toolMode = .paintbrush
            self.delegate?.setToolMode(toolMode)
            setToolColors(self.brushButton.imageView)
        }
    }
    
    @IBAction func eraserPressed(_ sender: Any) {
        if toolMode == .eraser {
            toolMode = .fill
            self.delegate?.setToolMode(toolMode)
            setToolColors(nil)
        } else {
            toolMode = .eraser
            self.delegate?.setToolMode(toolMode)
            setToolColors(self.eraserButton.imageView)
        }
    }
    
    func toolsFinish() {
        self.delegate?.toolsFinish()
        showTools(false)
    }
    
    func showTools(_ show: Bool, duration: TimeInterval = 0.2) {
        self.toolsContainer.isHidden = false
        UIView.animate(withDuration: duration, animations: {
            if(show) {
                self.toolsContainer.alpha = 1
            } else {
                self.toolsContainer.alpha = 0
            }
        }, completion: { finished in
            self.toolsContainer.isHidden = !show
        })
    }
    
    func setToolColors(_ view: UIImageView?) {
        let color = UIColor.lightGray
        
        if view == self.brushButton.imageView {
            self.brushButton.setImage(UIImage(named: "ic_close"), for: .normal)
            self.brushButton.imageView?.tintColor = .white
            self.eraserButton.imageView?.tintColor = color
            self.eraserButton.setImage(UIImage(named: "ic_eraser"), for: .normal)
        } else if view == self.eraserButton.imageView {
            self.eraserButton.setImage(UIImage(named: "ic_close"), for: .normal)
            self.eraserButton.imageView?.tintColor = .white
            self.brushButton.imageView?.tintColor = color
            self.brushButton.setImage(UIImage(named: "ic_paintbrush"), for: .normal)
        } else {
            self.eraserButton.setImage(UIImage(named: "ic_eraser"), for: .normal)
            self.brushButton.setImage(UIImage(named: "ic_paintbrush"), for: .normal)
            self.brushButton.imageView?.tintColor = color
            self.eraserButton.imageView?.tintColor = color
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OptionsCollectionView {
            vc.delegate = self
            vc.startType = currentLighting
            vc.options = loadLighting()
        }
    }
    
    internal func pickedLighting(type: CBLightingType) {
        self.currentLighting = type
        self.delegate?.setLightingMode(type)
    }
    
    func finish() {
        showOptionsList(false)
        self.isActive = false
        
        self.delegate?.toolsFinish()
    }
    
    func showOptionsList(_ show: Bool, duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, animations: {
            if(show) {
                self.listContainer.isHidden = false
                self.listBottomToBottom.constant = 0
            } else {
                self.listContainer.isHidden = true
                self.listBottomToBottom.constant = -self.listContainer.frame.height
            }
        })
    }
    
    private func loadLighting() -> [Option]{
        var options = [Option]()
        var names: [String] = ["None", "Incandescent", "Fluorescent", "LED_White", "LED_Warm", "Morning_Light", "Noon_Light", "Evening_Light", "Overcast_Light"]
        
        for i in 0..<8 {
            let type = CBLightingType(rawValue: i)
            let option = Option(type: type!,
                name: names[i],
                image: UIImage(named: names[i]))
            option.isSelected = (type == currentLighting)
            options.append(option)
        }
        
        return options
    }
}


internal protocol OptionsDelegate : NSObjectProtocol {
    func pickedLighting(type: CBLightingType)
}

class Option {
    var type: CBLightingType
    var name: String
    var image: UIImage?
    var cell: OptionCell?
    
    var isSelected: Bool = false {
        didSet {
            if (isSelected) {
                self.cell?.imageView.tintColor = UIColor.white
                self.cell?.textView.textColor = UIColor.white
            } else {
                self.cell?.imageView.tintColor = UIColor.gray
                self.cell?.textView.textColor = UIColor.gray
            }
        }
    }
    
    init(type: CBLightingType, name: String, image: UIImage?) {
        self.type = type
        self.name = name
        self.image = image
    }
}


class OptionsCollectionView: UICollectionViewController {
    
    var delegate: OptionsDelegate?
    var options: [Option]!
    
    var startType: CBLightingType?
    
    var selectedCell:OptionCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.isScrollEnabled = true
        self.collectionView?.isUserInteractionEnabled = true
        
        self.collectionView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70)
    }
    
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !options.isEmpty {
            print("lighting option count \(options.count)")
            return options.count
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! OptionCell
        let index = (indexPath as NSIndexPath).row
        
        
        cell.imageView.image = options[index].image
        cell.textView.text = options[index].name
        cell.textView.adjustsFontSizeToFitWidth = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(optionPressed(_:)))
        
        cell.container.tag = (indexPath as NSIndexPath).row
        cell.container.isUserInteractionEnabled = true
        cell.container.addGestureRecognizer(gesture)
        options[index].cell = cell
        options[index].isSelected = (startType == options[index].type)
        return cell
    }
    
    func optionPressed(_ sender: UITapGestureRecognizer) {
        let index = sender.view!.tag
    
        selectItem(index)
    }
    
    func selectItem(_ index: Int) {
        print("pressed at index \(index)")
        for option in self.options {
            option.isSelected = false
        }
        
        let option = self.options[index]
        option.isSelected = true
        self.delegate?.pickedLighting(type: option.type)
    }
    
    
}
class OptionCell: UICollectionViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UILabel!
}


