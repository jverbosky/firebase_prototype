//
//  ViewController.swift
//  Firebase Prototype
//
//  Created by something on 4/25/17.
//  Copyright © 2017 Pittsburgh TechHire. All rights reserved.
//

import UIKit
import SwiftyPlistManager

class ViewController: UIViewController {

    // let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let dataPlistName = "Login"
    let usernameKey = "username"  // plist username key
    var usernameValue:String = ""
    var fcmIdValue:String = ""
    
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var statusUpdate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    // Initialize plist if present, otherwise copy over Login.plist file into app's Documents directory
    SwiftyPlistManager.shared.start(plistNames: [dataPlistName], logging: false)
        
    // Output plist value for username
    // readPlist(usernameKey)
        
    }

    // Function to collect username from input field
    @IBAction func submitButton(_ sender: UIButton) {
        
        if inputField.text != "" {
            evaluatePlist(inputField.text!)
            statusUpdate.text = "Thank you \(inputField.text!)!"
        } else {
            statusUpdate.text = "Username not detected - please try again!"
        }
    }
    
    // Function to determine if plist is already populated
    func evaluatePlist(_ usernameValue:String) {
        
        // Run function to add key/value pairs if plist empty, otherwise run function to update values
        SwiftyPlistManager.shared.getValue(for: usernameKey, fromPlistWithName: dataPlistName) { (result, err) in
            if err != nil {
                populatePlist(usernameKey, usernameValue)
            } else {
                updatePlist(usernameKey, usernameValue)
            }
        }
    }
    
    // Function to populate empty plist file with specified key/value pair
    func populatePlist(_ key:String, _ value:String) {
        SwiftyPlistManager.shared.addNew(value, key: key, toPlistWithName: dataPlistName) { (err) in
            if err == nil {
                print("-------------> Value '\(value)' successfully added at Key '\(key)' into '\(dataPlistName).plist'")
            }
        }
    }
    
    // Function to update specified key/value pair in plist file
    func updatePlist(_ key:String, _ value:String) {
        SwiftyPlistManager.shared.save(value, forKey: key, toPlistWithName: dataPlistName) { (err) in
            if err == nil {
                print("------------------->  Value '\(value)' successfully saved at Key '\(key)' into '\(dataPlistName).plist'")
            }
        }
    }
    
    // Function to read email key/value pairs out of plist
    func readPlistEmail(_ key:Any) {
        
        // Retrieve value
        SwiftyPlistManager.shared.getValue(for: key as! String, fromPlistWithName: dataPlistName) { (result, err) in
            if err == nil {
                guard let result = result else {
                    print("-------------> The Value for Key '\(key)' does not exists.")
                    return
                }
                // print("-------------> The Value for Key '\(key)' actually exists. It is: '\(result)'")
                usernameValue = result as! String
                print("------------> The value for the fcmIdValue variable is \(usernameValue).")
            } else {
                print("No key in there!")
            }
        }
    }
    
    // Function to read fcmID key/value pairs out of plist
    func readPlistFcm(_ key:Any) {
        
        // Retrieve value
        SwiftyPlistManager.shared.getValue(for: key as! String, fromPlistWithName: dataPlistName) { (result, err) in
            if err == nil {
                guard let result = result else {
                    print("-------------> The Value for Key '\(key)' does not exists.")
                    return
                }
                // print("-------------> The Value for Key '\(key)' actually exists. It is: '\(result)'")
                fcmIdValue = result as! String
                print("------------> The value for the fcmIdValue variable is \(fcmIdValue).")
            } else {
                print("No key in there!")
            }
        }
    }

    // Function to post email and Firebase token to Sinatra app
    func postData() {
        var request = URLRequest(url: URL(string: "https://ios-post-proto-jv.herokuapp.com/post_id")!)  // test to Heroku-hosted app
        
        let email = usernameValue
        let fcmID = fcmIdValue
        
        // let email = "jv-iphone@test.com"  // test from JV iPhone
        
        let postString = "email=\(email)&fcm_id=\(String(describing: fcmID))"
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

