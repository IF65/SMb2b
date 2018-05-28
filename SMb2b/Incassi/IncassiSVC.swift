//
//  IncassiSVC.swift
//  SMb2b
//
//  Created by Marco Gnecchi on 01/12/2017.
//  Copyright © 2017 Marco Gnecchi. All rights reserved.
//

import UIKit

class IncassiSVC: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        self.delegate = self
        self.preferredDisplayMode = .primaryOverlay
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*func splitViewController(_ splitViewController: UISplitViewController,collapseSecondary secondaryViewController: UIViewController,onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }*/
    
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        return true
    }
    
    

}
