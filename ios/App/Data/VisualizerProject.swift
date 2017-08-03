
//
//  VisualizerProject.swift
//
//  Created by Joel Teply on 6/7/16.
//  Copyright © 2016 Cambrian. All rights reserved.
//

import Foundation
import RealmSwift

internal protocol ProjectImageDelegate : NSObjectProtocol {
    func projectImageSelected(_ sender: AnyObject, image:VisualizerImage)
    func projectImageRemoved(_ sender: AnyObject)
    func projectImageShared(_ sender: AnyObject, image:VisualizerImage)
}

internal protocol ProjectImageCellDelegate : NSObjectProtocol {
    func projectImageSelected(_ sender: AnyObject, image:VisualizerImage)
    func projectImageDeleted(_ sender: AnyObject, image:VisualizerImage)
}

class VisualizerProject : Object  {
    
    dynamic var projectID = UUID().uuidString
    override class func primaryKey() -> String? { return "projectID"}
    
    dynamic var created = Date()
    dynamic var modified = Date()
    
    dynamic var name = "My Project"
    
    var _currentImageIndex = -1
    
    dynamic var currentImageIndex: Int {
        get {
            if (_currentImageIndex < 0) {
                var index = 0
                let mostRecent = self.mostRecentImage
                for image in self.images {
                    if image == mostRecent {
                        _currentImageIndex = index
                        break;
                    }
                    index += 1
                }
            }
            return _currentImageIndex
        }
        set {
            _currentImageIndex = newValue
        }
    }
    
    

    
    dynamic var mostRecentImage: VisualizerImage? {
        if self.images.count > 0 {
            for image in sortedImages {
                if image.thumbnail != nil {
                    return image
                }
            }
        }
        return nil
    }
    
    /*
    dynamic var previewImage: UIImage? {
        if let image = mostRecentImage {
            return image.previewImage
        }
        return nil
    }
    
    dynamic var thumbnailImage: UIImage? {
        if let image = mostRecentImage {
            return image.thumbnail
        }
        return nil
    }
 */
    
    dynamic var isEmpty: Bool {
        get {
            return self.images.count == 0
        }
    }
    
    fileprivate static var _currentProject : VisualizerProject?
    static var currentProject:VisualizerProject {
        get {
            
            guard let project = _currentProject
                else {
                    let results = latestProjects()
                    if results.count > 0 {
                        _currentProject = results[0]
                    } else {
                        _currentProject = createProject()
                    }
                    print("Using projectID:\(_currentProject!.projectID)")
                    return _currentProject!
            }
            
            return project
        }
        set {
            _currentProject = newValue
        }
    }
    
    static func createProject(name: String) -> VisualizerProject {
        let project = createProject()
        try! project.realm?.write {
            project.name = name
        }
        
        return project
    }
    
    static func createProject(_ block:((Void)->(Bool))? = nil) -> VisualizerProject {
        
        guard let context = DataController.sharedInstance.projectContext
            else {
                fatalError()
        }
        
        var newProject:VisualizerProject?
        //always just return the blank one
        if let currentProject = _currentProject {
            if (currentProject.isEmpty) {
                newProject = currentProject
            }
        }
        
        if (newProject == nil) {
            newProject = VisualizerProject()
        }
        
        try! context.write {
            context.add(newProject!)
        }
        
        return newProject!
    }
    
    static func latestProjects() -> Results<VisualizerProject>  {
        guard let context = DataController.sharedInstance.projectContext
            else {
                fatalError()
        }
        
        let searchResults = context.objects(VisualizerProject.self).sorted(byKeyPath: "modified", ascending: false)
        
        return searchResults
    }
    
    dynamic var currentImage:VisualizerImage? {
        get {
            if currentImageIndex < 0 || currentImageIndex >= self.images.count {
                return nil
            }
            return self.images[currentImageIndex]
        }
        set {
            if let image = newValue, let index = self.images.index(of: image) {
                currentImageIndex = index
            }
        }
    }
    
    func appendScene(_ scene:CBRemodelingScene) {
        appendImage(scene.sceneID)
    }

    func appendImage(_ id:String) {
        
        guard
            //let project = self.project, let index = project.images.indexOf(self), let context = realm
            let context = realm
            else { fatalError() }
        
        
        try! context.write {
            var image = context.object(ofType: VisualizerImage.self, forPrimaryKey: id)
            if image == nil {
                image = VisualizerImage()
                image?.imageID = id
                context.add(image!, update: true)
                VisualizerProject.currentProject.images.append(image!)
                image?.project = VisualizerProject.currentProject
            }
            
            VisualizerProject.currentProject.currentImage = image!
        }
    }
    
    func appendImage(image: VisualizerImage) {
        guard
            let context = DataController.sharedInstance.projectContext
            else { fatalError() }
        
        let project = VisualizerProject.currentProject
        try! context.write {
            context.add(image, update: true)
            
            if !project.images.contains(image) {
                project.images.append(image)
                image.project = VisualizerProject.currentProject
            }
            
            project.currentImage = image
        }
    }
    
    dynamic var directoryPath:URL {
        get {
            return DataController.getWriteDirectory().appendingPathComponent("projects").appendingPathComponent(projectID)
        }
    }
  
    func renameAlert(_ viewController:UIViewController, handler: ((Bool) -> Void)? = nil) {
        let chooseNameAlert = UIAlertController(title: "Project Name", message: "Enter a name for this project", preferredStyle: UIAlertControllerStyle.alert)
        chooseNameAlert.addAction(UIAlertAction(title: "Save", style: .default, handler:  {
            (alert: UIAlertAction!) -> Void in
            var name = chooseNameAlert.textFields![0].text!
            if (name.characters.count == 0) {
                name = "New Project"
            }
            
            //ProjectDatabase.sharedDatabase().saveProject(self.augmentedView, name:name!)
            
            try! self.realm?.write({
                self.name = name
            })
            
            if let handler = handler {
                handler(true)
            }
        }))
        chooseNameAlert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter Project Name:"
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            textField.text = self.name
        })
        
        chooseNameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:  {
            (alert: UIAlertAction!) -> Void in
            
            if let handler = handler {
                handler(false)
            }
        }))
        
        viewController.present(chooseNameAlert, animated: true, completion: nil)
    }
    
    func shareAction(_ viewController:UIViewController, button: UIBarButtonItem, handler: ((Bool) -> Void)? = nil) {
        
        if let image = self.currentImage {
            shareProjectImage(viewController, button: button, image: image) {
                if let handler = handler {
                    handler(true)
                }
            }
        } else {
            if let handler = handler {
                handler(false)
            }
        }
    }
    
    
    func deleteProject(_ completion: ((Void) -> Void)? = nil) {
        if (self.projectID == VisualizerProject.currentProject.projectID) {
            try! realm?.write ({
                VisualizerProject._currentProject = nil
                realm?.delete(self)
            
                if let block = completion {
                    block()
                }
            })
        }
    }
    
    //Relationships
    let images = List<VisualizerImage>()
    
    var sortedImages: Results<VisualizerImage> {
        get {
            return images.sorted(byKeyPath: "modified", ascending: false)
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["metaDataIDField", "currentImage", "currentImageIndex", "_currentImageIndex", "directoryPath", "previewImage"]
    }
}

