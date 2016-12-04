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
    @IBOutlet var selectedTrigger: UIImageView!
    @IBOutlet var photosCollectionView: UICollectionView!
    
    let reuseIdentifier = "photoCell" // also enter this string as the cell identifier in the storyboard
    var collectionViewItems = [UIImage]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewItems = [UIImage(named:"Dummy1")!, UIImage(named:"Dummy2")!, UIImage(named:"Dummy3")!, UIImage(named:"Dummy4")!, UIImage(named:"Dummy5")!, UIImage(named:"Dummy6")!, UIImage(named:"Dummy7")!, UIImage(named:"Dummy8")!, UIImage(named:"Dummy9")!, UIImage(named:"Dummy10")!, UIImage(named:"Dummy11")!, UIImage(named:"Dummy12")!]
    }
    
    override func viewDidLayoutSubviews() {
        // Setup common UI elemennts:
        setUpUI()

        // Setup button
        nextButton.backgroundColor = UIColor.memoirBlue()
        nextButton.layer.cornerRadius = 5
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionViewItems.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! UICollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var totalHeight: CGFloat = (self.view.frame.width / 3)
        var totalWidth: CGFloat = (self.view.frame.width / 3)
        
        print(totalWidth) // this prints 106.666666667
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
}
