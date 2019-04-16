/* 
Copyright (c) 2018 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
class ActivationCodeBase :NSObject,Codable {
	let status : Bool?
	let message : String?
	let result : [Result]?

	enum CodingKeys: String, CodingKey {

		case status = "status"
		case message = "message"
		case result = "result"
	}

    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder){
        self.status = aDecoder.decodeObject(forKey: CodingKeys.status.rawValue) as? Bool
        self.message = aDecoder.decodeObject(forKey: CodingKeys.message.rawValue) as? String
        self.result = aDecoder.decodeObject(forKey: CodingKeys.result.rawValue) as? [Result]
        super.init()
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(status, forKey: CodingKeys.status.rawValue)
        aCoder.encode(message, forKey: CodingKeys.message.rawValue)
        aCoder.encode(result, forKey: CodingKeys.result.rawValue)
    }

}

class Result:NSObject,Codable,NSCoding {
    let venue_name : String?
    let zone_id : String?
    let zone_name : String?
    
    enum CodingKeys: String, CodingKey {
        case venue_name = "venue_name"
        case zone_id = "zone_id"
        case zone_name = "zone_name"
    }
    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder){
        self.venue_name = aDecoder.decodeObject(forKey: CodingKeys.venue_name.rawValue) as? String
        self.zone_name = aDecoder.decodeObject(forKey: CodingKeys.zone_name.rawValue) as? String
        self.zone_id = aDecoder.decodeObject(forKey: CodingKeys.zone_id.rawValue) as? String
        super.init()
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(venue_name, forKey: CodingKeys.venue_name.rawValue)
        aCoder.encode(zone_id, forKey: CodingKeys.zone_id.rawValue)
        aCoder.encode(zone_name, forKey: CodingKeys.zone_name.rawValue)
    }
}
