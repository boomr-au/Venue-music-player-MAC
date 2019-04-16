//
//  VPlayListViewController.swift
//  Venue
//
//  Created by CHITRA on 01/11/18.
//  Copyright © 2018 CHITRA. All rights reserved.
//

import Cocoa
import AVFoundation

class VPlayListViewController: NSViewController {
    var selectedZone:Result?
    var selectedPlayList:Playlists?
    var arrayTracks=[Track]()
    var currentTrack:Track?
    
    @IBOutlet var textFieldVolume:NSTextField!
    @IBOutlet var textFieldTime:NSTextField!
    @IBOutlet var textFieldArtist:NSTextField!
    @IBOutlet var textFieldCurrentSong:NSTextField!
    @IBOutlet var textFieldNextSong:NSTextField!
    @IBOutlet var textFieldGain:NSTextField!
    @IBOutlet var textFieldPlayListName:NSTextField!

    @IBOutlet var sliderVolume:NSSlider!
    @IBOutlet var buttonPlay:NSButton!
    @IBOutlet var progressIndicator:NSProgressIndicator!

    // MARK: AVAudio properties
    var audioFormat: AVAudioFormat?
    var audioSampleRate: Float = 0
    var audioLengthSeconds: Float = 0
    var audioLengthSamples: AVAudioFramePosition = 0
    var engine = AVAudioEngine()
    var player = AVAudioPlayerNode()
    var rateEffect = AVAudioUnitTimePitch()
    var needsFileScheduled = true
    var currentPosition: AVAudioFramePosition = 0
    var timerSong = Timer()
    
    var audioFile: AVAudioFile? {
        didSet {
            if let audioFile = audioFile {
                audioFormat = audioFile.processingFormat
                audioLengthSamples = audioFile.length
                audioSampleRate = Float(audioFormat?.sampleRate ?? 44100)
                audioLengthSeconds = Float(audioLengthSamples) / audioSampleRate
            }
        }
    }
    var audioFileURL: URL? {
        didSet {
            if let audioFileURL = audioFileURL {
                audioFile = try? AVAudioFile(forReading: audioFileURL)
            }
        }
    }
    var currentFrame: AVAudioFramePosition {
        guard let lastRenderTime = player.lastRenderTime,
            let playerTime = player.playerTime(forNodeTime: lastRenderTime) else {
                return 0
        }
        
        return playerTime.sampleTime
    }
    enum TimeConstant {
        static let secsPerMin = 60
        static let secsPerHour = TimeConstant.secsPerMin * 60
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.progressIndicator.startAnimation(nil)
        self.fetchSong()
        self.setSlider()
        //textFieldTime.stringValue = "\(formatted(time: 0))/\(formatted(time: audioLengthSeconds))"
    }
    
    @IBAction func playAction(_ sender: NSButton) {
        if player.isPlaying {
            player.pause()
            sender.image = NSImage.init(named: "ic_play")
            timerSong.invalidate()
        } else {
            
            self.play()
        }
    }
    func play(){
        if needsFileScheduled {
            needsFileScheduled = false
            scheduleAudioFile()
        }
        player.play()
        buttonPlay.image = NSImage.init(named: "ic_pause")
        timerSong = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
        timerSong.fire()
    }
    @IBAction func sliderValueChanged(_ sender: NSSlider) {
        let currentValue = Int(sender.doubleValue)
        player.volume = Float(currentValue)
        textFieldVolume.stringValue = "\(currentValue)/15"
    }
    @IBAction func dismissView(sender:NSButton){
        self.dismiss(self)
    }
    
    func fetchSong(){
        let dictParams = ["playlist_id":"","zone_id":selectedZone?.zone_id,"p_type":""]
        NetworkManager().postMethodAlamofire(ConstantsManager.getNextTrack, dictionary: dictParams as NSDictionary) { (success, result, error) in
            self.progressIndicator.stopAnimation(nil)
            if let nextTrack = result as? NextTrackBase{
                if nextTrack.track != nil{
                    self.arrayTracks.append(nextTrack.track!)
                    self.currentTrack = nextTrack.track
                    let url = URL.init(string: (nextTrack.track?.song_url)!)
                    self.setupAudio(url: url!)
                    self.play()
                    self.setUpUI()
                }
            }
        }
    }
    
    func setUpUI(){
        self.textFieldPlayListName.stringValue = self.currentTrack?.playlist_name ?? ""
        self.textFieldCurrentSong.stringValue = self.currentTrack?.song_title ?? ""
        self.textFieldArtist.stringValue = self.currentTrack?.artist_name ?? ""
    }
}

extension VPlayListViewController{
    func setupAudio(url:URL) {
        //audioFileURL = Bundle.main.url(forResource: "Intro", withExtension: "mp4")
        audioFileURL = url
        // 2
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: audioFormat)
        engine.prepare()
        player.volume = 5.0
        do {
            // 3
            try engine.start()
        } catch{
        }
    }
    func scheduleAudioFile() {
        guard let audioFile = audioFile else { return }
        
        player.scheduleFile(audioFile, at: nil) { [weak self] in
            self?.needsFileScheduled = true
        }
    }
    
    func setSlider(){
        sliderVolume.minValue = 0.0
        sliderVolume.maxValue = 15.0
        sliderVolume.doubleValue = 5.0
    }
    func formatted(time: Float) -> String {
        var secs = Int(ceil(time))
        var hours = 0
        var mins = 0
        
        if secs > TimeConstant.secsPerHour {
            hours = secs / TimeConstant.secsPerHour
            secs -= hours * TimeConstant.secsPerHour
        }
        
        if secs > TimeConstant.secsPerMin {
            mins = secs / TimeConstant.secsPerMin
            secs -= mins * TimeConstant.secsPerMin
        }
        
        var formattedString = ""
        if hours > 0 {
            formattedString = "\(String(format: "%02d", hours)):"
        }
        formattedString += "\(String(format: "%02d", mins)):\(String(format: "%02d", secs))"
        return formattedString
    }
    @objc func updateUI() {
        currentPosition = currentFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        
        let time = Float(currentPosition) / audioSampleRate
        //textFieldTime.stringValue = "\(formatted(time: time))/\(formatted(time: audioLengthSeconds-time))"
        
        if currentPosition >= audioLengthSamples {
            player.stop()
            timerSong.invalidate()
            buttonPlay.image = NSImage.init(named: "ic_play")
        }
    }
}
