//
//  Nest.swift
//  Connecté ?
//
//  Created by Cyril DELAMARE on 08/12/2018.
//  Copyright © 2018 Cyril DELAMARE. All rights reserved.
//

import Foundation
import UIKit

class Nest {
    
    // https://console.developers.nest.com/products/2fa032aa-2df1-4da9-b6d2-664050580200
    
    let NestURL1 : String = "https://home.nest.com"
    let NestURL2 : String = "https://api.home.nest.com"
    let NestURL3 : String = "https://developer-api.nest.com/"
    let client_id : String = "2fa032aa-2df1-4da9-b6d2-664050580200"
    let client_secret : String = "4JZpE9XTMp9lgTHKrHKEMggJR"
    
    var Token : String = ""
    var TokenExpiration : Date!
    
    var piles : String = "Inconnu"

    
    init() { }
    
    
    func askAuthorization() {
        let defaults = UserDefaults.standard
        
        if ((defaults.object(forKey: "NestAccessToken")) != nil) {
            
            print("Expiration = \(defaults.object(forKey: "NestTokenExpiration") ?? "")")
            print()
            print("Default = \(defaults.description)")
            
            //loadDevices()
        }
        else {
            print("Request authorization to end user")
            let path : String = NestURL1+"/login/oauth2?client_id=\(client_id)&state=Toto"
            let url : URL = URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            
            UIApplication.shared.open(url)
        }
    }
    
    
    func getToken(authCode : String) {
        var request = URLRequest(url: URL(string: NestURL2+"/oauth2/access_token")!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=authorization_code&client_id=\(client_id)&client_secret=\(client_secret)&code=\(authCode)".data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                if (response.statusCode != 200) { print("Nest::getToken error \(response.statusCode) received "); return; }
                
                do {
                    let jsonToken : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let defaults = UserDefaults.standard
                    
                    self.Token = jsonToken.object(forKey: "access_token") as? String ?? ""
                    defaults.set(self.Token, forKey: "NestAccessToken")
                    
                    self.TokenExpiration = Date.init(timeInterval: Double(jsonToken.object(forKey: "expires_in") as! Int), since: Date())
                    defaults.set(self.TokenExpiration, forKey: "NestTokenExpiration")
                } catch let error as NSError { print("Nest::getToken failed: \(error.localizedDescription)") }
            } else { print("Nest::getToken failed: \(error!.localizedDescription)") }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
    }
    
    
    func loadDevices() {
        let path : String = NestURL3 + "devices/smoke_co_alarms/S4xaoUkme4KlMN4XBDELYBpFSyDSrbI7/battery_health"
        let url : URL = URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(Token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                //if (response.statusCode != 200) { print("Nest::loadDevices error \(response.statusCode) received "); return; }
                do {
                    let result : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    print("Result = \(result)")
                    
                } catch let error as NSError { print("Nest::loadDevices failed: \(error.localizedDescription)") }
            } else { print("Nest::loadDevices failed: \(error!.localizedDescription)") }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
    }
/*
 
     2018-12-21 18:08:08.594220+0100 Connecté ?[3934:1218166] libMobileGestalt MobileGestalt.c:890: MGIsDeviceOneOfType is not supported on this platform.
     Request = https://developer-api.nest.com/devices/smoke_co_alarms/
     Token = c.BCrHqzbomZCzhCdJs9iYzuM7BqLiNsV5wSNxmvcCuCucDHt41VM9LGOzSEvWt6wvROnLAQbTL1x1uYvyrReeSB4hWJthrJhpvK6F0Ocequi5BuYB273LAIR8j1G1ZwuRfTRPKnIBadDUUyRN
     Result = {
     S4xaoUkme4KlMN4XBDELYBpFSyDSrbI7 =     {
     "battery_health" = ok;
     "co_alarm_state" = ok;
     "device_id" = S4xaoUkme4KlMN4XBDELYBpFSyDSrbI7;
     "is_manual_test_active" = 0;
     "is_online" = 1;
     "last_connection" = "2018-12-20T21:45:58.558Z";
     "last_manual_test_time" = "2017-03-07T15:49:44.000Z";
     locale = "fr-FR";
     name = Hallway;
     "name_long" = "Hallway Nest Protect";
     "smoke_alarm_state" = ok;
     "software_version" = "3.1.4rc3";
     "structure_id" = KHuRIf94ZCXpVn214HjEdBcmU4BDI2YFUgZPVjgNKaFkc7WYXPlxIQ;
     "ui_color_state" = green;
     "where_id" = pp5HiFbxXpVsIsaKwXkGgd0nAj6ffHw8KEp9rF9zFsVvHNg7UeNRPQ;
     "where_name" = Hallway;
     };
     }
     Source Nest - Code = 28JTF32XXKSXFZXQ
 
 */
}
