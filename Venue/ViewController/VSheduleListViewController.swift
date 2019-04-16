//
//  VSheduleListViewController.swift
//  Venue
//
//  Created by CHITRA on 05/11/18.
//  Copyright © 2018 CHITRA. All rights reserved.
//

import Cocoa

class VSheduleListViewController: NSViewController,NSTableViewDelegate,NSTableViewDataSource,ScheduleCellDelegate {
    var selectedZone:Result?
    var arrayPlayList = [Playlists]()
    var arraySongs = [Track]()

    @IBOutlet var tableView:NSTableView!
    @IBOutlet var buttonPlayList:NSButton!
    @IBOutlet var buttonSchedule:NSButton!
    @IBOutlet var buttonNextSchedule:NSButton!
    @IBOutlet var textfieldPlayList:NSTextField!
    @IBOutlet var textfieldSchedule:NSTextField!
    @IBOutlet var textfieldOfflineCount:NSTextField!
    @IBOutlet var progressIndicator:NSProgressIndicator!
    var playerViewController:VPlayerViewController?
    var selectedRow:Int?
    var isPlayList:Bool?
    var playlistBase:PlaylistBase?
    var timerSong:Timer!
    var currentPlayList:Playlists?
    var socketTriggerStatus = false
    var socketTriggerForManualPlayList = false
    var offset = 0
    var availableSongCount = 0
    var trackSongCount = 0
    var isDownLoad = false

    override func viewDidLoad() {
        super.viewDidLoad()
        textfieldPlayList.backgroundColor = NSColor.black
        textfieldSchedule.backgroundColor = NSColor.lightGray
        isPlayList = true
        progressIndicator.startAnimation(nil)
        self.fetchSong()
        self.triggerTimerForRefresh()
        self.triggerTimer()
        self.listenSocket()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
    }
    
  
    func fetchSong(){
        let dictParams = ["playlist_id":"","zone_id":selectedZone?.zone_id as Any,"p_type":""] as [String : Any]
        NetworkManager().postMethodAlamofire(ConstantsManager.getNextTrack, dictionary: dictParams as NSDictionary) { (success, result, error) in
            if let nextTrack = result as? NextTrackBase{
                if nextTrack.track != nil{
                    self.showPlay(selectedPlayList: nil, playData: nil)
                }
            }
            
        } 
    }
    
    func listenSocket(){
        SocketIOManager.sharedInstance.socket.on("new message") { (data, emitter) in
            print("message triggered :\(data)")
            if let dictValue = data[0] as? NSDictionary{
                if let dictString = dictValue.object(forKey: "message") as? String {
                    self.socketForSchedule(dictString: dictString)
                }else if let dictData = dictValue.object(forKey: "message") as? NSDictionary {
                    if let zone_id = dictData.object(forKey: "zone_id"){
                        if (String(describing: zone_id) == self.selectedZone?.zone_id){
                            if let playId = dictData.object(forKey: "playlist_id"){
                                var p_type:Int!
                                if (dictData.object(forKey: "playlist_id") as? Int) != nil{
                                    p_type = dictData.object(forKey: "playlist_type") as? Int
                                }else{
                                    p_type = Int(dictData.object(forKey: "playlist_type") as! String)
                                }
                                self.socketForManualPlayList(playlist_Id: String(describing: playId), p_type:p_type)
                            }
                           // if(ConstantsManager.isPlayerShows == true){
                                if let play_status = dictData.object(forKey: "play_status"){
                                    self.socketForPlayPause(play_status:String(describing: play_status) )
                                }else if (dictData.object(forKey: "next_status")) != nil{
                                    NotificationCenter.default.post(name: NSNotification.Name("player_next"), object: nil, userInfo:nil)
                                }else if (dictData.object(forKey: "block_status")) != nil{
                                    NotificationCenter.default.post(name: NSNotification.Name("player_block"), object: nil, userInfo:nil)
                                }
                           // }
                        }
                    }
                }
            }
        }
    }
    
    func socketForManualPlayList(playlist_Id:String,p_type:Int){
        if(ConstantsManager.isPlayerShows == true){
            self.playerViewController?.selectedPlayList = nil
            NotificationCenter.default.post(name: NSNotification.Name("newPlay"), object: nil, userInfo: ["playList":["playlist_Id":playlist_Id,"p_type":p_type]])
        }else{
            //self.socketTriggerStatus = true
            self.showPlay(selectedPlayList:nil,playData: ["playlist_Id":playlist_Id,"p_type":p_type])
        }
    }
    
    func socketForPlayPause(play_status:String){
        if(play_status == "0"){
            NotificationCenter.default.post(name: NSNotification.Name("player_play"), object: nil, userInfo:nil)
        }else{
            NotificationCenter.default.post(name: NSNotification.Name("player_pause"), object: nil, userInfo:nil)
        }
    }
    
    func socketForSchedule(dictString:String){
        let jsonData = dictString.data(using: .utf8)!
        if let dictionary:NSDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary{
            if let arrayIds = dictionary["id"] as? NSArray{
                if(arrayIds.contains(self.selectedZone?.zone_id as Any)){
                    if(ConstantsManager.isPlayerShows == true){
                        self.playerViewController?.selectedPlayList = nil
                        NotificationCenter.default.post(name: NSNotification.Name("newPlay"), object: nil, userInfo:nil)
                    }else{
                        self.socketTriggerStatus = true
                        self.showPlay(selectedPlayList:nil, playData: nil)
                    }
                }
            }
        }
    }
    func triggerTimer(){
        timerSong = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkActivation), userInfo: nil, repeats: true)
        timerSong.fire()
    }
    func triggerTimerForRefresh(){
        self.offset = 0
        let timerRefresh = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(fetchPLayList), userInfo: nil, repeats: true)
        timerRefresh.fire()
    }
    @objc func fetchPLayList(){
        self.buttonNextSchedule.title = ""
        textfieldPlayList.backgroundColor = NSColor.black
        textfieldSchedule.backgroundColor = NSColor.lightGray
        let dictParams = ["zone_id":selectedZone?.zone_id as Any,"offset":offset] as [String : Any]
        NetworkManager().postMethodAlamofire(ConstantsManager.playlistURL, dictionary: dictParams as NSDictionary) { (success, result, error) in
            self.progressIndicator.stopAnimation(nil)
            if let playListBase = result as? PlaylistBase{
                if((playListBase.result?.playlists?.count)! > 0){
                    self.playlistBase = playListBase
                    if(self.offset == 0){
                        self.selectedRow = nil
                        self.arrayPlayList.removeAll()
                    }
                    self.arrayPlayList.append(contentsOf:self.playlistBase!.result?.playlists ?? [Playlists]())
                    self.tableView.reloadData()
                    self.setNextScheduleTime()
                    self.arraySongs = self.arrayPlayList.map { (playList) -> [Track] in
                        return playList.songs!
                        }.flatMap{$0}
                    self.offset += 1
                    self.fetchPLayList()
                    if(self.offset == 1 ){
                    }
                }else{
                    self.offset = 0
                    self.availableSongCount = 0
                    if(self.isDownLoad == false){self.downLoadAudio()}
                }
            }
        }
    }
    
    func downLoadAudio(){
        if trackSongCount < arraySongs.count{
            self.isDownLoad = true
           let nextSong = arraySongs[trackSongCount]
            self.downloadWith(url: nextSong.song_url ?? "",track:nextSong) { (success, response, error) in
                if(success == true){
                    self.availableSongCount += 1
                }
                DispatchQueue.main.async {
                     self.textfieldOfflineCount.stringValue = "Offline Available: \(self.availableSongCount)/\(self.arraySongs.count)"
                }
                self.trackSongCount += 1
                self.downLoadAudio()
            }
        }else{
            self.isDownLoad = false
            self.trackSongCount = 0
           //
        }
    }
   
    func downloadWith(url:String, track:Track,completionblock:@escaping(Bool?,AnyObject?,Error?)->Void){
        if let audioUrl = URL(string: url) {
            
            // then lets create your document folder url
            var documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            documentsDirectoryURL.appendPathComponent("Tracks")
            if  !FileManager.default.fileExists(atPath: documentsDirectoryURL.path){
                do {
                    try FileManager.default.createDirectory(atPath: documentsDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    NSLog("Couldn't create document directory")
                }
            }
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                completionblock(true,nil,nil)
            } else {
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else {
                        completionblock(false,nil,error)
                        return
                    }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        completionblock(true,response,nil)
                        self.saveToCoredata(audioUrl: audioUrl, track: track)
                        print("File moved to documents folder")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        completionblock(false,nil,error)
                    }
                }).resume()
            }
        }
    }
    
    func saveToCoredata(audioUrl:URL,track:Track){
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Tracks", in: context)
        let newTrack = NSManagedObject(entity: entity!, insertInto: context)
        newTrack.setValue(track.song_id, forKey: "trackId")
        newTrack.setValue(track.playlist_id, forKey: "playlist_Id")
        newTrack.setValue(audioUrl.lastPathComponent, forKey: "trackUrl")
        let saveTrack = NSKeyedArchiver.archivedData(withRootObject: track)
        newTrack.setValue(saveTrack, forKey: "track")
        do {
            try context.save()
            print("save successful")
        } catch {
            print("saving error")
        }
    }
    
    @objc func checkActivation(){
        if let activationCode = UserDefaults.standard.value(forKey: "activationCode"){
            let storyboard = NSStoryboard.init(name: "Main", bundle: nil)
            let dictParams = ["activation_code":activationCode]
            NetworkManager().postMethodAlamofire(ConstantsManager.checkActivationCode, dictionary: dictParams as NSDictionary) { (success, result, error) in
                if let activationCode = result as? CheckActivationCode{
                    if(activationCode.status != true){
                        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                        let vzone = storyboard.instantiateController(withIdentifier: "VZoneActivationViewController") as! VZoneActivationViewController
                       //self.view.window?.contentViewController = vzone

                       // NSApplication.shared.keyWindow?.contentViewController = vzone
                        let selectedIndex = ZoneTabs.shared.selectedTabViewItemIndex

                        let newItem: NSTabViewItem = NSTabViewItem(identifier: "\(selectedIndex)")
                        newItem.label = "Zone \(selectedIndex + 1)"
                        // "tvcontroller" is in storyboard
                        newItem.viewController = vzone
                        let tabItem = ZoneTabs.shared.tabViewItems[selectedIndex]
                        ZoneTabs.shared.removeTabViewItem(tabItem)
                        ZoneTabs.shared.insertTabViewItem(newItem, at: selectedIndex)
                        ZoneTabs.shared.selectedTabViewItemIndex = selectedIndex
                    }
                }else if(error?.localizedDescription == "Invalid Activation Code"){
                    NotificationCenter.default.post(name: Notification.Name("invalidActivationCode"), object: nil)
                   self.timerSong.invalidate()
                    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                    let vzone = storyboard.instantiateController(withIdentifier: "VZoneActivationViewController") as! VZoneActivationViewController
                    //self.present(vzone, animator: ReplacePresentationAnimator())
                   // self.presentAsModalWindow(vzone)
                    let selectedIndex = ZoneTabs.shared.selectedTabViewItemIndex

                    let newItem: NSTabViewItem = NSTabViewItem(identifier: "\(selectedIndex)")
                    newItem.label = "Zone \(selectedIndex + 1)"
                    // "tvcontroller" is in storyboard
                    newItem.viewController = vzone
                    let tabItem = ZoneTabs.shared.tabViewItems[selectedIndex]
                    ZoneTabs.shared.removeTabViewItem(tabItem)
                    ZoneTabs.shared.insertTabViewItem(newItem, at: selectedIndex)
                    ZoneTabs.shared.selectedTabViewItemIndex = selectedIndex

                }
            }
        }
    }
    func updatePlayList(){
        let dictParams = ["zone_id":selectedZone?.zone_id,"offset":"0"]
        NetworkManager().postMethodAlamofire(ConstantsManager.playlistURL, dictionary: dictParams as NSDictionary) { (success, result, error) in
            self.progressIndicator.stopAnimation(nil)
            if let playListBase = result as? PlaylistBase{
                self.playlistBase = playListBase
                self.arrayPlayList = self.playlistBase!.result?.playlists ?? [Playlists]()
                self.tableView.reloadData()
                self.arraySongs = self.arrayPlayList.map { (playList) -> [Track] in
                    return playList.songs!
                    }.flatMap{$0}
            }
        }
        
    }
    func setNextScheduleTime(){
        var nextPlayList:Playlists?
        if(arrayPlayList.count>0){
            for (_,playListNew) in arrayPlayList.enumerated(){
                let interval = playListNew.intervalFromNow()
                if(interval>0 ){
                    if(nextPlayList == nil){
                        nextPlayList=playListNew
                    }else{
                        let timeIntervalNext = nextPlayList?.intervalFromNow()
                        if(interval < timeIntervalNext!){
                            nextPlayList = playListNew
                        }
                    }
                }
            }
            buttonNextSchedule.title = (nextPlayList != nil) ? "Next Schedule will start at "+"\(nextPlayList?.start_time! ?? "")" : ""
        }
    }
        
    @IBAction func refresh(sender:NSButton){
        self.offset = 0
        progressIndicator.startAnimation(nil)
        self.fetchPLayList()
    }
    
    @IBAction func activateButton(sender:NSButton){
        selectedRow = nil
        if(sender == buttonPlayList){
            isPlayList = true
            textfieldPlayList.backgroundColor = NSColor.black
            textfieldSchedule.backgroundColor = NSColor.lightGray
        }else{
            isPlayList = false
            textfieldPlayList.backgroundColor = NSColor.lightGray
            textfieldSchedule.backgroundColor = NSColor.black
        }
        self.tableView.reloadData()
    }
    @IBAction func showPLayer(sender:NSButton){
       self.showPlay(selectedPlayList: self.currentPlayList,playData: nil)
    }
    @IBAction func settings(sender:NSButton){
        let storyBoard: NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
        let settings = storyBoard.instantiateController(withIdentifier: "VSettingsViewController") as! VSettingsViewController
        settings.selectedZone = selectedZone
        self.presentAsSheet(settings)
    }
    func showManualPlay(sender: NSButton) {
        let playList = arrayPlayList[sender.tag]
        self.currentPlayList = playList
        self.showPlay(selectedPlayList: playList,playData: nil)
    }
    
    func showPlay(selectedPlayList:Playlists?,playData:NSDictionary?){
        if(playerViewController == nil){
            let storyBoard: NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
            playerViewController = (storyBoard.instantiateController(withIdentifier: "VPlayerViewController") as? VPlayerViewController)
            if(playData != nil){
                playerViewController?.playData = playData
            }
        }else{
            if(socketTriggerStatus == true){
                socketTriggerStatus = false
                 NotificationCenter.default.post(name: NSNotification.Name("newPlay"), object: nil, userInfo:nil)
            }else if(playerViewController?.selectedPlayList?.playlist_id == nil || playerViewController?.selectedPlayList?.playlist_id != selectedPlayList?.playlist_id){
                if let playList = selectedPlayList{
                    NotificationCenter.default.post(name: NSNotification.Name("newPlay"), object: nil, userInfo:  ["playList":playList])
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name("newPlay"), object: nil, userInfo: ["playList":playData as Any])
                }
            }
        }
        ConstantsManager.isPlayerShows = true
        playerViewController?.selectedPlayList = selectedPlayList
        playerViewController?.selectedZone = selectedZone
      //  self.presentAsModalWindow(playerViewController!)

        
        let selectedIndex = ZoneTabs.shared.selectedTabViewItemIndex

        let newItem: NSTabViewItem = NSTabViewItem(identifier: "\(selectedIndex)")
        newItem.label = "Zone \(selectedIndex + 1)"
        // "tvcontroller" is in storyboard
        newItem.viewController = playerViewController
        let tabItem = ZoneTabs.shared.tabViewItems[selectedIndex]
        ZoneTabs.shared.removeTabViewItem(tabItem)
        ZoneTabs.shared.insertTabViewItem(newItem, at: selectedIndex)
        ZoneTabs.shared.selectedTabViewItemIndex = selectedIndex
    }
    
    func configureCellSchedule(index:Int)->SchedulePlayListCell?{
        let playList:Playlists = arrayPlayList[index]
        let cellIdentifier: String = "CellPlaylist"
        if let cell:SchedulePlayListCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(cellIdentifier), owner: nil) as? SchedulePlayListCell {
            cell.labelBackground.backgroundColor = NSColor.init(hexString: playList.playlist_color ?? "")
            cell.labelScheduleName.stringValue = playList.playlist_name ?? ""
            cell.labelSongCount.stringValue = "\(playList.songs?.count ?? 0) Songs"
            cell.scheduleDelegate = self
            cell.buttonPlay.tag = index
            return cell
        }
        return nil
    }
    func configureCellSong(index:Int)->SongPlayListCell?{
        let playList:Playlists = arrayPlayList[selectedRow!]
        let song:Track = playList.songs![index]
        let cellIdentifier: String = "CellSongList"
        if let cell:SongPlayListCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(cellIdentifier), owner: nil) as? SongPlayListCell {
            cell.labelSongName.stringValue = song.song_title!
            cell.labelAuthorName.stringValue = song.artist_name!
            return cell
        }
        return nil
    }
    func configureCellScheduleForSchedule(index:Int)->SchedulePlayListCell?{
        let cellIdentifier: String = "CellPlaylist"
        if let cell:SchedulePlayListCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(cellIdentifier), owner: nil) as? SchedulePlayListCell {
            cell.labelBackground.backgroundColor = NSColor.init(hexString: playlistBase?.result?.schedule_color ?? "")
            cell.labelScheduleName.stringValue = playlistBase?.result?.schedule_name ?? ""
            cell.labelSongCount.stringValue = "\(arraySongs.count) Songs"
            return cell
        }
        return nil
    }
    func configureCellSongForSchedule(index:Int)->SongPlayListCell?{
        let song:Track = arraySongs[index]
        let cellIdentifier: String = "CellSongList"
        if let cell:SongPlayListCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(cellIdentifier), owner: nil) as? SongPlayListCell {
            cell.labelSongName.stringValue = song.song_title!
            cell.labelAuthorName.stringValue = song.artist_name!
            return cell
        }
        return nil
    }
    //MARK:- TableView Delegates
    func numberOfRows(in tableView: NSTableView) -> Int {
        if(isPlayList == true){
            if(selectedRow != nil){
                let playList = arrayPlayList[selectedRow!]
                return arrayPlayList.count + (playList.songs?.count)!
            }else{
                return arrayPlayList.count
            }
        }else{
            if(selectedRow != nil){
               
                return 1+arraySongs.count
            }else{
                return 1
            }
        }
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if(isPlayList == true){
            if let selected = selectedRow {
                let selectedPlayList:Playlists = arrayPlayList[selected]
                let songCount:Int = selectedPlayList.songs?.count ?? 0
                if(selected >= row){
                    return arrayPlayList[row]
                }else if(selected < row && songCount+selected >= row){
                    return selectedPlayList.songs![row-(selected+1)]
                }else{
                    return arrayPlayList[row-songCount]
                }
            }else{
                return arrayPlayList[row]
            }
        }else{
            if(selectedRow != nil){
                if(row == 0){
                    return playlistBase
                }else{
                    return arraySongs[row-1]
                }
            }else{
                return playlistBase
            }
        }
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if(isPlayList == true){
            if let selected = selectedRow {
                let selectedPlayList:Playlists = arrayPlayList[selected]
                let songCount:Int = selectedPlayList.songs?.count ?? 0
                if(selected >= row){
                    return configureCellSchedule(index: row)
                }else if(selected < row && songCount+selected >= row){
                    return configureCellSong(index: row-(selected+1))
                }else{
                    return configureCellSchedule(index: row-songCount)
                }
            }else{
                return configureCellSchedule(index: row)
            }
        }else{
             if(selectedRow != nil) {
                if(row == 0){
                    return configureCellScheduleForSchedule(index: 0)

                }else{
                    return configureCellSongForSchedule(index: row-1)
                }
             }else{
                return configureCellScheduleForSchedule(index: 0)
            }
        }
    }
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        if(isPlayList == true){
            if let selected = selectedRow {
                let selectedPlayList:Playlists = arrayPlayList[selected]
                let songCount:Int = selectedPlayList.songs?.count ?? 0
                if(selected == row){
                    selectedRow = nil
                }else if(selected > row){
                    selectedRow = row
                }else if(songCount+selected <= row){
                    selectedRow = row-songCount
                }
            }else{
                selectedRow = row
            }
        }else{
            if let selected = selectedRow {
                if(selected == row){
                    selectedRow = nil
                }
            }else{
                selectedRow = row
            }
        }
        self.tableView.reloadData()
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if(isPlayList == true){
            if let selected = selectedRow {
                let selectedPlayList:Playlists = arrayPlayList[selected]
                let songCount:Int = selectedPlayList.songs?.count ?? 0
                if(selected == row){
                    return 180.0
                }else if(selected < row && songCount+selected >= row){
                    return 45.0
                }else{
                    return 135.0
                }
            }else{
                return 135.0
            }
        }else{
            if(row == 0){
                return 135.0
            }else{
                return 45.0
            }
        }
    }
    func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
        print("row \(row)")
        
    }
    @objc func scrollViewDidScroll(_ scrollView: NSScrollView) {
        print("vertical Scroller value \(scrollView.verticalScroller?.floatValue)")
        if (scrollView.verticalScroller?.floatValue.isEqual(to: 1.0))!{
            
        }

    }
    
}

extension NSColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
extension Playlists{
    func intervalFromNow()->TimeInterval{
        let startDate = self.start_time!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: startDate)
        let interval = date!.timeIntervalSince(Date())
        return interval
    }
}
