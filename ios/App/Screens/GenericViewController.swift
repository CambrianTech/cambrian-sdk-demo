//
//  GenericViewController.swift
//  HarmonyApp
//
//  Created by joseph on 6/1/17.
//  Copyright © 2017 Cambrian. All rights reserved.
//

import Foundation

class GenericViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.stopUsingTransparentNavigationBar()
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.barTintColor = appColor
        self.navigationController?.navigationBar.backgroundColor = appColor
    }
}
