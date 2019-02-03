//
//  Netatmo.swift
//  Connecté ?
//
//  Created by Cyril DELAMARE on 02/12/2018.
//  Copyright © 2018 Cyril DELAMARE. All rights reserved.
//

import Foundation

class Netatmo {

    let NetatmoURL : String = "https://api.netatmo.com"
    let client_id : String = "5c040915a467a36f768e1945"
    let client_secret : String = "ZZOOrlLD35O4gI4Rk546xRiOW9K60c"
    let NetatmoLogin : String = "gonecd@gmail.com"
    let NetatmoPassword : String = "00egalNoao"

    var Token : String = ""
    var RefreshToken : String = ""
    var TokenExpiration : Date!

    init () { }
    
    func oldinit()
    {
        let defaults = UserDefaults.standard
        
        if ((defaults.object(forKey: "NetatmoAccessToken")) != nil) {
            print("Refresh token")
            self.refreshToken(refresher: defaults.string(forKey: "NetatmoRefreshToken")!)
        }
        else {
            print("Get token")
            self.getToken()
        }

        loadDevices()
    }

    
    func getToken() {
        var request = URLRequest(url: URL(string: NetatmoURL+"/oauth2/token")!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=password&client_id=\(client_id)&client_secret=\(client_secret)&username=\(NetatmoLogin)&password=\(NetatmoPassword)".data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                if (response.statusCode != 200) { print("Netatmo::getToken error \(response.statusCode) received "); return; }

                do {
                    let jsonToken : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let defaults = UserDefaults.standard

                    self.Token = jsonToken.object(forKey: "access_token") as? String ?? ""
                    defaults.set(self.Token, forKey: "NetatmoAccessToken")

                    self.RefreshToken = jsonToken.object(forKey: "refresh_token") as? String ?? ""
                    defaults.set(self.RefreshToken, forKey: "NetatmoRefreshToken")

                    self.TokenExpiration = Date.init(timeInterval: Double(jsonToken.object(forKey: "expires_in") as! Int), since: Date())
                    defaults.set(self.TokenExpiration, forKey: "NetatmoTokenExpiration")
                } catch let error as NSError { print("Netatmo::getToken failed: \(error.localizedDescription)") }
            } else { print("Netatmo::getToken failed: \(error!.localizedDescription)") }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
    }
    

    func refreshToken(refresher : String) {
        var request = URLRequest(url: URL(string: NetatmoURL+"/oauth2/token")!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=refresh_token&refresh_token=\(refresher)&client_id=\(client_id)&client_secret=\(client_secret)".data(using: String.Encoding.utf8);
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                if (response.statusCode != 200) { print("Netatmo::refreshToken error \(response.statusCode) received "); return; }
                do {
                    let jsonToken : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    let defaults = UserDefaults.standard
                    
                    self.Token = jsonToken.object(forKey: "access_token") as? String ?? ""
                    defaults.set(self.Token, forKey: "NetatmoAccessToken")
                    
                    self.RefreshToken = jsonToken.object(forKey: "refresh_token") as? String ?? ""
                    defaults.set(self.RefreshToken, forKey: "NetatmoRefreshToken")
                    
                    self.TokenExpiration = Date.init(timeInterval: Double(jsonToken.object(forKey: "expires_in") as! Int), since: Date())
                    defaults.set(self.TokenExpiration, forKey: "NetatmoTokenExpiration")
                } catch let error as NSError { print("Netatmo::refreshToken failed: \(error.localizedDescription)") }
            } else { print("Netatmo::refreshToken failed: \(error!.localizedDescription)") }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
    }
    
    
    func loadDevices() {
        let path : String = NetatmoURL+"/api/getstationsdata?access_token=\(Token)"
        let url : URL = URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse  {
                if (response.statusCode != 200) { print("Netatmo::loadDevices error \(response.statusCode) received "); return; }
                do {
                    let result : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    print("Result = \(result)")

                } catch let error as NSError { print("Netatmo::loadDevices failed: \(error.localizedDescription)") }
            } else { print("Netatmo::loadDevices failed: \(error!.localizedDescription)") }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }
    }
}
