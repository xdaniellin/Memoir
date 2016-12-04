//
//  TriggerViewController.swift
//  memoire_codepathProject
//
//  Created by Nicholas Naudé on 26/11/2016.
//  Copyright © 2016 Samihah Azim. All rights reserved.
//

import UIKit

class TriggerViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        // Setup common UI elemennts:
        setUpUI()
        // Setup button
        nextButton.backgroundColor = UIColor.memoirBlue()
        nextButton.layer.cornerRadius = 5
    }
 
}
