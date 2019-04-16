//
//  NetworkManager.swift
//  Venue
//
//  Created by CHITRA on 01/11/18.
//  Copyright © 2018 CHITRA. All rights reserved.
//

import Cocoa
import Alamofire
class NetworkManager: NSObject {
    var completionHandler : (Bool, AnyObject?, NSError?)->() = {_,_,_ in }
    
    func postMethodAlamofire(_ serviceName : String, dictionary : NSDictionary, completion : @escaping (Bool, AnyObject?, NSError?)->Void)
    {
        completionHandler = completion
        if let url = URL(string: ConstantsManager.mailURL + serviceName) {
            //let header = ["Content-Type":"application/x-www-form-urlencoded"]
            request(url, method: .post, parameters: dictionary as? Parameters, encoding: URLEncoding.httpBody, headers: nil).responseJSON { (response:DataResponse<Any>) in
                switch response.result {
                case .success(let jsonData):
                    let dictionary = jsonData as! NSDictionary
                    let status:Bool = dictionary.object(forKey: "status") as! Bool
                    if(status){
                        self.getModalObject(serviceUrl: serviceName, response: response)
                    }else{
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : dictionary.value(forKey: "message")! as! String])
                        let response = dictionary.value(forKey: "message")! as? String
                        self.completionHandler(true,response as AnyObject,error)
                    }
                case .failure(let error): completion(false,nil,error as NSError)
                    break
                    
                }
            }
        }
    }
    
    func getModalObject(serviceUrl:String,response:DataResponse<Any>){
        let data = getSerializedData(response: response)
        let decoder = JSONDecoder()
        do{
            switch serviceUrl {
            case ConstantsManager.activateZoneURL:
                let responseData = try decoder.decode(ActivationCodeBase.self, from: data)
                completionHandler(true,responseData as AnyObject,nil)
            case ConstantsManager.playlistURL:
                let responseData = try decoder.decode(PlaylistBase.self, from: data)
                completionHandler(true,responseData as AnyObject,nil)
            case ConstantsManager.getNextTrack:
                let responseData = try decoder.decode(NextTrackBase.self, from: data)
                completionHandler(true,responseData as AnyObject,nil)
            case ConstantsManager.updateTrack:
                let responseData = try decoder.decode(UpdateTrackBase.self, from: data)
                completionHandler(true,responseData as AnyObject,nil)
            case ConstantsManager.checkActivationCode:
                let responseData = try decoder.decode(CheckActivationCode.self, from: data)
                completionHandler(true,responseData as AnyObject,nil)
            case ConstantsManager.blockSong:
                let responseData = try decoder.decode(BlockSong.self, from: data)
                completionHandler(true,responseData as AnyObject,nil)
            case ConstantsManager.stopPlayer:
                let responseData = try decoder.decode(StopPlayer.self, from: data)
                completionHandler(true,responseData as AnyObject,nil)
            default:
                break
            }
        }catch{
        }
    }
    
    func getSerializedData(response:DataResponse<Any>)->Data{
        var dataNew = Data()
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: response.result.value!, options: .prettyPrinted)
            let reqJSONStr = String(data: jsonData, encoding: .utf8)
            dataNew = (reqJSONStr?.data(using: .utf8))!
        }catch{
        }
        return dataNew
    }
}
