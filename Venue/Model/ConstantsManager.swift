//
//  ConstantsManager.swift
//  Venue
//
//  Created by CHITRA on 01/11/18.
//  Copyright © 2018 CHITRA. All rights reserved.
//

import Foundation
class ConstantsManager: NSObject {
    static var isPlayerShows = false
    static let mailURL:String = "http://portal.venuemusic.co.uk/venue-music/"
    static let activateZoneURL:String = "get-zone.php"
    static let playlistURL:String = "get-playlist-shuffled.php"
    static let getNextTrack:String = "get-single-track-ex.php"
    static let updateTrack:String = "update-now-playing.php"
    static let checkActivationCode:String = "check-activationcode.php"
    static let blockSong:String = "block-songs.php"
    static let stopPlayer:String = "stop-player.php"

    
    static let activateCodeError:String = "Invalid Activation Code"

}
