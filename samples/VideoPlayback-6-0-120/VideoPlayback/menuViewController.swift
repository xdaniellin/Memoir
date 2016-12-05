//
//  menuViewController.swift
//  VideoPlayback
//
//  Created by Daniel Lin on 11/23/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

import UIKit

class menuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var galleryHeaderView: UIView!
    @IBAction func didTapCloseButton(_ sender: AnyObject) {
        //dismiss(animated: true)
    }
    @IBOutlet weak var galleryTableView: UITableView!
    
    @IBOutlet weak var createMemoirButton: UIButton!
    var galleryImages = [UIImage]()
    var galleryDate = [String?]()
    var titleArray = [String?]()
    var contributorsArray = [String?]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryImages = [UIImage(named: "Dummy1")!, UIImage(named: "Dummy2")!, UIImage(named: "Dummy3")!, UIImage(named: "Dummy4")!, UIImage(named: "Dummy5")!, UIImage(named: "Dummy6")!, UIImage(named: "Dummy7")!]
        
        galleryDate = ["1 contributors", "7 contributors", "1 contributors", "0 contributors", "1 contributors", "2 contributors", "4 contributors"]
        
        titleArray = ["Kingsley", "CodePath University", "Food, glorious food!", "Big Sur", "Nature", "Horseriding in Big Sur", "Art class"]
        
        contributorsArray = ["1 contributor", "7 contributors", "1 contributor", "0 contributors", "1 contributor", "2 contributors", "4 contributors", "1 contributors"]
    }
    
    
    
    override func viewDidLayoutSubviews() {
        galleryHeaderView.backgroundColor = UIColor.memoirBlue()
        navigationController?.isNavigationBarHidden = true
        setUpUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    
    // TableView methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.galleryImages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "galleryCell") as! GalleryTableViewCell
        cell.galleryImage.image = galleryImages[indexPath.row]
        cell.titleLabel?.text = titleArray[indexPath.row]
        cell.contributorsLabel.text = contributorsArray[indexPath.row]
        cell.backgroundColor = UIColor.memoirBlack()
        return cell
    }
    
    func tableView(_ tableView: UITableView!, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        if indexPath.row == 1 {
            performSegue(withIdentifier: "memoirSegue", sender: nil)
        }
    }
    
    @IBAction func onCameraButtonTapped(_ sender: Any) {
            navigationController?.popToRootViewController(animated: true)
    }
}
