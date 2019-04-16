//
//  SettingVC.swift
//  Venue
//
//  Created by SrishtiInnovaitve on 29/03/19.
//  Copyright © 2019 CHITRA. All rights reserved.
//

import Cocoa
import AVFoundation
import  CoreAudio
var selectedDevice = [NSDictionary]()
class SettingVC: NSViewController {
    @IBOutlet var popUp:NSPopUpButton!
    var popUpString = [String]()
    var player1 = AVPlayer()
    let songs = ["song1","song2","song3","song4","song5","song6","song7","song8","song9"]
    var selectedUid = ""
    @IBOutlet weak var songspop: NSPopUpButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Populate the cell from saved device information.
        for dict in audioDevices {
            popUpString.append((dict as NSDictionary).object(forKey: "name") as! String)
        }
       popUp.removeAllItems()
       popUp.addItems(withTitles: popUpString)
        songspop.removeAllItems()
        songspop.addItems(withTitles: songs)
        
    }
    
    @IBAction func Songs(_ sender: NSPopUpButton) {
        if popUp.itemTitles.count == 0 {
            for dict in audioDevices {
                popUpString.append((dict as NSDictionary).object(forKey: "name") as! String)
            }
            popUp.removeAllItems()
            popUp.addItems(withTitles: popUpString)
        }
        playerSong(song: sender.indexOfSelectedItem, Uid: selectedUid)
        
    }
    
    @IBAction func PopUpAction(_ sender: Any) {
      self.selectedUid = (audioDevices[popUp.indexOfSelectedItem] as NSDictionary).value(forKey: "uid") as! String
        playerSong(song:0, Uid: selectedUid)
    }
    func playerSong(song :Int,Uid :String){
        guard let audioFileURL = Bundle.main.url(forResource: songs[song], withExtension: "mp3") else {
            fatalError("audio file is not in bundle.")
        }
        let item =  AVPlayerItem(url: audioFileURL)
        player1 = AVPlayer(playerItem: item)
        player1.audioOutputDeviceUniqueID = Uid
        player1.volume = 1.0
        player1.play()
        
    }
    
    
    //MARK:- TableView Delegates
   
}
