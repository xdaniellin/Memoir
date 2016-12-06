//
//  PrintViewController.swift
//  VideoPlayback
//
//  Created by Nicholas Naudé on 05/12/2016.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

import UIKit

class PrintViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSaveTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
