//
//  VideoViewController.swift
//  memoire_codepathProject
//
//  Created by Nicholas Naudé on 26/11/2016.
//  Copyright © 2016 Samihah Azim. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var videosCollectionView: UICollectionView!
    @IBOutlet weak var createButton: UIButton!
    
    let reuseIdentifier = "videoCell"
    var videoImages = [UIImage]()
    var collectionViewLayout: CustomImageFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        videosCollectionView.dataSource = self
        videoImages = [UIImage(named: "Dummy1")!, UIImage(named: "Dummy2")!, UIImage(named: "Dummy3")!, UIImage(named: "Dummy4")!, UIImage(named: "Dummy5")!, UIImage(named: "Dummy6")!, UIImage(named: "Dummy7")!, UIImage(named: "Dummy8")!, UIImage(named: "Dummy9")!, UIImage(named: "Dummy10")!, UIImage(named: "Dummy11")!, UIImage(named: "Dummy12")!, UIImage(named: "Dummy13")!, UIImage(named: "Dummy14")!, UIImage(named: "Dummy15")!, UIImage(named: "Dummy16")!, UIImage(named: "Dummy17")!, UIImage(named: "Dummy18")!, UIImage(named: "Dummy19")!, UIImage(named: "Dummy20")!, UIImage(named: "Dummy21")!]
        
        collectionViewLayout = CustomImageFlowLayout()
        videosCollectionView.collectionViewLayout = collectionViewLayout
        
    }
    
    
    override func viewDidLayoutSubviews() {
        
        videosCollectionView.backgroundColor = UIColor.memoirBlack()
        
        // Setup navigation bar colors etc
        navigationController?.navigationBar.barTintColor = UIColor.memoirBlue()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.white


        // Setup common UI elements:
        setUpUI()
        createButton.backgroundColor = UIColor.memoirBlue()
        createButton.layer.cornerRadius = 5
    }
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videoImages.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! VideoCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.videoImage.image = self.videoImages[indexPath.item]
        return cell
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.size.width/3.2, height: 100)
    }

    @IBAction func onBackArrowTapped(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
}
