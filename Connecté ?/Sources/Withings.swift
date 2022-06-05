//
//  Withings.swift
//  Connecté ?
//
//  Created by Cyril DELAMARE on 08/12/2018.
//  Copyright © 2018 Cyril DELAMARE. All rights reserved.
//

import Foundation
import UIKit

class Withings {
    
    // https://account.withings.com/partner/dashboard_oauth2
    
    let WithingsURL     : String = "https://account.withings.com"
    let WithingsURLnew  : String = "https://wbsapi.withings.net/v2"
    let client_id       : String = "3a56e5bdb979d5535c0087368c4ba2c3f72681bb306335a1551b1d3f0c76c474"
    let client_secret   : String = "9e9fe6039121bce547901f5e92427b10a16bbc5668974e03095552a0be2d8326"
    
    let measureWeight       : Int = 1
    let measureBodyTemp     : Int = 71
    let measureSkinTemp     : Int = 73
    let measureFatMass      : Int = 5
    let measureRoomTemp     : Int = 12

    let typeBalance     : String = "Scale"
    let typeThermometre : String = "Smart Connected Thermometer"

    var Token           : String = ""
    var RefreshToken    : String = ""
    var TokenExpiration : Date!

    var piles : String = "Inconnu"
    
    
    init() { }
    
    
    func askAuthorization() {
        let defaults = UserDefaults.standard
        var returnCode : Int = 0
        
        if ((defaults.object(forKey: "WithingsAccessToken")) != nil) {
            print("Refresh token")
            returnCode = self.refreshToken(refresher: defaults.string(forKey: "WithingsRefreshToken")!)
        }
        
        if (returnCode != 0) {
            print("Request authorization to end user")
            let path : String = WithingsURL+"/oauth2_user/authorize2?response_type=code&client_id=\(client_id)&scope=user.info,user.metrics&state=Toto&redirect_uri=HomeConnecte://Withings"
            let url : URL = URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            
            UIApplication.shared.open(url)
        }
    }
    
    
    func getToken(authCode : String) {
        //var request = URLRequest(url: URL(string: WithingsURL+"/oauth2/token")!)
        var request = URLRequest(url: URL(string: WithingsURLnew + "/oauth2")!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "action=requesttoken&grant_type=authorization_code&client_id=\(client_id)&client_secret=\(client_secret)&code=\(authCode)&redirect_uri=HomeConnecte://Withings".data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                if (response.statusCode != 200) { print("Withings::getToken error \(response.statusCode) received "); return; }
                
                do {
                    let jsonWrapper : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let jsonToken : NSDictionary = jsonWrapper.object(forKey: "body") as! NSDictionary

                    let defaults = UserDefaults.standard
                    
                    self.Token = jsonToken.object(forKey: "access_token") as? String ?? ""
                    defaults.set(self.Token, forKey: "WithingsAccessToken")
                    
                    self.RefreshToken = jsonToken.object(forKey: "refresh_token") as? String ?? ""
                    defaults.set(self.RefreshToken, forKey: "WithingsRefreshToken")
                    
                    self.TokenExpiration = Date.init(timeInterval: jsonToken.object(forKey: "expires_in") as! Double, since: Date())
                    defaults.set(self.TokenExpiration, forKey: "WithingsTokenExpiration")
                } catch let error as NSError { print("Withings::getToken failed: \(error.localizedDescription)") }
            } else { print("Withings::getToken failed: \(error!.localizedDescription)") }
        })

        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
    }
    
    func refreshToken(refresher : String) -> Int {
        //var request = URLRequest(url: URL(string: WithingsURL+"/oauth2/token")!)
        var request = URLRequest(url: URL(string: WithingsURLnew + "/oauth2")!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "action=requesttoken&grant_type=refresh_token&refresh_token=\(refresher)&client_id=\(client_id)&client_secret=\(client_secret)".data(using: String.Encoding.utf8);
        var returnCode :Int = -1
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                returnCode = response.statusCode
                if (returnCode != 200) { print("Withings::refreshToken error \(response.statusCode) received "); return; }
                do {
                    let jsonWrapper : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let jsonToken : NSDictionary = jsonWrapper.object(forKey: "body") as! NSDictionary
                    let defaults = UserDefaults.standard

                    returnCode = jsonWrapper.object(forKey: "status") as? Int ?? -1
                    
                    self.Token = jsonToken.object(forKey: "access_token") as? String ?? ""
                    defaults.set(self.Token, forKey: "WithingsAccessToken")
                    
                    self.RefreshToken = jsonToken.object(forKey: "refresh_token") as? String ?? ""
                    defaults.set(self.RefreshToken, forKey: "WithingsRefreshToken")
                    
                    self.TokenExpiration = Date.init(timeInterval: jsonToken.object(forKey: "expires_in") as? Double ?? 0.0, since: Date())
                    defaults.set(self.TokenExpiration, forKey: "WithingsTokenExpiration")
                } catch let error as NSError { print("Withings::refreshToken failed: \(error.localizedDescription)") }
            } else { print("Withings::refreshToken failed: \(error!.localizedDescription)") }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
 
        return returnCode
}
    

    func loadDevices() {
        let path : String = "https://wbsapi.withings.net/v2/user?action=getdevice&access_token=\(Token)"
        let url : URL = URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                if (response.statusCode != 200) { print("Withings::loadDevices error \(response.statusCode) received "); return; }
                do {
                    let result : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    print("Result = \(result)")
                    let deviceList : NSArray = (result.object(forKey: "body") as! NSDictionary).object(forKey: "devices") as! NSArray
                    self.piles = (deviceList[0] as! NSDictionary).object(forKey: "battery") as? String ?? "Burp"
                    
                } catch let error as NSError { print("Withings::loadDevices failed: \(error.localizedDescription)") }
            } else { print("Withings::loadDevices failed: \(error!.localizedDescription)") }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
    }


    func loadMeasures(measure: Int, start: Int, end: Int)  -> (at : [Int], vals : [Int]) {
        var at   : [Int] = []
        var vals : [Int] = []
        var ended : Bool = false

        let dateFormShort   = DateFormatter()
        dateFormShort.locale = Locale.current
        dateFormShort.dateFormat = "dd MMM HH:mm:SS"


        let path : String = "https://wbsapi.withings.net/v2/measure?action=getmeas&startdate=" + String(start) + "&enddate=" + String(end) + "&meastype=" + String(measure) + "&access_token=\(Token)"
        let url : URL = URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                if (response.statusCode != 200) { print("Withings::loadDevices error \(response.statusCode) received "); ended = true; return; }
                do {
                    let result : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let measures : NSArray = (result.object(forKey: "body") as! NSDictionary).object(forKey: "measuregrps") as! NSArray

                    for oneMeasure in measures {
                        let timestamp : Int = ((oneMeasure as! NSDictionary).object(forKey: "date")) as? Int ?? 0
                        let mesures : NSArray = ((oneMeasure as! NSDictionary).object(forKey: "measures")) as! NSArray
                        let valeur : Int = (mesures[0] as! NSDictionary).object(forKey: "value") as? Int ?? 0
                        
                        at.append(timestamp)
                        vals.append(valeur)
                    }
                    ended = true

                } catch let error as NSError { print("Withings::loadDevices failed: \(error.localizedDescription)"); ended = true; }
            } else { print("Withings::loadDevices failed: \(error!.localizedDescription)"); ended = true; }
        })
        
        task.resume()
        while (!ended) { usleep(1000) }
        
        return (at, vals)
    }

}
