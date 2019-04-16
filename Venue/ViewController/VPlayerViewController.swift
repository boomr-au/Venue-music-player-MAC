 //
//  VPlayerViewController.swift
//  Venue
//
//  Created by CHITRA on 07/11/18.
//  Copyright © 2018 CHITRA. All rights reserved.
//

import Cocoa
import AVFoundation
import Alamofire
import  CoreAudio
 
class VPlayerViewController: NSViewController {
    var selectedZone:Result?
    var selectedPlayList:Playlists?
    var arrayTracks=[Track]()
    var currentTrack:Track?
    var nextTrack:Track?
    var track1:Track?
    var track2:Track?
    var updateCount = 0
    var updateCountNext = 0
    var nextStartPlay = 0
    var crossfadeStart = false
    var currentPlayerVolumePart:Float = 0.0
    var rootViewController:NSViewController?
    var playData:NSDictionary?
    @IBOutlet weak var popUpOutPutDevices: NSPopUpButton!
    var channelNames = [String]()
   /* var deviceArray: [NSMutableArray] = []
    var devices: AudioObjectID?
    var AOPropertyListenerBlock: AudioObjectPropertyListenerBlock?*/
    // Key-value observing context
    private var playerItemContext = 0

    @IBOutlet var textFieldVolume:NSTextField!
    @IBOutlet var textFieldTime:NSTextField!
    @IBOutlet var textFieldArtist:NSTextField!
    @IBOutlet var textFieldCurrentSong:NSTextField!
    @IBOutlet var textFieldNextSong:NSTextField!
    @IBOutlet var textFieldGain:NSTextField!
    @IBOutlet var textFieldPlayListName:NSTextField!
    @IBOutlet var imageSong:NSImageView!

    @IBOutlet var sliderVolume:NSSlider!
    @IBOutlet var buttonPlay:NSButton!
    @IBOutlet var progressIndicator:NSProgressIndicator!
    
    var timerSong = Timer()
    var currentPlayerQueue:AVQueuePlayer!
    var nextPlayerQueue:AVQueuePlayer?
    var selectedUid = ""
    lazy var playerQueue1 : AVQueuePlayer = {
        return AVQueuePlayer()
    }()
    lazy var playerQueue2 : AVQueuePlayer = {
        return AVQueuePlayer()
    }()
    enum TimeConstant {
        static let secsPerMin = 60
        static let secsPerHour = TimeConstant.secsPerMin * 60
    }
    var player1 = AVPlayer()
    let songs = ["song1","song2","song3","song4","song5","song6","song7","song8","song9"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.getOutputDevices()

        self.progressIndicator.startAnimation(nil)
        self.setSlider()
        self.fetchSong()
        NotificationCenter.default.addObserver(self, selector: #selector(dismissViews), name: Notification.Name("invalidActivationCode"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchForNotification(notification:)), name: Notification.Name("newPlay"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerPlay), name: Notification.Name("player_play"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerPause), name: Notification.Name("player_pause"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(blockSong(sender:)), name: Notification.Name("player_block"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(skipSong(sender:)), name: Notification.Name("player_next"), object: nil)
        // install kAudioHardwarePropertyDevices notification listener
        var theAddress = AudioObjectPropertyAddress()
        theAddress.mSelector = kAudioHardwarePropertyDevices
        theAddress.mScope = kAudioObjectPropertyScopeOutput
        theAddress.mElement = kAudioObjectPropertyElementMaster
     


       // self.listenSocket()
       //preferredContentSize = NSSize(width: 2000, height: 2000)
    }
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    override func viewWillDisappear() {
    }
    
    @IBAction func actionSelectDevice(_ sender: NSPopUpButton) {
       self.selectedUid = (audioDevices[sender.indexOfItem(withTitle: sender.titleOfSelectedItem!)] as! NSDictionary).value(forKey: "uid") as! String
    }
   
    func getOutputDevices(){
        self.popUpOutPutDevices.removeAllItems()

        for dict in audioDevices {
             self.popUpOutPutDevices.addItem(withTitle: (dict as NSDictionary).object(forKey: "name") as! String)
        }
        self.selectedUid = (audioDevices[0] as NSDictionary).value(forKey: "uid") as! String
    }
    private func deallocObservers(player: AVPlayer) {
        self.playerQueue1.removeObserver(self, forKeyPath: "status")
        self.playerQueue2.removeObserver(self, forKeyPath: "status")
    }
    
    func listenSocket(){
        SocketIOManager.sharedInstance.socket.on("new message") { (data, emitter) in
            if let dictValue = data[0] as? NSDictionary{
                let dictString:String? = dictValue.object(forKey: "message") as? String ?? nil
                let jsonData = dictString?.data(using: .utf8)!
                if let dictionary:NSDictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary{
                    if let arrayIds = dictionary["id"] as? NSArray{
                        if(arrayIds.contains(self.selectedZone?.zone_id as Any)){
                            self.fetchForNotification(notification: nil)
                        }
                    }
                }
            }
        }
    }
    @IBAction func settings(sender:NSButton){
        let storyBoard: NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
        let settings = storyBoard.instantiateController(withIdentifier: "VSettingsViewController") as! VSettingsViewController
        settings.selectedZone = selectedZone
        self.presentAsSheet(settings)
    }
    @IBAction func sliderValueChanged(_ sender: NSSlider) {
        let currentValue = Int(sender.doubleValue)
        currentPlayerQueue.volume = Float(currentValue)
        textFieldVolume.stringValue = "\(currentValue)/15"
    }
    @objc func dismissViews(){
        if let current = self.playerQueue1.currentItem{
            self.playerQueue1.remove(current)
        }
        if let current = self.playerQueue2.currentItem{
            self.playerQueue2.remove(current)
        }
        if(ConstantsManager.isPlayerShows == true){
            ConstantsManager.isPlayerShows = false
            self.rootViewController?.dismiss(self)
        }
    }
    @IBAction func dismissView(sender:NSButton){
        ConstantsManager.isPlayerShows = false
        self.rootViewController?.dismiss(self)
    }
    
    @IBAction func skipSong(sender:NSButton){
        if (currentPlayerQueue.currentItem !=  nil && textFieldNextSong.stringValue.count > 0){
            if(currentPlayerQueue == playerQueue1){
                self.track1 = nil
                self.currentTrack = self.track2
            }else{
                self.track2 = nil
                self.currentTrack = self.track1
            }
            self.currentPlayerQueue.pause()
            if let currentItem = self.currentPlayerQueue.currentItem{
                self.currentPlayerQueue.remove(currentItem)
            }
            self.textFieldTime.stringValue = "00:00/00:00"
            self.updateCount = 0
            self.nextStartPlay = 0
            self.currentPlayerQueue = self.nextPlayerQueue
            if(self.buttonPlay.image == NSImage.init(named: "ic_pause")){
                self.selectedUid = (audioDevices[popUpOutPutDevices.indexOfSelectedItem] as NSDictionary).value(forKey: "uid") as! String
                self.currentPlayerQueue.audioOutputDeviceUniqueID = self.selectedUid
                self.currentPlayerQueue?.play()
            }else{
                self.currentPlayerQueue?.pause()
            }
            self.setUpUI()
            self.setReplayGainValue()
        }
    }
    @IBAction func blockSong(sender:NSButton){
        var playListId = ""
        var songId = ""
        if let playlist = selectedPlayList{
            playListId = playlist.playlist_id!
        }
        if let track = currentTrack{
            songId = track.song_id ?? ""
        }
        let dictParams = ["playlist_id":playListId,"song_id":songId as Any,"status":"1"] as [String : Any]
        NetworkManager().postMethodAlamofire(ConstantsManager.blockSong, dictionary: dictParams as NSDictionary) { (success, result, error) in
            self.progressIndicator.stopAnimation(nil)
            if (result as? BlockSong) != nil{
            }
        }
        self.skipSong(sender: sender)
    }
    
    func fetchSong(){
        var playListId = ""
        var p_type = 0
        if let playlist = selectedPlayList{
            playListId = playlist.playlist_id!
            p_type = playlist.is_bucket!
        }
        if let playData = playData{
            playListId = playData["playlist_Id"] as! String
            p_type = playData["p_type"] as! Int
            //p_type = Int(playData["p_type"] as! String)!
        }
        let dictParams = ["playlist_id":playListId,"zone_id":selectedZone?.zone_id as Any,"p_type":p_type] as [String : Any]
        NetworkManager().postMethodAlamofire(ConstantsManager.getNextTrack, dictionary: dictParams as NSDictionary) { (success, result, error) in
            self.progressIndicator.stopAnimation(nil)
            if let nextTrack = result as? NextTrackBase{
                if nextTrack.track != nil{
                    if(self.track1 != nil || self.track2 != nil){
                        self.textFieldNextSong.stringValue = nextTrack.track?.song_title ?? ""
                    }
                    self.setUpPlayers(nextTrack: nextTrack.track!)
                }
            }else if(success == true){
                self.stopPlayer()
            }
        }
    }
    
    func stopPlayer(){
        let dictParams = ["zone_id":selectedZone?.zone_id]
        NetworkManager().postMethodAlamofire(ConstantsManager.stopPlayer, dictionary: dictParams as NSDictionary) { (success, result, error) in
            if let stopPlayerResult = result as? StopPlayer{
                print("\(stopPlayerResult)")
            }
        }
    }
    
    @objc func fetchForNotification(notification:NSNotification?){
        var playListId = ""
        var p_type = 0
        if let userInfo = notification?.userInfo{
            if let playList = userInfo["playList"] as? Playlists{
                if(playList.playlist_id! !=  "0"){
                    playListId = playList.playlist_id!
                    p_type = playList.is_bucket!
                }
            }else if let playData = userInfo["playList"] as? NSDictionary{
                self.playData = playData
                if(playData["playlist_Id"] as! String != "0"){
                    playListId = playData["playlist_Id"] as! String
                    p_type = playData["p_type"] as! Int
                }
            }
        }
        let dictParams = ["playlist_id":playListId,"zone_id":selectedZone?.zone_id as Any,"p_type":p_type] as [String : Any]
        NetworkManager().postMethodAlamofire(ConstantsManager.getNextTrack, dictionary: dictParams as NSDictionary) { (success, result, error) in
            self.progressIndicator.stopAnimation(nil)
            if let nextTrack = result as? NextTrackBase{
                if nextTrack.track != nil{
                    if(self.currentPlayerQueue == self.playerQueue1){
                        self.track2 = nextTrack.track
                        self.playerQueue2 = self.setUpPlayerQueue(audioLink: (self.track2?.song_url!)!,playerQueue: self.playerQueue2)
                        self.nextPlayerQueue = self.playerQueue2
                        self.nextTrack = self.track2
                    }else{
                        self.track1 = nextTrack.track
                        self.playerQueue1 = self.setUpPlayerQueue(audioLink: (self.track1?.song_url!)!,playerQueue: self.playerQueue1)
                        self.nextPlayerQueue = self.playerQueue1
                        self.nextTrack = self.track1
                    }
                    if(self.currentTrack == nil){
                        self.currentPlayerQueue = self.nextPlayerQueue
                        self.currentTrack = self.nextTrack
                        self.play(currentPlayer: self.nextPlayerQueue!)
                        self.setUpUI()
                        self.setReplayGainValue()
                    }
                    self.textFieldNextSong.stringValue = self.nextTrack?.song_title ?? ""
                }
            }
        }
    }
    
    func trackInitialSetUp(nextTrack:Track){
        self.track1 = nextTrack
        self.playerQueue1 = self.setUpPlayerQueue(audioLink: (self.track1?.song_url!)!,playerQueue: playerQueue1)
        
    }
    
    func setUpPlayers(nextTrack:Track){
        if(self.track1 == nil){
            self.track1 = nextTrack
            self.playerQueue1 = self.setUpPlayerQueue(audioLink: (self.track1?.song_url!)!,playerQueue: playerQueue1)
            if(self.currentTrack == nil){
                self.currentPlayerQueue = self.playerQueue1
                self.currentTrack = self.track1
                self.play(currentPlayer: playerQueue1)
                self.setUpUI()
                self.setReplayGainValue()
            }else{
                self.nextPlayerQueue = self.playerQueue1
                self.nextPlayerQueue?.volume = 0
                self.nextTrack = self.track1
            }
        }else{
            self.track2 = nextTrack
            self.playerQueue2 = self.setUpPlayerQueue(audioLink: (self.track2?.song_url!)!,playerQueue: playerQueue2)
            self.nextPlayerQueue = self.playerQueue2
            self.nextPlayerQueue?.volume = 0
            self.nextTrack = self.track2
        }
    }
    
    func checkStatusOfCurrentPlayer(){
        
    }
    
    func UpdateTrack(currentTrack:Track){
        var playStatus = 0
        var previousTrackId = ""
        var duration = ""
        var p_type:Int?
        if(selectedPlayList == nil && playData == nil){
            playStatus = 0
        }else{
            playStatus = 1
            if(selectedPlayList != nil){
                p_type = selectedPlayList?.is_bucket
            }else{
                p_type = playData?["p_type"] as? Int
            }
        }
        if let previousTrackid = UserDefaults.standard.value(forKey: "previousTrackId") as? Int {
            previousTrackId = String(previousTrackid)
            if let durations = UserDefaults.standard.value(forKey: "previousTrackDuration") as? String{
                duration = durations
            }
        }
        let dictParams = ["track_id":currentTrack.song_id ?? "","zone_id":selectedZone?.zone_id ?? "" ,"artist_name":currentTrack.artist_name ?? "","playlist_id":currentTrack.playlist_id ?? "","p_type":p_type ?? "","play_status":playStatus ,"previous_track_id":previousTrackId,"duration":duration] as [String : Any]
        NetworkManager().postMethodAlamofire(ConstantsManager.updateTrack, dictionary: dictParams as NSDictionary) { (success, result, error) in
            if let trackResult = result as? UpdateTrackBase{
                if(trackResult.status == true){
                    if let result = trackResult.result{
                        UserDefaults.standard.set(result.id, forKey: "previousTrackId")
                    }
                    if(self.track1 == nil || self.track2 == nil){
                        self.fetchSong()
                    }
                }
            }else if(error?.localizedDescription == "The Internet connection appears to be offline."){
                self.fetchFromCoreData(track: currentTrack)
            }
        }
    }
    
    func fetchFromCoreData(track:Track){
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tracks")
        fetchRequest.predicate = NSPredicate(format: "playlist_Id == \(track.playlist_id ?? "")")
        do {
            let fetchedSongs = try context.fetch(fetchRequest) as! [NSManagedObject]
            if fetchedSongs.count > 0{
                let currentTrackFromCoredata = fetchedSongs.filter{($0.value(forKey: "trackId") as! String) == track.song_id}
                if (currentTrackFromCoredata.count > 0){
                    var index = fetchedSongs.firstIndex(of: currentTrackFromCoredata.first!)
                    if(index!+1 >= fetchedSongs.count){
                        index = -1
                    }
                        let object = fetchedSongs[index!+1]
                        let nextTrackData = object.value(forKey: "track")
                        let nextTrack:Track = NSKeyedUnarchiver.unarchiveObject(with: nextTrackData as! Data) as! Track
                        if(self.track1 != nil || self.track2 != nil){
                            self.textFieldNextSong.stringValue = nextTrack.song_title ?? ""
                        }
                        self.setUpPlayers(nextTrack: nextTrack)
                }
            }
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    
    func setUpPlayerQueue(audioLink:String,playerQueue:AVQueuePlayer)->AVQueuePlayer{
        if let url = URL(string: audioLink) {
            var playerItem:AVPlayerItem!
            let item = self.checkForOfflineAvailability(audioUrl: url)
            if(item != nil){
                playerItem = item
            }else{
                playerItem = AVPlayerItem.init(url: url)
            }
            if(playerQueue.items().count != 0){
                playerQueue.removeAllItems()
            }
            // Register as an observer of the player item's status property
            playerItem.addObserver(self,
                                   forKeyPath: #keyPath(AVPlayerItem.status),
                                   options: [.old, .new],
                                   context: &playerItemContext)
            //playerQueue.audioOutputDeviceUniqueID
            playerQueue.insert(playerItem, after: nil)
        }
        return playerQueue
    }
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            // Switch over status value
            switch status {
            case .readyToPlay:
                break
            // Player item is ready to play.
            case .failed:
                print("Failed Play")
                let track:Track!
                if(self.currentPlayerQueue.status.rawValue == 1){
                    if(self.currentTrack == track1){
                        track = self.track2
                        self.track2 = nil
                    }else{
                        track = self.track1
                        self.track1 = nil
                    }
                }else{
                    track = self.track1
                    self.track1 = nil
                }
                self.UpdateTrack(currentTrack: track)
                break
            // Player item failed. See error.
            case .unknown:
                break
                // Player item is not yet ready.
            }
        }
    }
    

    
    func checkForOfflineAvailability(audioUrl:URL)->AVPlayerItem?{
        var documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        documentsDirectoryURL.appendPathComponent("Tracks")
        if  FileManager.default.fileExists(atPath: documentsDirectoryURL.path){
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                let playerItem  = AVPlayerItem(asset: AVAsset(url: destinationUrl))
                return playerItem
            }
        }
        return nil
    }
    
    func setReplayGainValue(){
        if(currentTrack != nil){
            let newVolume = getGainVolume(track: currentTrack!)
            self.currentPlayerQueue.volume = Float(newVolume)
            self.sliderVolume.doubleValue = Double(newVolume)
            DispatchQueue.main.async {
                self.textFieldVolume.stringValue = "\(newVolume)/15"
            }
        }
    }
    
    func getGainVolume(track:Track) -> Int {
        if(track.gain != ""){
            let gainText = track.gain?.replacingOccurrences(of: " dB", with: "")
            let gain = Float(gainText ?? "0.0")
            let maxVolume = Float(15.0)
            let percent = Float(0.60 + (gain! * 0.0275))
            return Int(maxVolume * percent)
        }else{
            return (Int(0.60*15))
        }
    }
    
    @IBAction func playAudio(sender:NSButton){
        if(self.currentPlayerQueue.timeControlStatus.rawValue == 2){
            self.playerPause()
        }else{
            self.playerPlay()
        }
    }
    
    @objc func playerPause(){
        if(self.currentPlayerQueue.timeControlStatus.rawValue != 0){
            buttonPlay.image = NSImage.init(named: "ic_play")
            self.currentPlayerQueue.pause()
            self.nextPlayerQueue?.pause()
            self.timerSong.invalidate()
        }
    }
    
    @objc func playerPlay(){
        if(self.currentPlayerQueue.timeControlStatus.rawValue != 2){
            buttonPlay.image = NSImage.init(named: "ic_pause")
            self.play(currentPlayer: currentPlayerQueue)
            if let currentItem = currentPlayerQueue.currentItem{
                let currentTime:Float64 = CMTimeGetSeconds(currentItem.currentTime())
                let duration:Float64 = CMTimeGetSeconds(currentItem.duration)
                if(duration-currentTime < 10){
                    self.selectedUid = (audioDevices[popUpOutPutDevices.indexOfSelectedItem] as NSDictionary).value(forKey: "uid") as! String
                    self.nextPlayerQueue!.audioOutputDeviceUniqueID = self.selectedUid
                    self.nextPlayerQueue?.play()
                }
            }
        }
    }
    
    
    func play(currentPlayer:AVQueuePlayer){
        self.selectedUid = (audioDevices[popUpOutPutDevices.indexOfSelectedItem] as NSDictionary).value(forKey: "uid") as! String
        currentPlayer.audioOutputDeviceUniqueID = self.selectedUid
        currentPlayer.play()
        timerSong = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
        timerSong.fire()
        buttonPlay.image = NSImage.init(named: "ic_pause")
    }
    @objc func updateUI(){
        if let currentItem = currentPlayerQueue.currentItem{
            let currentItem:AVPlayerItem = currentItem
            let duration:Float64 = CMTimeGetSeconds(currentItem.duration)
            let currentTime:Float64 = CMTimeGetSeconds(currentItem.currentTime())
            if(duration > 0.0){
                DispatchQueue.main.async {
                    self.textFieldTime.stringValue = "\(self.formatted(time: currentTime,isHour: false ))/\(self.formatted(time: duration, isHour: false))"
                }
            }
            if(currentTime > 1.0 && self.updateCount == 0){
                self.updateCount += 1
                self.UpdateTrack(currentTrack: self.currentTrack!)
            }
            if(self.updateCount == 1){
                UserDefaults.standard.set(self.formatted(time: currentTime, isHour: true), forKey: "previousTrackDuration")
            }
            if(self.nextStartPlay == 1){
                self.reducingSoundForCurrentPlayer()
                self.improvingSoundForNextPlayer()
            }
            if(currentTime == 1){
                self.nextStartPlay = 0
            }
            if let next = self.nextPlayerQueue{
                if(duration - currentTime < 10.0 && self.nextStartPlay == 0){
                    self.crossfadeStart = true
                    self.nextStartPlay += 1
                    self.updateCountNext = 0
                    self.selectedUid = (audioDevices[popUpOutPutDevices.indexOfSelectedItem] as NSDictionary).value(forKey: "uid") as! String
                    next.audioOutputDeviceUniqueID = self.selectedUid
                    next.play()
//                    if let nextItem = next.currentItem{
//                        let nextCurrentTime:Float64 = CMTimeGetSeconds(nextItem.currentTime())
//                        if(nextCurrentTime > 1.0 && updateCountNext == 0){
//                            self.updateCountNext += 1
//                            if(self.nextPlayerQueue == playerQueue2){
//                                self.UpdateTrack(currentTrack: track2!)
//                            }else{
//                                self.UpdateTrack(currentTrack: track1!)
//                            }
//                        }
//                    }
                }
            }
        }else{
            self.nextStartPlay = 0
            self.updateCount = 0
            if(currentPlayerQueue == playerQueue1 && self.track2 != nil){
                self.currentPlayerQueue.pause()
                self.track1 = nil
                self.currentTrack = self.track2
                self.currentPlayerQueue = playerQueue2
                //self.play(currentPlayer: self.currentPlayerQueue)
                self.setUpUI()
                self.setReplayGainValue()
            }else if(currentPlayerQueue == playerQueue2 && self.track1 != nil){
                self.currentPlayerQueue.pause()
                self.track2 = nil
                self.currentTrack = self.track1
                self.currentPlayerQueue = playerQueue1
                // self.play(currentPlayer: self.currentPlayerQueue)
                self.setUpUI()
                self.setReplayGainValue()
            }else{
                self.track1 = nil
                self.track2 = nil
                self.currentTrack = nil
            }
            
        }
    }
    func reducingSoundForCurrentPlayer(){
        if(crossfadeStart == true){
            self.crossfadeStart = false
            currentPlayerVolumePart = self.currentPlayerQueue.volume/9
        }
        if(self.currentPlayerQueue.volume > 0){
            self.currentPlayerQueue.volume -= currentPlayerVolumePart
        }
    }
    func improvingSoundForNextPlayer(){
        let gain = Float(self.getGainVolume(track: self.nextTrack!))
        let value:Float = Float(gain/9.0)
        if((self.nextPlayerQueue?.volume )! < gain){
            self.nextPlayerQueue?.volume += value
        }
    }
    func setSlider(){
        sliderVolume.minValue = 0.0
        sliderVolume.maxValue = 15.0
        sliderVolume.doubleValue = 5.0
    }
    func setUpUI(){
        DispatchQueue.main.async {
            self.textFieldNextSong.stringValue = ""
            self.textFieldPlayListName.stringValue = self.currentTrack?.playlist_name ?? ""
            self.textFieldCurrentSong.stringValue = self.currentTrack?.song_title ?? ""
            self.textFieldArtist.stringValue = self.currentTrack?.artist_name ?? ""
            self.textFieldGain.stringValue = self.currentTrack?.gain ?? ""
        }
        self.imageSong.image = NSImage.init(named: "albm_art")
        self.currentPlayingSongArtWork()
        self.emitCurrentPlaying()
    }
    func emitCurrentPlaying(){
        SocketIOManager.sharedInstance.socket.on("current_playing") { (data, ack) in
            
        }
        SocketIOManager.sharedInstance.socket.emit("new message",["current_playing": ["zone_id": selectedZone?.zone_id ?? "","playlist_name": self.currentTrack?.playlist_name,"song_name": self.currentTrack?.song_title]])
    }
    
    
    
    func currentPlayingSongArtWork() {
        var searchQuery = String()
        if let artistName =  currentTrack?.artist_name {
            searchQuery = artistName+" "
        }
        if let trackName = currentTrack?.song_title {
            searchQuery = searchQuery+trackName
        }
        request("https://itunes.apple.com/search?term="+getSongNameRemovedSpecialCharacter(string: searchQuery)+"&limit=1", method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
            if let result = response.result.value as? NSDictionary {
                if let array = result["results"] as? NSArray {
                    if array.count > 0 {
                        if let urlString = (array[0] as! NSDictionary)["artworkUrl100"] as? String {
                            let imageUrl = urlString.replacingOccurrences(of: "100x100", with: "500x500")
                            self.imageSong.load(url: URL.init(string: imageUrl)!)
                        }
                    }
                }
            }else {
                
            }
        }
    }
    
    func getSongNameRemovedSpecialCharacter(string: String) -> String {
        var res = String()
        var count = 0
        for c in string {
            switch c {
            case "(": count+=1; break;
            case ")": count-=1; break;
            default:
                if count == 0 {res += String(c)}
                break;
            }
        }
        return res.replacingOccurrences(of: " ", with: "+")
    }
    func formatted(time: Float64,isHour:Bool) -> String {
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
        }else if(isHour == true){
            formattedString = "00:"
        }
        formattedString += "\(String(format: "%02d", mins)):\(String(format: "%02d", secs))"
        return formattedString
    }
}

extension NSImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = NSImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
