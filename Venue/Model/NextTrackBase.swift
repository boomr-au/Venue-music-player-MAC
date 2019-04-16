/* 
Copyright (c) 2018 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct NextTrackBase : Codable {
	let status : Bool?
	let message : String?
	let track : Track?

	enum CodingKeys: String, CodingKey {

		case status = "status"
		case message = "message"
		case track = "track"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		status = try values.decodeIfPresent(Bool.self, forKey: .status)
		message = try values.decodeIfPresent(String.self, forKey: .message)
		track = try values.decodeIfPresent(Track.self, forKey: .track)
	}

}
class Track:NSObject,Codable,NSCoding {
    let playlist_name : String?
    let playlist_id : String?
    let song_id : String?
    let song_title : String?
    let artist_name : String?
    let duration : String?
    let album_title : String?
    let album_id : String?
    let track_number : String?
    let gain : String?
    let peak : String?
    let song_url : String?
    
    enum CodingKeys: String, CodingKey {
        
        case playlist_name = "playlist_name"
        case playlist_id = "playlist_id"
        case song_id = "song_id"
        case song_title = "song_title"
        case artist_name = "artist_name"
        case duration = "duration"
        case album_title = "album_title"
        case album_id = "album_id"
        case track_number = "track_number"
        case gain = "gain"
        case peak = "peak"
        case song_url = "song_url"
    }
    
    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder){
        self.playlist_name = aDecoder.decodeObject(forKey: CodingKeys.playlist_name.rawValue) as? String
        self.playlist_id = aDecoder.decodeObject(forKey: CodingKeys.playlist_id.rawValue) as? String
        self.song_id = aDecoder.decodeObject(forKey: CodingKeys.song_id.rawValue) as? String
        self.song_title = aDecoder.decodeObject(forKey: CodingKeys.song_title.rawValue) as? String
        self.artist_name = aDecoder.decodeObject(forKey: CodingKeys.artist_name.rawValue) as? String
        self.duration = aDecoder.decodeObject(forKey: CodingKeys.duration.rawValue) as? String
        self.album_title = aDecoder.decodeObject(forKey: CodingKeys.album_title.rawValue) as? String
        self.album_id = aDecoder.decodeObject(forKey: CodingKeys.album_id.rawValue) as? String
        self.track_number = aDecoder.decodeObject(forKey: CodingKeys.track_number.rawValue) as? String
        self.gain = aDecoder.decodeObject(forKey: CodingKeys.gain.rawValue) as? String
        self.peak = aDecoder.decodeObject(forKey: CodingKeys.peak.rawValue) as? String
        self.song_url = aDecoder.decodeObject(forKey: CodingKeys.song_url.rawValue) as? String
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(playlist_name, forKey: CodingKeys.playlist_name.rawValue)
        aCoder.encode(playlist_id, forKey: CodingKeys.playlist_id.rawValue)
        aCoder.encode(song_id, forKey: CodingKeys.song_id.rawValue)
        aCoder.encode(song_title, forKey: CodingKeys.song_title.rawValue)
        aCoder.encode(artist_name, forKey: CodingKeys.artist_name.rawValue)
        aCoder.encode(duration, forKey: CodingKeys.duration.rawValue)
        aCoder.encode(album_title, forKey: CodingKeys.album_title.rawValue)
        aCoder.encode(album_id, forKey: CodingKeys.album_id.rawValue)
        aCoder.encode(track_number, forKey: CodingKeys.track_number.rawValue)
        aCoder.encode(gain, forKey: CodingKeys.gain.rawValue)
        aCoder.encode(peak, forKey: CodingKeys.peak.rawValue)
        aCoder.encode(song_url, forKey: CodingKeys.song_url.rawValue)
    }
    
}

