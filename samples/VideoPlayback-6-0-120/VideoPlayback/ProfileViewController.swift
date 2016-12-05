//
//  ProfileViewController.swift
//  memoire_codepathProject
//
//  Created by Nicholas Naudé on 26/11/2016.
//  Copyright © 2016 Samihah Azim. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet var backgroundView: UIScrollView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var account: UIView!
    @IBOutlet weak var address: UIView!
    @IBOutlet weak var creditcard: UIView!
    @IBOutlet weak var topAssets: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: 375, height: 1100)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //top assets
        topAssets.alpha = 0.0
        
        UIView.animate(withDuration: 1.0, delay: 0.7,
                       options: [],
                       animations: {
                        self.topAssets.alpha = 1.0
        }, completion: nil)
        
        
        //account
        account.alpha = 0.0
        
        UIView.animate(withDuration: 1.0, delay: 0.7,
                       options: [],
                       animations: {
                        self.account.alpha = 1.0
        }, completion: nil)
        
        //address
        address.alpha = 0.0
        
        UIView.animate(withDuration: 1.0, delay: 0.7,
                       options: [],
                       animations: {
                        self.address.alpha = 1.0
        }, completion: nil)
        
        //creditcard
        creditcard.alpha = 0.0
        
        UIView.animate(withDuration: 1.0, delay: 0.7,
                       options: [],
                       animations: {
                        self.creditcard.alpha = 1.0
        }, completion: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        backgroundView.backgroundColor = UIColor.memoirBlack()
        setUpUI()
    }
    @IBAction func onDismissTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSaveButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
