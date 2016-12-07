//
//  IntroViewController.swift
//  TestVideo
//
//  Created by Daniel Lin on 12/4/16.
//  Copyright © 2016 Daniel Lin. All rights reserved.
//

import UIKit
import AVFoundation

class IntroViewController: UIViewController, UIScrollViewDelegate {
    
    // Sign in & Sign up
    @IBOutlet weak var form1: UITextField!
    @IBOutlet weak var form2: UITextField!
    @IBOutlet weak var form3: UITextField!
    
    @IBOutlet weak var divider1: UIView!
    @IBOutlet weak var divider2: UIView!
    
    @IBOutlet weak var button_primary_view: UIView!
    @IBOutlet weak var button_secondary: UIButton!
    @IBOutlet weak var button_primary: UIButton!
    @IBOutlet weak var button_forgotpw: UIImageView!
    var signInState: Bool!
    @IBOutlet weak var form: UIView!
    var form_startingHeight: CGFloat!
    
    
    @IBOutlet weak var wallet: UIImageView!
    // AV Player
    var player: AVPlayer?
    var player_onboarding1: AVPlayer?
    var player_onboarding2: AVPlayer?
    var player_onboarding3: AVPlayer?
    var player_onboarding4: AVPlayer?
    var player_onboardingFinal: AVPlayer?
    
    var playerLayer_onboarding1: AVPlayerLayer?
    var playerLayer_onboarding2: AVPlayerLayer?
    var playerLayer_onboarding3: AVPlayerLayer?
    var playerLayer_onboarding4: AVPlayerLayer?
    var playerLayer_onboardingFinal: AVPlayerLayer?
    
    @IBOutlet weak var page2_videoFinal: UIView!
    
    @IBOutlet weak var idealView: UIView!
    
    @IBOutlet weak var page2_videoD: UIView!
    @IBOutlet weak var page2_videoC: UIView!
    @IBOutlet weak var page2_videoB: UIView!
    @IBOutlet weak var page2_videoA: UIView!
    
    var vidA_startFrame: CGRect!
    var vidB_startFrame: CGRect!
    var vidC_startFrame: CGRect!
    var vidD_startFrame: CGRect!
    
    var allVideos: [UIView]!
    var allVideos_frames: [CGRect]!
    var allVideos_layers: [AVPlayerLayer]!
    var allVideos_players: [AVPlayer]!
    
    @IBOutlet weak var phone: UIImageView!
    @IBOutlet weak var page3: UIView!
    @IBOutlet weak var page2: UIView!
    
    @IBOutlet weak var page1_video: UIView!
    @IBOutlet weak var page1: UIView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    var pageControl_startX: CGFloat!
    var wallet_startX: CGFloat!
    var phone_startY: CGFloat!
    var bg_pattern_startX: CGFloat!
    @IBOutlet weak var bg_pattern: UIImageView!
    
    
    override func viewDidLoad() {
        scrollView.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
        scrollView.contentSize = CGSize(width: 375*5, height: 667)
        scrollView.delegate = self
        super.viewDidLoad()
        
        pageControl_startX = pageControl.center.x
        wallet_startX = page3.center.x
        phone_startY = phone.center.y
        bg_pattern_startX = bg_pattern.center.x
        
        vidA_startFrame = page2_videoA.frame
        vidB_startFrame = page2_videoB.frame
        vidC_startFrame = page2_videoC.frame
        vidD_startFrame = page2_videoD.frame
        
        
        
        setupVideo()
        setupVideos_onboarding()
        // Do any additional setup after loading the view.
        allVideos = [page2_videoA, page2_videoB, page2_videoC, page2_videoD]
        allVideos_frames = [vidA_startFrame, vidB_startFrame, vidC_startFrame, vidD_startFrame]
        allVideos_layers = [playerLayer_onboarding1!, playerLayer_onboarding2!, playerLayer_onboarding3!, playerLayer_onboarding4!]
        allVideos_players = [ player_onboarding1!, player_onboarding2!, player_onboarding3!, player_onboarding4! ]
        
        // Sign In & Sign Up
        form.layer.borderColor =
            UIColor(red:0.45, green:0.85, blue:0.83, alpha:1.0).cgColor
        form.layer.borderWidth = 3.0;
        form.layer.cornerRadius = 5
        button_primary_view.layer.cornerRadius = 5
        signInState = true
        form_startingHeight = form.frame.height
        button_forgotpw.alpha = 0
        divider1.center.y = form.frame.height / 3
        divider2.center.y = form.frame.height * (2 / 3)
        divider2.frame.size = CGSize(width: form.frame.width, height: form.layer.borderWidth)
        divider1.frame.size = CGSize(width: form.frame.width, height: form.layer.borderWidth)
        
        
        // Dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(IntroViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func button_secondary_didPress(_ sender: Any) {
        let newHeight: CGFloat!
        let newButtonOpacity: CGFloat!
        let newDividerOpacity: CGFloat!
        let newFormPlaceholder: String!
        if signInState == true{
            newHeight = form_startingHeight * 2/3
            button_primary.setTitle("Sign In", for: .normal)
            button_secondary.setTitle("Create Account", for: .normal)
            newButtonOpacity = 1
            newDividerOpacity = 0
            newFormPlaceholder = "Password"
        } else {
            newHeight = form_startingHeight
            button_primary.setTitle("Create Account", for: .normal)
            button_secondary.setTitle("Sign In", for: .normal)
            newButtonOpacity = 0
            newDividerOpacity = 1
            newFormPlaceholder = "Email"
        }
        
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.05, options: [], animations: {
            self.button_forgotpw.alpha = newButtonOpacity
            self.form.frame.size = CGSize(width: self.form.frame.size.width, height: newHeight)
            self.divider2.alpha = newDividerOpacity
            self.form2.placeholder = newFormPlaceholder
            self.form3.alpha = newDividerOpacity
            self.form2.text = ""
            self.form3.text = ""
        }, completion: { (Bool) in
            //ok
        })
        
        signInState = !signInState
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let x = scrollView.contentOffset.x
        //print(x)
        
        let page1_x = CGFloat(0)
        let page2_x = CGFloat(375)
        let page3_x = CGFloat(750)
        let page4_x = CGFloat(1125)
        let page5_x = CGFloat(1500)
        
        
        if page1_x < x && x < page2_x {
            transition_1(x: x, start: page1_x, end: page2_x)
        } else if page2_x < x && x < page3_x {
            transition_2(x: x, start: page2_x, end: page3_x)
        } else if page3_x < x && x < page4_x {
            transition_3(x: x, start: page3_x, end: page4_x)
        } else if page4_x < x && x < page5_x {
            transition_4(x: x, start: page4_x, end: page5_x)
        }
        if x > page2_x {
            bg_pattern.center.x = convertValue(inputValue: x, r1Min: page2_x, r1Max: page5_x, r2Min: bg_pattern_startX, r2Max: bg_pattern_startX + 1125)
        }
    }
    
    func transition_1(x: CGFloat, start: CGFloat, end: CGFloat) {
        print("hi")
        
        //opacity = convertValue(inputValue: x, r1Min: start, r1Max: end-200, r2Min: 1, r2Max: 0)
        //print(opacity)
        //playerLayer.layer.opacity = opacity
    }
    func transition_2(x: CGFloat, start: CGFloat, end: CGFloat) {
        for (index,video) in allVideos.enumerated() {
            
            let new_x       = convertValue(inputValue: x, r1Min: start, r1Max: end, r2Min: allVideos_frames[index].origin.x, r2Max: idealView.frame.origin.x + 375)
            let new_y       = convertValue(inputValue: x, r1Min: start, r1Max: end, r2Min: allVideos_frames[index].origin.y, r2Max: idealView.frame.origin.y)
            let new_width   = convertValue(inputValue: x, r1Min: start, r1Max: end, r2Min: allVideos_frames[index].width, r2Max: idealView.frame.width)
            let new_height  = convertValue(inputValue: x, r1Min: start, r1Max: end, r2Min: allVideos_frames[index].height, r2Max: idealView.frame.height)
            let new_shadowRadius = convertValue(inputValue: x, r1Min: start, r1Max: end, r2Min: 10, r2Max: 0)
            
            video.layer.shadowRadius = new_shadowRadius
            video.frame = CGRect(x: new_x, y: new_y, width: new_width, height: new_height)
            
            allVideos_layers[index].frame.size = CGSize(width: new_width, height: new_height)
            allVideos_players[index].pause()
            
            
            if x < start + 100 {
                allVideos_players[index].play()
            }
        }
    }
    func transition_3(x: CGFloat, start: CGFloat, end: CGFloat) {
        let tx = convertValue(inputValue: x, r1Min: start, r1Max: end, r2Min: self.wallet_startX, r2Max: self.wallet_startX + 375)
        page3.center.x = tx
        
        let phone_new_y = convertValue(inputValue: x, r1Min: start, r1Max: end, r2Min: self.phone_startY, r2Max: self.phone_startY - 667)
        phone.center.y = phone_new_y
        
        //let new_opacity = convertValue(inputValue: x, r1Min: start, r1Max: end, r2Min: 0, r2Max: 1)
        //page2_videoFinal.alpha = new_opacity
        
        print(x)
        if x > 1032 {
            page2_videoFinal.alpha = 1 //new_opacity
        }
        else{
            page2_videoFinal.alpha = 0 //new_opacity
        }
        if x > end - ((end-start)/2) {
            player_onboardingFinal?.play()
        } else {
            player_onboardingFinal?.pause()
            player_onboardingFinal?.seek(to: kCMTimeZero)
        }
        
    }
    func transition_4(x: CGFloat, start: CGFloat, end: CGFloat) {
        print("hi")
        //Calculate Values
        var tx = convertValue(inputValue: x, r1Min: start, r1Max: end, r2Min: self.pageControl_startX, r2Max: self.pageControl_startX - 375)
        pageControl.center.x = tx
        
        tx = convertValue(inputValue: x, r1Min: start, r1Max: end, r2Min: self.wallet_startX + 375, r2Max: self.wallet_startX + 375 - 150)
        page3.center.x = tx
        //        let ty = convertValue(inputValue: offset, r1Min: start, r1Max: end, r2Min: yOffsets[i], r2Max: 0)
        //        let scale = convertValue(inputValue: offset, r1Min: start, r1Max: end, r2Min: scales[i], r2Max: 1)
        //        let rotation_radians = convertValue(inputValue: offset, r1Min: CGFloat(start), r1Max: CGFloat(end), r2Min: rotations[i], r2Max: 0)
        //        let rotation_degrees = CGFloat(Double(rotation_radians) * M_PI / 180)
        //    }
        //        //Apply Transform
        //        tile.transform = CGAffineTransform(translationX: CGFloat(tx),y: CGFloat(ty))
        //        tile.transform = tile.transform.scaledBy(x: scale, y: scale)
        //        tile.transform = tile.transform.rotated(by: rotation_degrees)
    }
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Get the current page based on the scroll offset
        let page : Int = Int(round(scrollView.contentOffset.x / 375))
        
        // Set the current page, so the dots will update
        pageControl.currentPage = page
    }
    
    func setupVideos_onboarding() {
        // Set Up Video
        let path1 = Bundle.main.path(forResource: "codepath_onboarding1_2", ofType: "mp4")
        player_onboarding1 = AVPlayer(url: NSURL(fileURLWithPath: path1!) as URL)
        playerLayer_onboarding1 = AVPlayerLayer(player: player_onboarding1)
        playerLayer_onboarding1?.frame.size = self.page2_videoA.frame.size
        
        self.page2_videoA.layer.addSublayer(playerLayer_onboarding1!)
        playerLayer_onboarding1?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        player_onboarding1?.seek(to: kCMTimeZero)
        player_onboarding1?.play()
        player_onboarding1?.isMuted = true
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player_onboarding1?.currentItem, queue: OperationQueue.main) { (notification) -> Void in
            self.player_onboarding1?.seek(to: kCMTimeZero)
            self.player_onboarding1?.play()
        }
        page2_videoA.layer.shadowColor = UIColor.black.cgColor
        page2_videoA.layer.shadowOpacity = 0.3
        page2_videoA.layer.shadowOffset = CGSize.zero
        page2_videoA.layer.shadowRadius = 10
        // Parallax
        
        
        ////////////////////////////////
        
        // Set Up Video
        let path2 = Bundle.main.path(forResource: "codepath_onboarding2_2", ofType: "mp4")
        player_onboarding2 = AVPlayer(url: NSURL(fileURLWithPath: path2!) as URL)
        playerLayer_onboarding2 = AVPlayerLayer(player: player_onboarding2)
        
        playerLayer_onboarding2?.frame.size = self.page2_videoB.frame.size
        //CGRect.init(x:-100,y:-30,width:self.view.frame.width*1.5,height:self.view.frame.height*1.15)
        
        self.page2_videoB.layer.addSublayer(playerLayer_onboarding2!)
        playerLayer_onboarding2?.videoGravity = AVLayerVideoGravityResizeAspectFill
        //self.view.layer.addSublayer(playerLayer)
        player_onboarding2?.seek(to: kCMTimeZero)
        player_onboarding2?.play()
        player_onboarding2?.isMuted = true
        // Do any additional setup after loading the view.
        //NotificationCenter.default.addObserver(self, selector: #selector(Video.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player_onboarding2.currentItem)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player_onboarding2?.currentItem, queue: OperationQueue.main) { (notification) -> Void in
            self.player_onboarding2?.seek(to: kCMTimeZero)
            self.player_onboarding2?.play()
        }
        page2_videoB.layer.shadowColor = UIColor.black.cgColor
        page2_videoB.layer.shadowOpacity = 0.3
        page2_videoB.layer.shadowOffset = CGSize.zero
        page2_videoB.layer.shadowRadius = 10
        // Parallax
        
        
        ////////////////////////
        
        // Set Up Video
        let path3 = Bundle.main.path(forResource: "codepath_onboarding3_2", ofType: "mp4")
        player_onboarding3 = AVPlayer(url: NSURL(fileURLWithPath: path3!) as URL)
        playerLayer_onboarding3 = AVPlayerLayer(player: player_onboarding3)
        
        playerLayer_onboarding3?.frame.size = self.page2_videoC.frame.size
        //CGRect.init(x:-100,y:-30,width:self.view.frame.width*1.5,height:self.view.frame.height*1.15)
        
        self.page2_videoC.layer.addSublayer(playerLayer_onboarding3!)
        playerLayer_onboarding3?.videoGravity = AVLayerVideoGravityResizeAspectFill
        //self.view.layer.addSublayer(playerLayer)
        player_onboarding3?.seek(to: kCMTimeZero)
        player_onboarding3?.play()
        player_onboarding3?.isMuted = true
        // Do any additional setup after loading the view.
        //NotificationCenter.default.addObserver(self, selector: #selector(Video.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player_onboarding2.currentItem)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player_onboarding3?.currentItem, queue: OperationQueue.main) { (notification) -> Void in
            self.player_onboarding3?.seek(to: kCMTimeZero)
            self.player_onboarding3?.play()
        }
        page2_videoC.layer.shadowColor = UIColor.black.cgColor
        page2_videoC.layer.shadowOpacity = 0.3
        page2_videoC.layer.shadowOffset = CGSize.zero
        page2_videoC.layer.shadowRadius = 10
        
        // Parallax
        //        addParallax(view: page2_videoA)
        //        addParallax(view: page2_videoB)
        //        addParallax(view: page2_videoC)
        //        addParallax(view: page2_videoD)
        //
        
        ////////////////////////
        
        // Set Up Video
        let path4 = Bundle.main.path(forResource: "codepath_q_2", ofType: "mp4")
        player_onboarding4 = AVPlayer(url: NSURL(fileURLWithPath: path4!) as URL)
        playerLayer_onboarding4 = AVPlayerLayer(player: player_onboarding4)
        
        playerLayer_onboarding4?.frame.size = self.page2_videoD.frame.size
        //CGRect.init(x:-100,y:-30,width:self.view.frame.width*1.5,height:self.view.frame.height*1.15)
        
        self.page2_videoD.layer.addSublayer(playerLayer_onboarding4!)
        playerLayer_onboarding4?.videoGravity = AVLayerVideoGravityResizeAspectFill
        //self.view.layer.addSublayer(playerLayer)
        player_onboarding4?.seek(to: kCMTimeZero)
        player_onboarding4?.play()
        player_onboarding4?.isMuted = true
        // Do any additional setup after loading the view.
        //NotificationCenter.default.addObserver(self, selector: #selector(Video.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player_onboarding2.currentItem)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player_onboarding4?.currentItem, queue: OperationQueue.main) { (notification) -> Void in
            self.player_onboarding4?.seek(to: kCMTimeZero)
            self.player_onboarding4?.play()
        }
        
        
        /////////////////////////////
        
        // Set Up Video
        let path5 = Bundle.main.path(forResource: "codepath_onboardingALL_2", ofType: "mp4")
        player_onboardingFinal = AVPlayer(url: NSURL(fileURLWithPath: path5!) as URL)
        playerLayer_onboardingFinal = AVPlayerLayer(player: player_onboardingFinal)
        
        playerLayer_onboardingFinal?.frame.size = self.page2_videoFinal.frame.size
        //CGRect.init(x:-100,y:-30,width:self.view.frame.width*1.5,height:self.view.frame.height*1.15)
        
        self.page2_videoFinal.layer.addSublayer(playerLayer_onboardingFinal!)
        
        playerLayer_onboardingFinal?.videoGravity = AVLayerVideoGravityResizeAspectFill
        //self.view.layer.addSublayer(playerLayer)
        player_onboardingFinal?.seek(to: kCMTimeZero)
        //player_onboardingFinal?.play()
        player_onboardingFinal?.isMuted = true
        // Do any additional setup after loading the view.
        //NotificationCenter.default.addObserver(self, selector: #selector(Video.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player_onboarding2.currentItem)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player_onboardingFinal?.currentItem, queue: OperationQueue.main) { (notification) -> Void in
            self.player_onboardingFinal?.seek(to: kCMTimeZero)
            self.player_onboardingFinal?.play()
        }
        
        page2_videoD.layer.shadowColor = UIColor.black.cgColor
        page2_videoD.layer.shadowOpacity = 0.3
        page2_videoD.layer.shadowOffset = CGSize.zero
        page2_videoD.layer.shadowRadius = 10
        
        
        
        
    }
    
    func setupVideo() {
        // Set Up Video
        let path = Bundle.main.path(forResource: "video_2", ofType: "mp4")
        player = AVPlayer(url: NSURL(fileURLWithPath: path!) as URL)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = CGRect.init(x:-100,y:-30,width:self.view.frame.width*2.5,height:self.view.frame.height*1.15)
        
        page1_video.layer.addSublayer(playerLayer)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        //self.view.layer.addSublayer(playerLayer)
        player?.seek(to: kCMTimeZero)
        player?.play()
        player?.isMuted = true
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(Video.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        addParallax(view: page1_video)
        
    }
    func playerItemDidReachEnd() {
        self.player?.seek(to: kCMTimeZero)
        self.player?.play()
    }
    func addParallax(view: UIView) {
        // Parallax
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -30
        verticalMotionEffect.maximumRelativeValue = 30
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -450
        horizontalMotionEffect.maximumRelativeValue = 150
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add
        view.addMotionEffect(group)
    }
    
}
