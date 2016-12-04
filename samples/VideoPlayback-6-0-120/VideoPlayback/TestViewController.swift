//
//  TestViewController.swift
//  VideoPlayback
//
//  Created by Daniel Lin on 11/16/16.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    @IBOutlet weak var ui_button: UIButton!
    @IBOutlet weak var main_label: UILabel!
    //Define a variable for an array to hold the ViewControllers named, viewControllers.
    @IBOutlet weak var bottom_gradient: UIView!
    @IBOutlet weak var contentView: UIView!
    var AR_viewController: UIViewController!

    @IBOutlet weak var testButton: UIButton!
    var profileView: UIView!
    var bgBarView: UIView!
    var progressBarArray: [UIView] = []
    var progressBarArray_active: [UIView] = []
    let padding_fromSides = 30.0
    let padding_fromBottom = 25
    let interVideoPadding = 2.0
    let progressBarHeight = 2.0
    var numberOfVideos: Int!
    @IBOutlet weak var button: UIView!
    @IBAction func buttonTouchDown(_ sender: AnyObject) {
        print("down")
    }
//    @IBAction func buttonTouchUp(_ sender: AnyObject) {
//        print("up")
//
//        if ui_button.currentImage == UIImage(named: "icon_dl_default") {
//            print("true")
//        }
//    }
//    
    
    
    //var AR = VideoPlaybackEAGLView()
    
    //AR.someProperty = "Hello World"
    //instanceOfCustomObject.someMethod()
    
    @IBOutlet weak var holdingBox: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        holdingBox.frame.size = CGSize(width: Double(self.view.frame.size.width)-padding_fromSides * 2, height: progressBarHeight)
        holdingBox.frame.origin.x = CGFloat(padding_fromSides)
        holdingBox.frame.origin.y = self.view.bounds.maxY - CGFloat(padding_fromBottom) - CGFloat(progressBarHeight)
        holdingBox.backgroundColor = UIColor(red:1, green:1.00, blue:1, alpha:0.0)
        
        display_AR_viewController()
        
        createScanner()
        //createProgressBars(numberOfVideos: 10)
        
        // Style button
        button.layer.cornerRadius = 22
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = CGSize.zero
        button.layer.shadowRadius = 10
        
        // Style Gradient
        let topColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        let bottomColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: [Float] = [0.0,1.0]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        gradientLayer.frame = bottom_gradient.layer.bounds //frame
        bottom_gradient.layer.insertSublayer(gradientLayer, at: 0)
        
        // Position & Style Button
        button.frame.origin.y = holdingBox.frame.origin.y - CGFloat(padding_fromBottom) - (button.frame.height*3/4)
        button.frame.origin.x = self.view.bounds.width - CGFloat(padding_fromSides) - button.frame.width
        button.backgroundColor = UIColor(red:0.54, green:1.00, blue:0.99, alpha: 0.0)
        
        // Position & Style Label
        main_label.frame.origin.x = CGFloat(padding_fromSides)
        main_label.frame.origin.y = holdingBox.frame.origin.y - CGFloat(padding_fromBottom) - main_label.frame.height
        
        // SWIFT NOTIFICATION: PROGRESS UPDATE
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "progressUpdate"), object: nil, queue: OperationQueue.main) { (notification: Notification!) in
            let progress = Float(notification?.userInfo?["progress"] as! NSNumber.FloatLiteralType)
            let current_index = Int(notification?.userInfo?["current_index"] as! NSNumber.FloatLiteralType)
            
            print("THE PROGRESS IS ",progress)
            print("THE CURRENT INDEX IS ",current_index)
            //
            self.updateProgressBars(progress: progress, current_index: current_index)
        }
        
        
        // SWIFT NOTIFICATION: TAP LEFT
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "tapLeft"), object: nil, queue: OperationQueue.main) { (notification: Notification!) in
            let userInfo = notification?.userInfo
            print("Hey....we tapped LEFT")
        }

        // SWIFT NOTIFICATION: TAP RIGHT
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "tapRight"), object: nil, queue: OperationQueue.main) { (notification: Notification!) in
            let userInfo = notification?.userInfo
            print("Hey....we tapped RIGHT")
        }
        
        // SWIFT NOTIFICATION: SCAN ON (not set)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "scanOn"), object: nil, queue: OperationQueue.main) { (notification: Notification!) in
            let previous_numberOfVideos = self.numberOfVideos
            let new_numberOfVideos = Int(notification?.userInfo?["numberOfVideos"] as! NSNumber.FloatLiteralType)
            
            if new_numberOfVideos != previous_numberOfVideos{
                
                if new_numberOfVideos == 0 {
                    self.createScanner()
                    self.destroyProgressBars()
                    self.main_label.text = "Searching"
                    self.ui_button.setImage(UIImage(named: "icon_dl_default"), for: UIControlState.normal)
                }
                else {
                    self.createProgressBars(numberOfVideos: new_numberOfVideos)
                    self.destroyScanner()
                    self.main_label.text = "Columbia 2016"
                    self.ui_button.setImage(UIImage(named: "icon_dl_pause"), for: UIControlState.normal)
                }
                self.numberOfVideos = new_numberOfVideos
                
                //DL: DLIN LATEST:
                // - find a way to kill progressbar/scanner
                // - make a gradient
                // - border animation?
                // - button shadow interaction (touchdown/dtouch up)
            }
            print(self.numberOfVideos)
        }
    }

    
    func createScanner () {
        // Layer Creation
        profileView = UIView(frame: CGRect(x: 250, y: 0, width: 100, height: holdingBox.frame.height))
        profileView.backgroundColor = UIColor(red:0.54, green:1.00, blue:0.99, alpha:1.0)
        profileView.layer.cornerRadius = CGFloat(progressBarHeight) / 2
        profileView.frame.origin.x = 0
        profileView.frame.size = CGSize(width: 0, height: holdingBox.frame.height)

        bgBarView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: holdingBox.frame.height))
        bgBarView.backgroundColor = UIColor(red:1, green:1.00, blue:1, alpha:0.3)
        bgBarView.layer.cornerRadius = CGFloat(progressBarHeight) / 2
        bgBarView.frame.size = holdingBox.frame.size
        
        // Add to View
        self.holdingBox.addSubview(profileView)
        self.holdingBox.addSubview(bgBarView)
        
        // Animation
        UIView.animateKeyframes(withDuration: 1.25, delay: 0, options: [.calculationModeCubicPaced, .repeat, .autoreverse], animations:{
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0, animations: {
                self.profileView.frame.origin.x = self.holdingBox.frame.width/2
                self.profileView.frame.size = CGSize(width: 150, height: self.holdingBox.frame.height)
            })
            
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0, animations: {
                self.profileView.frame.origin.x = self.holdingBox.frame.width
                self.profileView.frame.size = CGSize(width: 0, height: self.holdingBox.frame.height)
            })
            
            }, completion: nil)
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testMe() {
        print("SUCCESS I GUESS")
        //let userInfo = notification?.userInfo

    }

    func display_AR_viewController() {
        // Within the ViewDidLoad() method, access the main Storyboard through code.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Next, instantiate each ViewController by referencing storyboard and the particular ViewController's Storyboard ID
        AR_viewController = storyboard.instantiateViewController(withIdentifier: "AR")
        
        // Add the new ViewController. (Calls the viewWillAppear method of the ViewController you are adding)
        addChildViewController(AR_viewController)
        
        // Adjust the size of the ViewController view you are adding to match the contentView of your tabBarViewController and add it as a subView of the contentView.
        //AR_viewController.view.frame = contentView.frame.applying(CGAffineTransform .scaledBy(x: 2, y:2))
        AR_viewController.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        AR_viewController.view.frame = contentView.bounds
        AR_viewController.view.transform = CGAffineTransform(scaleX: 1.07, y:1.07)
        //AR_viewController.view.frame = contentView.bounds.CGAffineTransform(scaleX: 2.4, y:2.4)
        contentView.addSubview(AR_viewController.view)
        //contentView.center.y += 0
        
        // Call the viewDidAppear method of the ViewController you are adding using didMove(toParentViewController: self).
        AR_viewController.didMove(toParentViewController: self)
    }
    
    func createProgressBars (numberOfVideos: Int) {
        for i in 0...numberOfVideos-1{
            
            // Variables
            let width  = CGFloat(holdingBox.frame.width) / CGFloat(numberOfVideos) - CGFloat(interVideoPadding) + CGFloat(CGFloat(interVideoPadding) / CGFloat(numberOfVideos))
            let height = holdingBox.frame.height
            let x      = Double(i) * ( Double(width) + interVideoPadding )
            let y      = 0
            
            // Create
            let bar = UIView( frame: CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height)) )
            let bar_active = UIView( frame: CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(0), height: CGFloat(height)) )
            
            // Modify
            bar.backgroundColor = UIColor(red:1, green:1.00, blue:1, alpha:0.3)
            bar_active.backgroundColor = UIColor(red:0.54, green:1.00, blue:0.99, alpha:1.0)
            bar.layer.cornerRadius = 3.0
            bar_active.layer.cornerRadius = 3.0
            
            // Push To Array
            progressBarArray.append(bar)
            progressBarArray_active.append(bar_active)
            
            // Add To View
            self.holdingBox.addSubview(bar)
            self.holdingBox.addSubview(bar_active)
        }
    }

    
    func destroyProgressBars () {
        for bar in progressBarArray { bar.removeFromSuperview() }
        for bar in progressBarArray_active { bar.removeFromSuperview() }
        progressBarArray = []
        progressBarArray_active = []
        
    }
    
    func destroyScanner () {
        if self.profileView != nil {
            self.profileView.removeFromSuperview()
            self.bgBarView.removeFromSuperview()
        }
    }
    
    func updateProgressBars( progress: Float, current_index: Int) {
        let fullWidth = Double(progressBarArray[0].frame.width)
        print(progressBarArray_active)
        for (i, bar) in self.progressBarArray_active.enumerated() {
            
            if i < current_index {
                // Full
                bar.frame.size = CGSize(width: fullWidth, height: progressBarHeight)
            }
            else if i == current_index {
                // Adjusted
                let currentWidth = Double(progress) * fullWidth
                bar.frame.size = CGSize(width: currentWidth, height: progressBarHeight)
                
            }
            else {
                // Empty
                bar.frame.size = CGSize(width: 0, height: progressBarHeight)
            }
        }
    }
    
}
