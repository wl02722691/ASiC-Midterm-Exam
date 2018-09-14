//
//  ViewController.swift
//  ASiC Midterm-Exam2
//
//  Created by 張書涵 on 2018/9/14.
//  Copyright © 2018年 AliceChang. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var orientationStatus = 1
    
    @IBOutlet weak var durationLal: UILabel!
    
    @IBOutlet weak var timeSlider: UISlider!
    
    @IBOutlet weak var currentTimeLbl: UILabel!
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var btn_volume_up: UIButton!
    
    @IBOutlet weak var btn_play_rewind: UIButton!
    
    @IBOutlet weak var btn_play: UIButton!
    
    @IBOutlet weak var btn_play_forward: UIButton!
    
    @IBOutlet weak var btn_fullScreen: UIButton!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchBtn: UIButton!
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var isVideoPlaying = false
    
    @IBAction func btn_volume_up(_ sender: UIButton) {
        if player.volume != 0 && orientationStatus == 2 {
            print(self.player.volume)
            self.player.volume = 0.0
            sender.setImage(UIImage(named: "btn_volume_off"), for: .normal)
        }else if player.volume == 0 && orientationStatus == 2{
            self.player.volume = 1.0
             sender.setImage(UIImage(named: "btn_volume_up"), for: .normal)
       
        }else if player.volume != 0 && orientationStatus != 2 {
            print(self.player.volume)
            self.player.volume = 0.0
            sender.setImage(UIImage(named: "btn_volume_off")?.withRenderingMode(.alwaysTemplate), for: .normal)
            sender.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }else{
            self.player.volume = 1.0
            sender.setImage(UIImage(named: "btn_volume_up")?.withRenderingMode(.alwaysTemplate), for: .normal)
            sender.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
    }
    
    @IBAction func btn_play_rewind(_ sender: UIButton) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - 10
        
        if newTime < 0 {
            newTime = 0
        }
        let time:CMTime = CMTimeMake(Int64(newTime * 1000), 1000)
        player.seek(to: time)
    }
    
    @IBAction func btn_play(_ sender: UIButton) {
        if isVideoPlaying && orientationStatus == 2{
            player.pause()
            sender.setImage(UIImage(named: "btn_stop"), for: .normal)
        }else if isVideoPlaying == false && orientationStatus == 2{
            player.play()
            
            sender.setImage(UIImage(named: "btn_play"), for: .normal)
            
        }else if isVideoPlaying && orientationStatus != 2{
            player.pause()
            btn_play.setImage(UIImage(named: "btn_stop")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn_play.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
        }else{
            player.play()
            btn_play.setImage(UIImage(named: "btn_play")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn_play.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        isVideoPlaying = !isVideoPlaying
        
        print("現在btn_play裡：orientationStatus\(orientationStatus)")
    }
    
    @IBAction func btn_play_forward(_ sender: UIButton) {
        guard let duration = player.currentItem?.duration else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 10
        
        if newTime < (CMTimeGetSeconds(duration) - 10 ){
            let time:CMTime = CMTimeMake(Int64(newTime * 1000), 1000)
            player.seek(to: time)
        }
    }
    
    @IBAction func btn_fullScreen(_ sender: UIButton) {
        if self.orientationStatus == 3{
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            print("現在btn_fullScreen上：orientationStatus\(orientationStatus)")
            orientationStatus = 2
        }else{
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            orientationStatus = 3
            print("現在btn_fullScreen下：orientationStatus\(orientationStatus)")
            
        }
        
    }
    
    @IBAction func searchBtn(_ sender: UIButton) {
        
        let urltextFeild = searchTextField.text ?? ""
        let url = URL(string: urltextFeild) ?? URL(string: "")!
        player = AVPlayer(url: url)
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        videoView.layer.addSublayer(playerLayer)

        player.play()
        isVideoPlaying = true
       
       playerLayer.frame = videoView.bounds
        
        addTimeObserver()
    }
    
   
    @IBAction func sliderValueChang(_ sender: UISlider) {
        player.seek(to: CMTimeMake(Int64(sender.value * 1000), 1000))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration",let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            self.durationLal.text = getTimeString(from: player.currentItem!.duration)
            
            
        }
    }
    
    func getTimeString(from time:CMTime) -> String{
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours,minutes,seconds])
        }else{
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }
    
    func addTimeObserver(){
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = self?.player.currentItem else{return}
            self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
            self?.currentTimeLbl.text = self?.getTimeString(from: currentItem.currentTime())
        })
    }


    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        print("看這裡：\(fromInterfaceOrientation.rawValue)")
        if fromInterfaceOrientation.rawValue == 3 || fromInterfaceOrientation.rawValue == 4 ||  orientationStatus == 3{
            
            
            print("現在didRotate上：\(fromInterfaceOrientation.rawValue),與\(orientationStatus)")
            
            self.orientationStatus = fromInterfaceOrientation.rawValue
            orientationStatus = 2
            
            print("現在didRotate上過完：\(fromInterfaceOrientation.rawValue),與\(orientationStatus)")
            
            self.navigationController?.isNavigationBarHidden = false
            
            btn_volume_up.setImage(UIImage(named: "btn_volume_up")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn_volume_up.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            btn_play_rewind.setImage(UIImage(named: "btn_play_rewind")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn_play_rewind.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            btn_play.setImage(UIImage(named: "btn_play")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn_play.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            btn_play_forward.setImage(UIImage(named: "btn_play_forward")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn_play_forward.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            btn_fullScreen.setImage(UIImage(named: "btn_fullScreen")?.withRenderingMode(.alwaysTemplate), for: .normal)
            
            btn_fullScreen.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            currentTimeLbl.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            durationLal.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            
            
        }else{
           
            
            print("現在didRotate下沒過：\(fromInterfaceOrientation.rawValue),與\(orientationStatus)")
            
            self.orientationStatus = fromInterfaceOrientation.rawValue
            
            print("現在didRotate下過完：\(fromInterfaceOrientation.rawValue),與\(orientationStatus)")
            
            print(fromInterfaceOrientation.rawValue)
            print("isPortrait")
            
            self.navigationController?.isNavigationBarHidden = true
            
            btn_volume_up.setImage(UIImage(named: "btn_volume_up")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn_volume_up.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            btn_play_rewind.setImage(UIImage(named: "btn_play_rewind")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn_play_rewind.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            btn_play.setImage(UIImage(named: "btn_play")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn_play.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            btn_play_forward.setImage(UIImage(named: "btn_play_forward")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn_play_forward.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            btn_fullScreen.setImage(UIImage(named: "btn_fullScreen_exit")?.withRenderingMode(.alwaysTemplate), for: .normal)
            btn_fullScreen.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            currentTimeLbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            durationLal.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
        
        }
        
        if playerLayer != nil && videoView != nil{
                playerLayer.frame = videoView.bounds
        }
        
       
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(orientationStatus)
        
        self.navigationItem.title = "Video Player"
        timeSlider.tintColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        
        searchBtn.layer.borderColor = #colorLiteral(red: 0.8039215686, green: 0.8039215686, blue: 0.8039215686, alpha: 1)
        searchBtn.layer.borderWidth = 1
        searchBtn.clipsToBounds = true
        searchBtn.layer.cornerRadius = 5
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("hi")
    }
    

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        
    }

}

