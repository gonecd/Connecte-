//
//  Parrot.swift
//  Connecté ?
//
//  Created by Cyril DELAMARE on 08/12/2018.
//  Copyright © 2018 Cyril DELAMARE. All rights reserved.
//

import Foundation

class Parrot {
    
    let ParrotURL : String = "https://api-flower-power-pot.parrot.com"
    let accessCode : String = "gonecd@gmail.com"
    let secretAccess : String = "LeeM3LNSbBAOCW8dZnVOwbpSSSMBOmp0ZV8H3RXwdY90RSTp"
    let ParrotLogin : String = "gonecd@gmail.com"
    let ParrotPassword : String = "00egalFopo"
    
    var accessToken : String = ""
    var authHeader : String = ""
    
    init() {
        getToken()
    }
    
    func getToken() {
        
        print("Parrot getToken")
        print("---------------")
        //var request = URLRequest(url: URL(string: ParrotURL+"/user/v3/authenticate?grant_type=password&client_id=\(accessCode)&client_secret=\(secretAccess)&username=\(ParrotLogin)&password=\(ParrotPassword)")!)

        var request = URLRequest(url: URL(string: ParrotURL+"/user/v3/authenticate")!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=password&client_id=\(accessCode)&client_secret=\(secretAccess)&username=\(ParrotLogin)&password=\(ParrotPassword)".data(using: String.Encoding.utf8);
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                print ("Response = \(response)")
                print ("Data = \(data), \(data.debugDescription), \(data.description)")

                //if (response.statusCode != 200) { print("Parrot::getToken error \(response.statusCode) received "); return; }

                do {
                    let jsonResponse : NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary

                    print("JSon = \(jsonResponse)")
                } catch let error as NSError { print("Parrot::getToken failed: \(error.localizedDescription)") }
            } else { print(error as Any) }
        })
        
        task.resume()
        while (task.state != URLSessionTask.State.completed) { sleep(1) }

        print("")
    }
    
}
