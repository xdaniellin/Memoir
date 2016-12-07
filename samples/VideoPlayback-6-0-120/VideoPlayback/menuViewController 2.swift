//
//  menuViewController.swift
//  VideoPlayback
//
//  Created by Daniel Lin on 11/23/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

import UIKit

class menuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBAction func didTapCloseButton(_ sender: AnyObject) {
        //dismiss(animated: true)
    }
    @IBOutlet weak var galleryTableView: UITableView!
    
    var galleryImages = [UIImage]()
    var galleryDate = [String?]()
    var titleArray = [String?]()
    var contributorsArray = [String?]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryImages = [UIImage(named: "Dummy1")!, UIImage(named: "Dummy2")!, UIImage(named: "Dummy3")!, UIImage(named: "Dummy4")!, UIImage(named: "Dummy5")!, UIImage(named: "Dummy6")!, UIImage(named: "Dummy7")!, UIImage(named: "Dummy8")!, UIImage(named: "Dummy9")!, UIImage(named: "Dummy10")!, UIImage(named: "Dummy11")!, UIImage(named: "Dummy12")!, UIImage(named: "Dummy13")!, UIImage(named: "Dummy14")!, UIImage(named: "Dummy15")!, UIImage(named: "Dummy16")!, UIImage(named: "Dummy17")!, UIImage(named: "Dummy18")!, UIImage(named: "Dummy19")!, UIImage(named: "Dummy20")!, UIImage(named: "Dummy21")!]
        
        galleryDate = ["1 contributors", "7 contributors", "1 contributors", "0 contributors", "1 contributors", "2 contributors", "4 contributors", "0 contributors", "1 contributors", "3 contributors", "2 contributors", "7 contributors", "0 contributors", "0 contributors", "0 contributors", "1 contributors", "1 contributors", "4 contributors", "5 contributors", "1 contributors", "0 contributors", ]
        
        titleArray = ["Kingsley's first steps", "Our Cuba Trip", "Where the wild things are", "Squad", "Californication", "", "San Francisco nights", "0 contributors", "1 contributors", "3 contributors", "2 contributors", "7 contributors", "0 contributors", "0 contributors", "0 contributors", "1 contributors", "1 contributors", "4 contributors", "5 contributors", "1 contributors", "0 contributors", ]
        
        contributorsArray = ["1 contributors", "7 contributors", "1 contributors", "0 contributors", "1 contributors", "2 contributors", "4 contributors", "0 contributors", "1 contributors", "3 contributors", "2 contributors", "7 contributors", "0 contributors", "0 contributors", "0 contributors", "1 contributors", "1 contributors", "4 contributors", "5 contributors", "1 contributors", "0 contributors", ]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TableView methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.galleryImages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "galleryCell") as! GalleryTableViewCell        
        cell.galleryImage.image = galleryImages[indexPath.row]
        cell.textLabel?.text = titleArray[indexPath.row]
        cell.contributorsLabel.text = contributorsArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView!, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
}
