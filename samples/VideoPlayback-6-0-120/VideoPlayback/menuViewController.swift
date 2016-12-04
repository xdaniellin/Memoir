//
//  menuViewController.swift
//  VideoPlayback
//
//  Created by Daniel Lin on 11/23/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

import UIKit

class menuViewController: UIViewController {
    @IBAction func didTapCloseButton(_ sender: AnyObject) {
        //dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onXButtonTapped(_ sender: Any) {
       dismiss(animated: true, completion: nil)
    }
}
