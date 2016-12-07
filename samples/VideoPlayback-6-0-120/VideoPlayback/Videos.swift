//
//  Video.swift
//  TestVideo
//
//  Created by Daniel Lin on 12/3/16.
//  Copyright © 2016 Daniel Lin. All rights reserved.
//

import UIKit
import AVFoundation

class Video: UIViewController {
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideo()
        
    }
    
    
    func playerItemDidReachEnd() {
        self.player?.seek(to: kCMTimeZero)
        self.player?.play()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupVideo() {
        // Set Up Video
        let path = Bundle.main.path(forResource: "video", ofType: "mp4")
        player = AVPlayer(url: NSURL(fileURLWithPath: path!) as URL)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = CGRect.init(x:-100,y:-30,width:self.view.frame.width*1.5,height:self.view.frame.height*1.15)
        
        
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(playerLayer)
        player?.seek(to: kCMTimeZero)
        player?.play()
        player?.isMuted = true
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(Video.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        
        // Parallax
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -30
        verticalMotionEffect.maximumRelativeValue = 30
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -100
        horizontalMotionEffect.maximumRelativeValue = 100
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        self.view.addMotionEffect(group)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
