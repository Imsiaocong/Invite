//
//  LoginViewController.swift
//  Final
//
//  Created by Di Wang on 5/6/20.
//  Copyright © 2020 william haberkorn. All rights reserved.
//

import UIKit
import TextFieldEffects
import TransitionButton
import AVFoundation
import AVKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var log: UIView!
    
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let regularBlur = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: regularBlur)
        blurView.frame = log.bounds
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        blurView.layer.cornerRadius = 16
        blurView.layer.masksToBounds = true
        log.addSubview(blurView)
        log.sendSubviewToBack(blurView)
        
        let usrnameField = YokoTextField(frame: CGRect(x: 30, y: 40, width: 200, height: 60))
        usrnameField.placeholderColor = .darkGray
        usrnameField.textColor = .white
        usrnameField.placeholder = "Username"

        self.log.addSubview(usrnameField)
        
        let pswField = YokoTextField(frame: CGRect(x: 30, y: 120, width: 200, height: 60))
        pswField.placeholderColor = .darkGray
        pswField.textColor = .white
        pswField.placeholder = "Password"
        pswField.isSecureTextEntry = true

        self.log.addSubview(pswField)
        
        let button = TransitionButton(frame: CGRect(x: 30, y: 265, width: 200, height: 40))
        self.log.addSubview(button)
        
        button.backgroundColor = .red
        button.setTitle("Go!", for: .normal)
        button.cornerRadius = 20
        button.spinnerColor = .white
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        
        playBackgoundVideo()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func buttonAction(_ button: TransitionButton) {
        button.startAnimation() // 2: Then start the animation when the user tap the button
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            sleep(2) // 3: Do your networking task or background work here.
            
            DispatchQueue.main.async(execute: { () -> Void in
                // 4: Stop the animation, here you have three options for the `animationStyle` property:
                // .expand: useful when the task has been compeletd successfully and you want to expand the button and transit to another view controller in the completion callback
                // .shake: when you want to reflect to the user that the task did not complete successfly
                // .normal
                button.stopAnimation(animationStyle: .expand, completion: {
                    self.player?.pause()
                    self.performSegue(withIdentifier: "toRec", sender: self)
                })
            })
        })
    }
    
    private func playBackgoundVideo() {
        if let filePath = Bundle.main.path(forResource: "moscow", ofType:"mp4") {
            let filePathUrl = NSURL.fileURL(withPath: filePath) as NSURL
            player = AVPlayer(url: filePathUrl as URL)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.videoView.bounds
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: nil) { (_) in
                self.player?.seek(to: CMTime.zero)
                self.player?.play()
            }
            self.videoView.layer.addSublayer(playerLayer)
            player?.play()
        }
    }

}
