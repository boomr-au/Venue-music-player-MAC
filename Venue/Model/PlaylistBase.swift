//
//  PlaylistBase.swift
//  Venue
//
//  Created by CHITRA on 05/11/18.
//  Copyright © 2018 CHITRA. All rights reserved.
//

import Foundation
struct PlaylistBase : Codable {
    let status : Bool?
    let message : String?
    let result : PLayListResult?
    
    enum CodingKeys: String, CodingKey {
        
        case status = "status"
        case message = "message"
        case result = "result"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Bool.self, forKey: .status)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        result = try values.decodeIfPresent(PLayListResult.self, forKey: .result)
    }
    
}
struct PLayListResult : Codable {
    let schedule_id : String?
    let schedule_name : String?
    let schedule_color : String?
    let created_by : String?
    let playlists : [Playlists]?
    
    enum CodingKeys: String, CodingKey {
        
        case schedule_id = "schedule_id"
        case schedule_name = "schedule_name"
        case schedule_color = "schedule_color"
        case created_by = "created_by"
        case playlists = "playlists"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        schedule_id = try values.decodeIfPresent(String.self, forKey: .schedule_id)
        schedule_name = try values.decodeIfPresent(String.self, forKey: .schedule_name)
        schedule_color = try values.decodeIfPresent(String.self, forKey: .schedule_color)
        created_by = try values.decodeIfPresent(String.self, forKey: .created_by)
        playlists = try values.decodeIfPresent([Playlists].self, forKey: .playlists)
    }
    
}


struct Playlists : Codable {
    let playlist_id : String?
    let playlist_name : String?
    let playlist_color : String?
    let is_bucket : Int?
    let duration : String?
    let start_time : String?
    let end_time : String?
    let p_duration : String?
    let songs : [Track]?
    var isOpen : Bool?

    enum CodingKeys: String, CodingKey {
        
        case playlist_id = "playlist_id"
        case playlist_name = "playlist_name"
        case playlist_color = "playlist_color"
        case is_bucket = "is_bucket"
        case duration = "duration"
        case start_time = "start_time"
        case end_time = "end_time"
        case p_duration = "p_duration"
        case songs = "songs"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        playlist_id = try values.decodeIfPresent(String.self, forKey: .playlist_id)
        playlist_name = try values.decodeIfPresent(String.self, forKey: .playlist_name)
        playlist_color = try values.decodeIfPresent(String.self, forKey: .playlist_color)
        is_bucket = try values.decodeIfPresent(Int.self, forKey: .is_bucket)
        duration = try values.decodeIfPresent(String.self, forKey: .duration)
        start_time = try values.decodeIfPresent(String.self, forKey: .start_time)
        end_time = try values.decodeIfPresent(String.self, forKey: .end_time)
        p_duration = try values.decodeIfPresent(String.self, forKey: .p_duration)
        songs = try values.decodeIfPresent([Track].self, forKey: .songs)
        isOpen = false
    }
    
}

struct Songs : Codable {
    let song_id : String?
    let song_title : String?
    let artist_name : String?
    let duration : String?
    let album_title : String?
    let album_id : String?
    let track_number : String?
    let gain : String?
    let peak : String?
    let total_duration : String?
    let song_url : String?
    
    enum CodingKeys: String, CodingKey {
        
        case song_id = "song_id"
        case song_title = "song_title"
        case artist_name = "artist_name"
        case duration = "duration"
        case album_title = "album_title"
        case album_id = "album_id"
        case track_number = "track_number"
        case gain = "gain"
        case peak = "peak"
        case total_duration = "total_duration"
        case song_url = "song_url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        song_id = try values.decodeIfPresent(String.self, forKey: .song_id)
        song_title = try values.decodeIfPresent(String.self, forKey: .song_title)
        artist_name = try values.decodeIfPresent(String.self, forKey: .artist_name)
        duration = try values.decodeIfPresent(String.self, forKey: .duration)
        album_title = try values.decodeIfPresent(String.self, forKey: .album_title)
        album_id = try values.decodeIfPresent(String.self, forKey: .album_id)
        track_number = try values.decodeIfPresent(String.self, forKey: .track_number)
        gain = try values.decodeIfPresent(String.self, forKey: .gain)
        peak = try values.decodeIfPresent(String.self, forKey: .peak)
        total_duration = try values.decodeIfPresent(String.self, forKey: .total_duration)
        song_url = try values.decodeIfPresent(String.self, forKey: .song_url)
    }
    
}
