//
//  CheckActivationCode.swift
//  Venue
//
//  Created by CHITRA on 14/11/18.
//  Copyright © 2018 CHITRA. All rights reserved.
//

import Foundation
struct CheckActivationCode : Codable {
    let status : Bool?
    let message : String?
    let result : [String]?
    
    enum CodingKeys: String, CodingKey {
        
        case status = "status"
        case message = "message"
        case result = "result"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decodeIfPresent(Bool.self, forKey: .status)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        result = try values.decodeIfPresent([String].self, forKey: .result)
    }
    
}
