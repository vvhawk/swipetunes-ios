//
//  ViewController.swift
//  swipetunes
//
//  Created by Vasanth Banumurthy on 11/14/23.
//

import UIKit
import AuthenticationServices
import Foundation

class ViewController: UIViewController, ASWebAuthenticationPresentationContextProviding
{

    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var swipeLabel: UILabel!
    
    @IBOutlet weak var loginLabel: UILabel!
    
    @IBOutlet weak var spotifyLogo: UIImageView!
    
    var counter = 0
    
    let lilac = UIColor(hex: "9BB6FB")
    let mint = UIColor(hex: "5ECDA4")
    let blush = UIColor(hex: "FB9B9B")
    
    var currentColorIndex = 0
    var colors: [UIColor] = []
    
    let clientID = "8f7480a1142f4d21b7a3bc1b49fc4822"  // Use your actual client ID
    let clientSecret = "75da21d3814c4fbbbe14f46c8e9f9148"
    var accessToken: String?
    
    // MARK: - ASWebAuthenticationPresentationContextProviding
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor
    {
        return self.view.window!
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print("hello world")
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleSpotifyCodeNotification(_:)), name: .spotifyAuthCodeReceived, object: nil)
        
        colors = [lilac, mint, blush]
        
        // Initial setup for attributed string
        updateSwipeTunesColor()

        // Set up a timer
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true)
        {
            [weak self] _ in
            self?.updateSwipeTunesColor()
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        animateSwipeGestureLabel()
        
        // Set up the swipe gesture recognizer
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
            swipeGesture.direction = .right // or .left, depending on the desired swipe direction
        swipeLabel.addGestureRecognizer(swipeGesture)
        swipeLabel.isUserInteractionEnabled = true
      
        //print("hey")
        
    }
    
    // Function to update the color
    func updateSwipeTunesColor() {
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: lilac]
        let mutableAttributedString = NSMutableAttributedString(string: "welcome\nto\n", attributes: normalTextAttributes)
        
        let swipeTunesAttributes = [NSAttributedString.Key.foregroundColor: colors[currentColorIndex]]
        let swipeTunesAttributedString = NSAttributedString(string: "swipetunes", attributes: swipeTunesAttributes)
        mutableAttributedString.append(swipeTunesAttributedString)

        welcomeLabel.attributedText = mutableAttributedString
        
        currentColorIndex = (currentColorIndex + 1) % colors.count
    }
    
    
    func animateSwipeGestureLabel() {
        UIView.animate(withDuration: 1.5, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
            // Move the label to the right
            self.swipeLabel.transform = CGAffineTransform(translationX: 20, y: 0)
        }, completion: { _ in
            // Move it back to its original position
            self.swipeLabel.transform = CGAffineTransform.identity
        })
    }
    
    @objc func appBecameActive() {
        // Restart the animation
        animateSwipeGestureLabel()
    }
    
    @objc func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        
        
        
        if gesture.direction == .right {
            
            // Handle the right swipe - start the Spotify login process
            print(counter)
            counter+=1
            startSpotifyLogin()
        }
    }
    
   
   
    
    func startSpotifyLogin() 
    {
        
        // This typically involves redirecting the user to a web-based login flow and handling the callback
        print("Starting Spotify Login...")
        
            let redirectURI = "myapp-swipetunes://callback"
            let scopes = "user-read-recently-played user-library-modify user-read-email user-read-private user-top-read"
            let encodedScopes = scopes.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

            guard let authURL = URL(string: "https://accounts.spotify.com/authorize?client_id=\(clientID)&response_type=code&redirect_uri=\(redirectURI)&scope=\(encodedScopes)") else {
                print("Invalid URL")
                return
            }
        
        // Note: "yourapp" should be replaced with the actual custom URL scheme you've defined.
//            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "myapp-swipetunes") { callbackURL, error in
//                // Handle the callback with the authorization code, error handling, etc.
//                if let callbackURL = callbackURL {
//                    // Parse the callbackURL to retrieve the authorization code
//                }
//            }
        
//        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "myapp-swipetunes") { callbackURL, error in
//            if let error = error {
//                    print("Authentication session error: \(error)")
//                } else if let callbackURL = callbackURL {
//                    print("Authentication session callback URL: \(callbackURL)")
//                }
//        }
        
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "myapp-swipetunes") { callbackURL, error in
            if let error = error {
                print("Authentication session error: \(error)")
            } else if let callbackURL = callbackURL {
                print("Authentication session callback URL: \(callbackURL)")
                // Parse the authorization code from the callback URL
                let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true)
                if let code = components?.queryItems?.first(where: { $0.name == "code" })?.value {
                    // Use the authorization code to exchange for a token
                    self.exchangeCodeForToken(authCode: code)
                }
            }
        }
        
           session.presentationContextProvider = self
           session.start()
        
        
    }
        
        
        
//    @objc func handleSpotifyCodeNotification(_ notification: Notification) 
//    {
//        print("Handling Spotify Code Notification...")
//        
//        if let code = notification.userInfo?["code"] as? String
//        {
//            // Now you have the auth code and you can proceed with token exchange
//            exchangeCodeForToken(authCode: code)
//        }
//    }
    
        

        
        func exchangeCodeForToken(authCode code: String) {
            
            print("Exchanging code for token...")
            
            let tokenURL = URL(string: "https://accounts.spotify.com/api/token")!
            var request = URLRequest(url: tokenURL)
            request.httpMethod = "POST"
            
            var bodyComponents = URLComponents(string: "")!
            bodyComponents.queryItems = [
                URLQueryItem(name: "grant_type", value: "authorization_code"),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "redirect_uri", value: "myapp-swipetunes://callback"),
                URLQueryItem(name: "client_id", value: "\(clientID)"),
                URLQueryItem(name: "client_secret", value: "\(clientSecret)")  // Not recommended for production!
            ]
            
            request.httpBody = bodyComponents.query?.data(using: .utf8)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error during HTTP request: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let accessToken = json["access_token"] as? String {
                        // Use the access token to make requests to the Spotify Web API
                        self.accessToken = accessToken
                        
                        print("Access Token: \(accessToken)")
                        
                        print("Access Token set: \(self.accessToken ?? "nil")")
                        
                        
                        self.transitionToMainInterface()
                    } else {
                        print("Could not get access token from response: \(json)")
                    }
                } else {
                    let dataString = String(data: data, encoding: .utf8)
                    print("Failed to parse data: \(dataString ?? "No data")")
                }
            }
            
            task.resume()
            
            
            
        }
    
    func transitionToMainInterface() {
        DispatchQueue.main.async { // Ensure UI updates are on the main thread.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                // This assumes you have set the Storyboard ID of your TabBarController to "TabBarController" in the Identity Inspector.
                if let discoverVC = tabBarController.viewControllers?.first as? DiscoverViewController {
                                discoverVC.accessToken = self.accessToken
                            }
                if let window = self.view.window {
                    window.rootViewController = tabBarController
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //print("Access Token in Prepare: \(accessToken)")
        
        if segue.identifier == "toTabBarController" {
            if let tabBarController = segue.destination as? UITabBarController,
               let discoverVC = tabBarController.viewControllers?.first as? DiscoverViewController {
                discoverVC.accessToken = self.accessToken
            }
        }
    }




}

