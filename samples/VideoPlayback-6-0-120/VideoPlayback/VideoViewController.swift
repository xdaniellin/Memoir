//
//  VideoViewController.swift
//  memoire_codepathProject
//
//  Created by Nicholas Naudé on 26/11/2016.
//  Copyright © 2016 Samihah Azim. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {
    
    @IBOutlet var videosCollectionView: UICollectionView!
    @IBOutlet weak var createButton: UIButton!
    
    
    //Lifecycle methods:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //UI methods:
    override func viewDidLayoutSubviews() {
        // Setup common UI elemennts:
        setUpUI()
        createButton.backgroundColor = UIColor.memoirBlue()
        createButton.layer.cornerRadius = 5
    }
    
    
}
