//
//  SocketManager.swift
//  Venue
//
//  Created by CHITRA on 14/11/18.
//  Copyright © 2018 CHITRA. All rights reserved.
//

import Cocoa
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    let config : [String: Any] = ["log": false,
                                "compress": true,
                                      "forcePolling": true,
                                      "forceNew": true,
                                      "forceWebsockets" : true]
    
    var socket: SocketIOClient!
    var manager: SocketManager!
    
    
    override init() {
        super.init()
        manager = SocketManager(socketURL: NSURL(string: "http://13.237.40.14:3004")! as URL,config:[])
        socket = manager.defaultSocket
        
        socket.on(clientEvent: SocketClientEvent.connect) { (data, emitter) in
            
        }
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection(){
        socket.disconnect()
    }

}
