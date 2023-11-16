//
//  SceneDelegate.swift
//  swipetunes
//
//  Created by Vasanth Banumurthy on 11/14/23.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        print("top 1")
        guard let _ = (scene as? UIWindowScene) else { return }
        print("top 2")
    }
    
    
    
    
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
            print("in scene")
        guard let urlContext = URLContexts.first else { return }
            let url = urlContext.url
            print("Received URL: \(url)")
        
            // Check if the incoming URL is the one from Spotify's authentication callback
            if url.scheme == "myapp-swipetunes" && url.host == "callback" {
                // Parse the URL to extract the "code" parameter
                guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                      let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                    // Handle the case where the authorization code is missing or there is an error
                    print("Error: Authorization code not found")
                    return
                }
                
                // Now you have the auth code and you can proceed with token exchange
                // You might want to pass this code back to your ViewController, for example, by using a notification or calling a method directly if you have a reference to your ViewController
                print("Posting notification with code: \(code)")
                NotificationCenter.default.post(name: .spotifyAuthCodeReceived, object: nil, userInfo: ["code": code])
                

            }
        }
    
    
    

    

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

