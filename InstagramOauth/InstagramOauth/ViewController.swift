//
//  ViewController.swift
//  InstagramOauth
//
//  Created by David Hopkins on 7/25/17.
//  Copyright © 2017 David Hopkins. All rights reserved.
//

import UIKit
import SafariServices
import Dispatch

class ViewController: UIViewController {

    @IBOutlet weak var loginStatus: UILabel!
    
    var authSession: SFAuthenticationSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }

    @IBAction func loginWithInstagram(_ sender: Any) {
        // app url that will handle callback, registered under URLTypes in Info.plist
        let callbackUrl  = "InstagramOauth://"
        // server url for Instagram callback
        let redirectUrl = "http://localhost:5000/callback"
        // Instagram client id - this must be created in dev portal and should be kept secret for real app
        let instragmClientId = "5177a42c89db4a7d992f9ae52c143393"
        // Instagram auth URL, including client id (should be kept secret in real app) and redirect uri to call
        let authURL = "https://api.instagram.com/oauth/authorize/?client_id=" + instragmClientId + "&redirect_uri=" + redirectUrl + "&response_type=code"
        //Initialize auth session
        self.authSession = SFAuthenticationSession(url: URL(string: authURL)!, callbackURLScheme: callbackUrl, completionHandler: { (callBack:URL?, error:Error? ) in
            guard error == nil, let successURL = callBack else {
                print(error!)
                self.loginStatus.text = "Error logging in with Instagram"
                return
            }
            // get token from query string
            let token = self.getQueryStringParameter(url: (successURL.absoluteString), param: "token")
            // use token fetch username from Instagram and set in UI
            self.setInstagramUsername(token: token!)
        })
        self.loginStatus.text = "Starting SFAuthenticationSession..."
        self.authSession?.start()
    }
    
    func setInstagramUsername(token: String) {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        // url to fetch Instagram user profile
        let url = URL(string: "https://api.instagram.com/v1/users/self/?access_token=" + token)!
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        // get username from json {"data": {"username": ...}...}
                        if let data = json["data"] as? [String: Any], let username = data["username"] as? String {
                            // must set text on main UI thread
                            DispatchQueue.main.async {
                                self.loginStatus.text = "Logged in as " + username
                            }
                        } else {
                            print("error getting username from json")
                        }
                    }
                } catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
}

