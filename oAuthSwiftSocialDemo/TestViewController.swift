//
//  TestViewController.swift
//  
//
//  Created by Craig Robertson on 1/11/17.
//  Modified from ViewController.swift provided from https://github.com/OAuthSwift/OAuthSwift/blob/master/Demo/Common/ViewController.swift
//

import UIKit
import OAuthSwift

class TestViewController: UIViewController {

    var oauthswift: OAuthSwift?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func twitterButtonAction(_ sender: UIButton) {
        // first authorize twitter
        doOAuthTwitter()

    }

    @IBAction func twitterPostButtonAction(_ sender: UIButton) {
        // test twitter response
        testTwitter(oauthswift as! OAuth1Swift)
    }
    
    func doOAuthTwitter(){
        let oauthswift = OAuth1Swift(
            consumerKey:    "APP CONSUMER KEY GOES HERE. Get this from dev.twitter.com",
            consumerSecret: "APP CONSUMER SECRET GOES HERE. Get this from dev.twitter.com",
            requestTokenUrl: "https://api.twitter.com/oauth/request_token",
            authorizeUrl:    "https://api.twitter.com/oauth/authorize",
            accessTokenUrl:  "https://api.twitter.com/oauth/access_token"
        )
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = getURLHandler()
        let _ = oauthswift.authorize(
            // this callbackURL is gets sent out to the twitter API so that when the API responds you get autoredirected
            // in order for the callback to get opened you need to set the Target URLType, URL Scheme to match the app name, oAuthSwiftSocialDemo in this case
            // this tells safari (which receives the callback) to open the request in this app. the <test> below is the hostname. This then gets opened in the AppDelegate open url function
            withCallbackURL: URL(string: "oAuthSwiftSocialDemo://test")!,
            success: { credential, response, parameters in
                self.showTokenAlert(name: "Token Alert", credential: credential)
                self.testTwitter(oauthswift)
        },
            failure: { error in
                print(error.description)
        }
        )
    }
    
    func testTwitter(_ oauthswift: OAuth1Swift) {
        // this should print the mentions for the twitter user you authorized. In http response.
        let _ = oauthswift.client.get(
            "https://api.twitter.com/1.1/statuses/mentions_timeline.json", parameters: [:],
            success: { response in
                let jsonDict = try? response.jsonObject()
                print(jsonDict as Any)
        }, failure: { error in
            print(error)
        }
        )
    }

    
    func showTokenAlert(name: String?, credential: OAuthSwiftCredential) {
        var message = "oauth_token:\(credential.oauthToken)"
        if !credential.oauthTokenSecret.isEmpty {
            message += "\n\noauth_token_secret:\(credential.oauthTokenSecret)"
        }
        self.showAlertView(title: name ?? "Service", message: message)
 
    }
    
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func getURLHandler() -> OAuthSwiftURLHandlerType {
        // with iOS > 9 we can use the SafariURLHandler instead of WebViewControllers
        let handler = SafariURLHandler(viewController: self, oauthSwift: self.oauthswift!)
        handler.presentCompletion = {
            print("Safari presented")
        }
        handler.dismissCompletion = {
            print("Safari dismissed")
        }
        return handler
    }
    
}
