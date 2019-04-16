//
//  ZoneTabs.swift
//  Venue
//
//  Created by SrishtiInnovaitve on 01/04/19.
//  Copyright © 2019 CHITRA. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit
import AudioToolbox
func AOPropertyListenerProc(_ objectID: AudioObjectID, _ addressCount: UInt32, _ addresses: UnsafePointer<AudioObjectPropertyAddress>, _ clientData: UnsafeMutableRawPointer?) -> OSStatus {
    
    let winController = clientData!.assumingMemoryBound(to: ZoneTabs.self).pointee
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

var audioDevices: [[String: String]] = []
var listIfTabView: [NSTabViewItem]!
class ZoneTabs: NSTabViewController {
    
    static var shared: ZoneTabs!
    let audioSystemID = Int(kAudioObjectSystemObject)
    @IBOutlet weak var tabViewItem: NSTabViewItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ZoneTabs.shared = self
        
        // Generate initial device list.
        
        updateDeviceList()
        
        // Install the listener for device notifications.
        
        addPropertyListener(for: .devices, deviceID: audioSystemID)
        // Do any additional setup after loading the view.
        
    }
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        if tabViewItem?.label == "Add Zone" {
            // Do any additional setup after loading the view.
            let newItem: NSTabViewItem = NSTabViewItem(identifier: "\(tabView.indexOfTabViewItem(tabViewItem!))")
            newItem.label = "Zone \(tabView.indexOfTabViewItem(tabViewItem!) + 1)"
            // "tvcontroller" is in storyboard
            newItem.viewController = storyboard?.instantiateController(withIdentifier: "VZoneActivationViewController") as? VZoneActivationViewController
            insertTabViewItem(newItem, at: tabView.indexOfTabViewItem(tabViewItem!))
            listIfTabView = tabViewItems
         }
        
    }
    
    
    override func tabViewDidChangeNumberOfTabViewItems(_ tabView: NSTabView) {
        
        
    }
    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        
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
    }
    
}
extension ZoneTabs {
    
    // Install the listener for device notifications.
    
    func addPropertyListener(for property: AudioObjectProperty, deviceID: Int) {
        
        var propertyAddress = property.propertyAddress
        
        AudioObjectAddPropertyListener(AudioObjectID(deviceID), &propertyAddress, AOPropertyListenerProc, &ZoneTabs.shared)
    }
    
    // Remove the listener for device notifications.
    
    func removePropertyListener(for property: AudioObjectProperty, deviceID: Int) {
        
        var propertyAddress = property.propertyAddress
        
        AudioObjectRemovePropertyListener(AudioObjectID(deviceID), &propertyAddress, AOPropertyListenerProc, &ZoneTabs.shared)
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
    
}
