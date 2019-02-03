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
    
    let WithingsURL : String = "https://account.withings.com"
    let client_id : String = "3a56e5bdb979d5535c0087368c4ba2c3f72681bb306335a1551b1d3f0c76c474"
    let client_secret : String = "9e9fe6039121bce547901f5e92427b10a16bbc5668974e03095552a0be2d8326"
    
    var Token : String = ""
    var RefreshToken : String = ""
    var TokenExpiration : Date!

    var piles : String = "Inconnu"
    
    
    init() { }
    
    
    func askAuthorization() {
        let defaults = UserDefaults.standard
        
        if ((defaults.object(forKey: "WithingsAccessToken")) != nil) {
            print("Refresh token")
            self.refreshToken(refresher: defaults.string(forKey: "WithingsRefreshToken")!)

            loadDevices()
        }
        else {
            print("Request authorization to end user")
            let path : String = WithingsURL+"/oauth2_user/authorize2?response_type=code&client_id=\(client_id)&scope=user.info,user.metrics&state=Toto&redirect_uri=HomeConnecte://Withings"
            let url : URL = URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            
            UIApplication.shared.open(url)
        }
    }
    
    
    func getToken(authCode : String) {
        var request = URLRequest(url: URL(string: WithingsURL+"/oauth2/token")!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=authorization_code&client_id=\(client_id)&client_secret=\(client_secret)&code=\(authCode)&redirect_uri=HomeConnecte://Withings".data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                if (response.statusCode != 200) { print("Withings::getToken error \(response.statusCode) received "); return; }
                
                do {
                    let jsonToken : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let defaults = UserDefaults.standard
                    
                    self.Token = jsonToken.object(forKey: "access_token") as? String ?? ""
                    defaults.set(self.Token, forKey: "WithingsAccessToken")
                    
                    self.RefreshToken = jsonToken.object(forKey: "refresh_token") as? String ?? ""
                    defaults.set(self.RefreshToken, forKey: "WithingsRefreshToken")
                    
                    self.TokenExpiration = Date.init(timeInterval: Double(jsonToken.object(forKey: "expires_in") as! String)!, since: Date())
                    defaults.set(self.TokenExpiration, forKey: "WithingsTokenExpiration")
                } catch let error as NSError { print("Withings::getToken failed: \(error.localizedDescription)") }
            } else { print("Withings::getToken failed: \(error!.localizedDescription)") }
        })

        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
    }
    
    func refreshToken(refresher : String) {
        var request = URLRequest(url: URL(string: WithingsURL+"/oauth2/token")!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=refresh_token&refresh_token=\(refresher)&client_id=\(client_id)&client_secret=\(client_secret)".data(using: String.Encoding.utf8);
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                if (response.statusCode != 200) { print("Withings::refreshToken error \(response.statusCode) received "); return; }
                do {
                    let jsonToken : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let defaults = UserDefaults.standard
                    
                    self.Token = jsonToken.object(forKey: "access_token") as? String ?? ""
                    defaults.set(self.Token, forKey: "WithingsAccessToken")
                    
                    self.RefreshToken = jsonToken.object(forKey: "refresh_token") as? String ?? ""
                    defaults.set(self.RefreshToken, forKey: "WithingsRefreshToken")
                    
                    self.TokenExpiration = Date.init(timeInterval: Double(jsonToken.object(forKey: "expires_in") as! String) ?? 0.0, since: Date())
                    defaults.set(self.TokenExpiration, forKey: "WithingsTokenExpiration")
                } catch let error as NSError { print("Withings::refreshToken failed: \(error.localizedDescription)") }
            } else { print("Withings::refreshToken failed: \(error!.localizedDescription)") }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
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
                    
                    //print("Result = \(result)")
                    let deviceList : NSArray = (result.object(forKey: "body") as! NSDictionary).object(forKey: "devices") as! NSArray
                    self.piles = (deviceList[0] as! NSDictionary).object(forKey: "battery") as? String ?? "Burp"
                    
                } catch let error as NSError { print("Withings::loadDevices failed: \(error.localizedDescription)") }
            } else { print("Withings::loadDevices failed: \(error!.localizedDescription)") }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
    }
}
