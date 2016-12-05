//
//  InviteViewController.swift
//  VideoPlayback
//
//  Created by Nicholas Naudé on 04/12/2016.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

import UIKit

class InviteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var makeButton: UIButton!
    @IBOutlet weak var contactsTableView: UITableView!
    
    var contactsArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactsArray = ["Aaron Bailey","Adam Noffsinger","Amrutha Krishnan","Amy Wu","Anton Herasymenko","Charlie Hieger","Chris Argonish","Daniel Lin","Devon Latzen","Doris Hernz","Grigory Rudko","Jean Menezes","Kristen Turner","Kyler Blue","Lauren Tindal","Michael Volovar","Namrata Mohanty","Nicholas Naudé","Nicolai Safai","Orion Richardson","Rachel Jin","Samihah","Sophia Kc.","Stephan Charbit","Tim Lee","Zia Levy"]
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        contactsTableView.backgroundColor = UIColor.memoirBlack()
        
        // Setup navigation bar colors etc
        navigationController?.navigationBar.barTintColor = UIColor.memoirBlue()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    
        // Setup common UI elements:
        setUpUI()
        makeButton.backgroundColor = UIColor.memoirBlue()
        makeButton.layer.cornerRadius = 5
        contactsTableView.backgroundColor = UIColor.memoirBlack()
    }
    
    // TableView methods:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactsArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsCell") as! ContactsTableViewCell
    
        cell.contactLabel?.text = contactsArray[indexPath.row]
        
        if cell.contactLabel.text == "Nicholas Naudé" {
            cell.contactImage.image = UIImage(named: "Nic")
        } else if cell.contactLabel.text == "Daniel Lin" {
            cell.contactImage.image = UIImage(named: "Daniel")
        } else if cell.contactLabel.text == "Samihah" {
        cell.contactImage.image = UIImage(named: "Samihah")
        } else {
        cell.contactImage.image = UIImage(named: "blankAvatar")
        }
    
        cell.backgroundColor = UIColor.memoirBlack()
        return cell
    }
    
    func tableView(_ tableView: UITableView!, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
    }
    
    @IBAction func onBackArrowTapped(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
}
