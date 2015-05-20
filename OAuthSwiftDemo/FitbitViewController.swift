//
//  FitbitViewController.swift
//  OAuthSwift
//
//  Created by Wright, Justin M on 5/20/15.
//  Copyright (c) 2015 Dongri Jin. All rights reserved.
//

import UIKit
import OAuthSwift
import SwiftyJSON

let FITBIT_CONSUMER_KEY = "f30fbf6431769c9afc7d42f66ced37dc" // client key
let FITBIT_CONSUMER_SECRET = "bd710d2d53601e640819d9ebef3f5b2d"
let USERDATA_FITBIT_OAUTH_TOKEN = "fitbit_oauth_token"
let USERDATA_FITBIT_OAUTH_TOKEN_SECRET = "fitbit_oauth_token_secret"

class FitbitViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  
  @IBAction func authenticate(sender: AnyObject) {
    
    authenticateFitbit()
    
  }
  
  @IBAction func userData(sender: AnyObject){
    
    if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(USERDATA_FITBIT_OAUTH_TOKEN) as? String,
      let accessSecret = NSUserDefaults.standardUserDefaults().objectForKey(USERDATA_FITBIT_OAUTH_TOKEN_SECRET) as? String {
        
        println("AccessToken \(accessToken)")
        println("AccessSecret \(accessSecret)")
        
        
        let client = OAuthSwiftClient(consumerKey: FITBIT_CONSUMER_KEY, consumerSecret: FITBIT_CONSUMER_SECRET, accessToken: accessToken, accessTokenSecret: accessSecret)
        
        let params = [ "oauth_consumer_key" : FITBIT_CONSUMER_KEY ]
        getUserData(client, parameters: params)
        
    }
    
    
  }
  
  func authenticateFitbit(){
    let callback = "xtrapoint://oauth-callback/fitbit"
    let oauthswift = getOAuthswift()
    
    
    oauthswift.authorizeWithCallbackURL( NSURL(string: callback)!, success: {
      [unowned self]  credential, response in
      println("Fitbit message: oauth_token: \(credential.oauth_token)\nnoauth_toke_secret: \(credential.oauth_token_secret)")
      
      // Save OAuthSwiftCredential
      NSUserDefaults.standardUserDefaults().setObject(credential.oauth_token, forKey: USERDATA_FITBIT_OAUTH_TOKEN)
      NSUserDefaults.standardUserDefaults().setObject(credential.oauth_token_secret, forKey: USERDATA_FITBIT_OAUTH_TOKEN_SECRET)
      
      let params = [ "oauth_consumer_key" : FITBIT_CONSUMER_KEY ]
      self.getUserData(oauthswift.client, parameters: params)
      
      }, failure: {(error:NSError!) -> Void in
        println(error.localizedDescription)
    })
    
  }
  
  
  func getOAuthswift() -> OAuth1Swift {
    let oauthswift = OAuth1Swift(
      consumerKey:    FITBIT_CONSUMER_KEY,
      consumerSecret: FITBIT_CONSUMER_SECRET,
      requestTokenUrl: "https://api.fitbit.com/oauth/request_token",
      authorizeUrl:    "https://www.fitbit.com/oauth/authorize?display=touch",
      accessTokenUrl:  "https://api.fitbit.com/oauth/access_token"
    )
    return oauthswift
  }
  
  
  func getUserData(client:OAuthSwiftClient, parameters:[String : AnyObject]){
    
    let urlString = "https://api.fitbit.com/1/user/-/profile.json"
    
    client.post(urlString, parameters: parameters, success: { (data, response) -> Void in
      
      let json = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil)
      println("jsonData:\(json)")
      
      }, failure: { [unowned self] (error) -> Void in
        println("Error \(error)")
        println("Ooops did not work")
        self.authenticateFitbit()
      })
    
  }
  
  
  
}
