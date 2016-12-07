//
//  ExisitingMemoirViewController.swift
//  VideoPlayback
//
//  Created by Nicholas Naudé on 06/12/2016.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

import UIKit

class ExisitingMemoirViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate{
        
    @IBOutlet weak var existingMemoirCollectionView: UICollectionView!

        
        var existingMemoirImages = [UIImage]()
        let reuseIdentifier = "existingMemoirCell"
        var collectionViewLayout: CustomImageFlowLayout!
        
        //Lifecycle methods
        override func viewDidLoad() {
            super.viewDidLoad()
            
            existingMemoirCollectionView.dataSource = self
            existingMemoirImages = [UIImage(named:"Dummy1")!, UIImage(named:"Dummy2")!, UIImage(named:"Dummy3")!,UIImage(named:"Dummy4")!,UIImage(named:"Dummy5")!,UIImage(named:"Dummy6")!,UIImage(named:"Dummy7")!]
            
            // Do any additional setup after loading the view.
            
            collectionViewLayout = CustomImageFlowLayout()
            existingMemoirCollectionView.collectionViewLayout = collectionViewLayout
        }
        
        override func viewDidLayoutSubviews() {
            
            // Setup navigation bar colors etc
            navigationController?.navigationBar.barTintColor = UIColor.memoirBlue()
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            navigationItem.backBarButtonItem?.tintColor = UIColor.white
            
            
            navigationController?.isNavigationBarHidden = false
            setUpUI()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            navigationController?.isNavigationBarHidden = true
        }
        
        // MARK: - UICollectionViewDataSource protocol
        
        // tell the collection view how many cells to make
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.existingMemoirImages.count
        }
        
        // make a cell for each cell index path
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            // get a reference to our storyboard cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! ExistingCollectionViewCell
            
            // Use the outlet in our custom class to get a reference to the UILabel in the cell
            cell.existingMemoirImage.image = self.existingMemoirImages[indexPath.item]
            return cell
        }
        
        
        func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
            return 1
        }
        
        
        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
        {
            return CGSize(width: collectionView.frame.size.width/3.2, height: 100)
        }
        
}
