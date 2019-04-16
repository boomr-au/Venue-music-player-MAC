//
//  loopBackViewController.swift
//  Venue
//
//  Created by SrishtiInnovaitve on 27/02/19.
//  Copyright © 2019 CHITRA. All rights reserved.
//
/*
import Cocoa
import AVFoundation
import AVKit
import AudioToolbox

func AOPropertyListenerProc(_ objectID: AudioObjectID, _ addressCount: UInt32, _ addresses: UnsafePointer<AudioObjectPropertyAddress>, _ clientData: UnsafeMutableRawPointer?) -> OSStatus {
    
    let winController = clientData!.assumingMemoryBound(to: loopBackViewController.self).pointee
    let properties = UnsafeBufferPointer(start: addresses, count: Int(addressCount))
    
    for property in properties {
        
        switch property.mSelector {
            
            /*
             These are the other types of notifications we might receive:
             
             case kAudioHardwarePropertyDefaultInputDevice:
             break;
             
             case kAudioHardwarePropertyDefaultOutputDevice:
             break;
             
             case kAudioHardwarePropertyDefaultSystemOutputDevice:
             break;
             */
            
        case kAudioHardwarePropertyDevices:
            DispatchQueue.main.async {
                winController.updateDeviceList()
            }
            
        default:
            break
        }
    }
    
    return noErr
}

enum AudioObjectProperty {
    
    case devices, deviceName, deviceUID, inputStream, outputStream
    
    var propertyAddress: AudioObjectPropertyAddress {
        
        switch self {
            
        case .devices:
            return AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices,
                                              mScope: kAudioObjectPropertyScopeGlobal,
                                              mElement: kAudioObjectPropertyElementMaster)
            
        case .deviceName:
            return AudioObjectPropertyAddress(mSelector: kAudioObjectPropertyName,
                                              mScope: kAudioObjectPropertyScopeGlobal,
                                              mElement: kAudioObjectPropertyElementMaster)
            
        case .deviceUID:
            return AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyDeviceUID,
                                              mScope: kAudioObjectPropertyScopeGlobal,
                                              mElement: kAudioObjectPropertyElementMaster)
            
        case .inputStream:
            return AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreamConfiguration,
                                              mScope: kAudioObjectPropertyScopeInput,
                                              mElement: 0)
            
        case .outputStream:
            return AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreamConfiguration,
                                              mScope: kAudioObjectPropertyScopeOutput,
                                              mElement: 0)
        }
    }
}
class loopBackViewController: NSViewController {
    static var shared: loopBackViewController!
    @IBOutlet weak var audioDeviceTableView: NSTableView!

    // Currently-known audio devices.
    
    var audioDevices: [[String: String]] = []
    var player = AVPlayer()
    var player1 = AVPlayer()
    var player2 = AVPlayer()
    var player3 = AVPlayer()
    var player4 = AVPlayer()
    var player5 = AVPlayer()
    var player6 = AVPlayer()
    var player7 = AVPlayer()
    var player8 = AVPlayer()
    var player9 = AVPlayer()

    // Audio object ID for the system object.
    
    let audioSystemID = Int(kAudioObjectSystemObject)
    
    // Set up the window initially.
    let songs = ["song1","song2","song3","song4","song5","song6","song7","song8","song9"]
    override func viewDidLoad() {
        super.viewDidLoad()
        loopBackViewController.shared = self
        
        // Generate initial device list.
        
        updateDeviceList()
        
        // Install the listener for device notifications.
        
        addPropertyListener(for: .devices, deviceID: audioSystemID)
        
    }
    override func viewWillDisappear() {
        // Remove the listener for device notifications.
        
        removePropertyListener(for: .devices, deviceID: audioSystemID)
    }
    
    // Get an array of audio output device IDs.
    
    func audioDeviceIDs() throws -> [Int] {
        
        let dataSize = try audioPropertyDataSize(for: .devices, deviceID: audioSystemID)
        
        // Populate an array with device IDs.
        
        let deviceCount = Int (dataSize) / MemoryLayout<AudioObjectID>.size
        let ptr = try audioPropertyData(for: .devices, deviceID: audioSystemID, type: AudioObjectID.self, size: dataSize)
        let devices = UnsafeMutableBufferPointer(start: ptr, count: deviceCount)
        
        return devices.map { Int($0) }
    }
    
    // Update the list of audio output devices.
    
    func updateDeviceList() {
        
        // Get an array of all the audio output devices.
        
        let deviceIDs: [Int]
        
        do {
            deviceIDs = try audioDeviceIDs()
        }
        catch {
            print("Device IDs error: \(error)")
            return
        }
        
        // Iterate over each device gathering information.
        
        var devices = [[String: String]]()
        
        for deviceID in deviceIDs {
            
            let deviceName: String
            
            do {
                deviceName = try audioPropertyString(for: .deviceName, deviceID: deviceID)
            }
            catch {
                print("Device name error: \(error)")
                deviceName = "error"
            }
            
            let uniqueName: String
            
            do {
                uniqueName = try audioPropertyString(for: .deviceUID, deviceID: deviceID)
            }
            catch {
                print("Device UID error: \(error)")
                uniqueName = "error"
            }
            
            let inputChannelCount: Int
            
            do {
                inputChannelCount = try audioPropertyChannelCount(for: .inputStream, deviceID: deviceID)
            }
            catch {
                print("Input channel error: \(error)")
                inputChannelCount = 0
            }
            
            let outputChannelCount: Int
            
            do {
                outputChannelCount = try audioPropertyChannelCount(for: .outputStream, deviceID: deviceID)
            }
            catch {
                print("Output channel error: \(error)")
                outputChannelCount = 0
            }
            if outputChannelCount > 0 {
            devices.append(["id": String(deviceID),
                            "name": deviceName,
                            "uid": uniqueName,
                            "ich": String(inputChannelCount),
                            "och": String(outputChannelCount)])
            }
        }
        
        audioDevices = devices
        audioDeviceTableView.reloadData()
    }
    

}

// This extension contains the table view protocol conformance methods.

extension loopBackViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    // Data source method: number of rows.
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return audioDevices.count
    }
    
    // Delegate method: the cell view for a specified row.
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        // Ignore requests for a row view.
        
        guard let identifier = tableColumn?.identifier else { return nil }
        
        // Populate the cell from saved device information.
        
        let cell = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
        cell.textField?.stringValue = audioDevices [row] [identifier.rawValue]!
        
        return cell
    }
    func tableViewSelectionDidChange(_ notification: Notification) {
        let table = notification.object as! NSTableView
        print(table.selectedRow)
       

        guard let audioFileURL = Bundle.main.url(forResource: songs[table.selectedRow], withExtension: "mp3") else {
            fatalError("audio file is not in bundle.")
        }
        if table.selectedRow == 0
        {
        let item =  AVPlayerItem(url: audioFileURL)
        player = AVPlayer(playerItem: item)
        player.audioOutputDeviceUniqueID = ((audioDevices [table.selectedRow] as NSDictionary).object(forKey: "uid") as! String)
        player.volume = 1.0
        player.play()
        }
        else if table.selectedRow == 1 {
            let item =  AVPlayerItem(url: audioFileURL)
            player1 = AVPlayer(playerItem: item)
            player1.audioOutputDeviceUniqueID = ((audioDevices [table.selectedRow] as NSDictionary).object(forKey: "uid") as! String)
            player1.volume = 1.0
            player1.play()
        }
        else if table.selectedRow == 2 {
            let item =  AVPlayerItem(url: audioFileURL)
            player2 = AVPlayer(playerItem: item)
            player2.audioOutputDeviceUniqueID = ((audioDevices [table.selectedRow] as NSDictionary).object(forKey: "uid") as! String)
            player2.volume = 1.0
            player2.play()
        }
        else if table.selectedRow == 3 {
            let item =  AVPlayerItem(url: audioFileURL)
            player3 = AVPlayer(playerItem: item)
            player3.audioOutputDeviceUniqueID = ((audioDevices [table.selectedRow] as NSDictionary).object(forKey: "uid") as! String)
            player3.volume = 1.0
            player3.play()
        }
        else if table.selectedRow == 4 {
            let item =  AVPlayerItem(url: audioFileURL)
            player4 = AVPlayer(playerItem: item)
            player4.audioOutputDeviceUniqueID = ((audioDevices [table.selectedRow] as NSDictionary).object(forKey: "uid") as! String)
            player4.volume = 1.0
            player4.play()
        }
        else if table.selectedRow == 5 {
            let item =  AVPlayerItem(url: audioFileURL)
            player5 = AVPlayer(playerItem: item)
            player5.audioOutputDeviceUniqueID = ((audioDevices [table.selectedRow] as NSDictionary).object(forKey: "uid") as! String)
            player5.volume = 1.0
            player5.play()
        }
        else if table.selectedRow == 6 {
            let item =  AVPlayerItem(url: audioFileURL)
            player6 = AVPlayer(playerItem: item)
            player6.audioOutputDeviceUniqueID = ((audioDevices [table.selectedRow] as NSDictionary).object(forKey: "uid") as! String)
            player6.volume = 1.0
            player6.play()
        }
        else if table.selectedRow == 7 {
            let item =  AVPlayerItem(url: audioFileURL)
            player7 = AVPlayer(playerItem: item)
            player7.audioOutputDeviceUniqueID = ((audioDevices [table.selectedRow] as NSDictionary).object(forKey: "uid") as! String)
            player7.volume = 1.0
            player7.play()
        }
        else {
            let item =  AVPlayerItem(url: audioFileURL)
            player8 = AVPlayer(playerItem: item)
            player8.audioOutputDeviceUniqueID = ((audioDevices [table.selectedRow] as NSDictionary).object(forKey: "uid") as! String)
            player8.volume = 1.0
            player8.play()
        }
        
       /* myPlayer = AVPlayer(URL: myFilePathURL)
        myPlayer.audioOutputDeviceUniqueID = myAudioOutputDevices[1].deviceUID()
        myPlayer.play()*/
    
    }
    
}

// This extension contains methods for interacting with AudioToolbox.

extension loopBackViewController {
    
    // Install the listener for device notifications.
    
    func addPropertyListener(for property: AudioObjectProperty, deviceID: Int) {
        
        var propertyAddress = property.propertyAddress
        
        AudioObjectAddPropertyListener(AudioObjectID(deviceID), &propertyAddress, AOPropertyListenerProc, &loopBackViewController.shared)
    }
    
    // Remove the listener for device notifications.
    
    func removePropertyListener(for property: AudioObjectProperty, deviceID: Int) {
        
        var propertyAddress = property.propertyAddress
        
        AudioObjectRemovePropertyListener(AudioObjectID(deviceID), &propertyAddress, AOPropertyListenerProc, &loopBackViewController.shared)
    }
    
    // Retrieve the value of a string property of an audio device.
    
    func audioPropertyString(for property: AudioObjectProperty, deviceID: Int) throws -> String {
        
        var propertyAddress = property.propertyAddress
        var dataSize = UInt32(MemoryLayout<CFString>.size)
        var stringRef: CFString?
        
        let err = AudioObjectGetPropertyData(AudioObjectID(deviceID), &propertyAddress, 0, nil, &dataSize, &stringRef)
        guard err == noErr else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(err)) }
        guard let result = stringRef as String? else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(EINVAL)) }
        
        return result
    }
    
    // Retrieve the data size for a property of an audio device.
    
    func audioPropertyDataSize(for property: AudioObjectProperty, deviceID: Int) throws -> Int {
        
        var propertyAddress = property.propertyAddress
        var dataSize = UInt32(0)
        
        let err = AudioObjectGetPropertyDataSize(AudioObjectID(deviceID), &propertyAddress, 0, nil, &dataSize)
        guard err == noErr else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(err)) }
        
        return Int(dataSize)
    }
    
    // Retrieve the data for a property of an audio device.
    
    func audioPropertyData<T>(for property: AudioObjectProperty, deviceID: Int, type: T.Type, size: Int) throws -> UnsafeMutablePointer<T> {
        
        guard let ptr = calloc(size, 1)?.assumingMemoryBound(to: T.self)
            else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(ENOMEM)) }
        
        var propertyAddress = property.propertyAddress
        var dataSize = UInt32(size)
        
        let err = AudioObjectGetPropertyData(AudioObjectID(deviceID), &propertyAddress, 0, nil, &dataSize, ptr)
        guard err == noErr else { free(ptr); throw NSError(domain: NSOSStatusErrorDomain, code: Int(err)) }
        
        return ptr
    }
    
    // Retrieve an input or output channel count for an audio device.
    
    func audioPropertyChannelCount(for property: AudioObjectProperty, deviceID: Int) throws -> Int {
        
        // Find out the size of the stream data for the device.
        
        let dataSize = try audioPropertyDataSize(for: property, deviceID:  deviceID)
        
        // Get the stream data.
        
        let ptr = try audioPropertyData(for: property, deviceID: deviceID, type: AudioBufferList.self, size: dataSize)
        let bufferListPtr = UnsafeMutableAudioBufferListPointer(ptr)
        
        // Count the number of channels in the stream
        
        var channelCount = 0
        
        for buffer in bufferListPtr {
            channelCount += Int(buffer.mNumberChannels)
        }
        
        return channelCount
    }
    
}*/
