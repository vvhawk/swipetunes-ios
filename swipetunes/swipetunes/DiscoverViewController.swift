//
//  DiscoverViewController.swift
//  swipetunes
//
//  Created by Vasanth Banumurthy on 11/15/23.
//

import UIKit
import AVFoundation




class DiscoverViewController: UIViewController {
    
    var accessToken: String?
    
    var recommendations: [DisplaySong] = []
    var currentIndex = 0
    
    var swipeHistory: [SwipeLogEntry] = []
    
    
    let lilac = UIColor(hex: "9BB6FB")
    let mint = UIColor(hex: "5ECDA4")
    let blush = UIColor(hex: "FB9B9B")
    
    var player: AVPlayer?
    var away = false
    var swipeLock = false
    var pause = false
    
    @IBOutlet weak var albumImageView: UIImageView!
    
    @IBOutlet weak var songLabel: UILabel!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    
    // Play button tapped
    @IBAction func playButtonTapped(_ sender: UIButton) 
    {
        
        

        pauseButton.isHidden = false
        
        if player?.timeControlStatus == .paused {
                // Audio is paused, resume playing
            player?.play()
            pause = false
                playButton.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else if player?.timeControlStatus == .playing {
                // Audio is playing, restart from the beginning
            player?.seek(to: CMTime.zero) { [weak self] _ in
                    self?.player?.play()
                }
            }
        
        
    }

    

    // Pause button tapped
    @IBAction func pauseButtonTapped(_ sender: UIButton) 
    {
        if(player?.timeControlStatus == .paused)
        {
            return
        }
        pause = true
        player?.pause()
        playButton.imageView?.transform = CGAffineTransform(scaleX: 1, y: 1)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
            
        self.songLabel.text = ""
        self.artistLabel.text = ""
        albumImageView.image = nil
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        // Start loading animation
        
//        let indicatorSize: CGFloat = 50
//        // Adjust size as needed
//            activityIndicator.frame = CGRect(x: (view.frame.width - indicatorSize) / 2,
//                    y: (view.frame.height - indicatorSize) / 2,
//                    width: indicatorSize,
//                     height: indicatorSize)
        
        
        activityIndicator.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
        // Adjust scale as needed
        
        activityIndicator.startAnimating()
            
        
        
        print("Access Token in DiscoverViewController: \(accessToken ?? "nil")")
        
        // Do any additional setup after loading the view.
        
        if let customFont = UIFont(name: "Caveat-Bold", size: 42) {
            songLabel.font = customFont
        } else {
            print("Custom font not loaded.")
        }
        
        
        if let customFont = UIFont(name: "Caveat", size: 24) {
            artistLabel.font = customFont
        } else {
            print("Custom font not loaded.")
        }
        
        
        let tabBarFont = UIFont(name: "Courier New", size: 12) ?? UIFont.systemFont(ofSize: 10)
        let attributes = [NSAttributedString.Key.font: tabBarFont]
        
        UITabBarItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        
        
        
        
        let config1 = UIImage.SymbolConfiguration(pointSize: 94, weight: .medium, scale: .default)
        let largeImage1 = UIImage(systemName: "play.circle.fill", withConfiguration: config1)
        

        playButton.setImage(largeImage1, for: .normal)
        playButton.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        let config2 = UIImage.SymbolConfiguration(pointSize: 94, weight: .medium, scale: .default)
        let largeImage2 = UIImage(systemName: "pause.circle.fill", withConfiguration: config2)
        pauseButton.setImage(largeImage2, for: .normal)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            rightSwipeGesture.direction = .right
            view.addGestureRecognizer(rightSwipeGesture)

        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            leftSwipeGesture.direction = .left
            view.addGestureRecognizer(leftSwipeGesture)
        
        albumImageView.layer.borderWidth = 0
        albumImageView.layer.borderColor = UIColor.clear.cgColor
        
        
        if let accessToken = accessToken
        {
            SpotifyService.shared.fetchTopTracks(accessToken: accessToken)
            { result in
                DispatchQueue.main.async
                {
                    switch result
                    {
                    case .success(let topTracksResponse):
                        print("Top Tracks: \(topTracksResponse.items ?? [])")
                        // Extracting track IDs from the top tracks
                        let seedTrackIDs = topTracksResponse.items?.compactMap
                        { $0.id } ?? []
                        if !seedTrackIDs.isEmpty
                        {
                            // Fetch recommendations with these seed track IDs
                            self.fetchRecommendations(with: seedTrackIDs)
                        }
                    case .failure(let error):
                        print("Error fetching top tracks: \(error)")
                    }
                }
            }
        }
        else
        {
            print("Access Token not available")
        }
        
        
        
        
        
        
    }
    
    
    
    func fetchRecommendations(with seedTracks: [String]) 
    {
        guard let accessToken = self.accessToken else 
        {
            print("Access Token not available")
            return
        }
        
        SpotifyService.shared.getRecommendations(seedTracks: seedTracks, accessToken: accessToken) 
        { [weak self] result in
            DispatchQueue.main.async
            {
                switch result 
                {
                case .success(let recommendationsResponse):
                    self?.recommendations = recommendationsResponse.tracks ?? []
                    print("Recommendations: \(self?.recommendations ?? [])")
                    // Call a method to update the UI with these recommendations
                    self?.displayCurrentRecommendation()
                case .failure(let error):
                    print("Error fetching recommendations: \(error)")
                }
            }
        }
    }
    
    
    func displayCurrentRecommendation() {
        while currentIndex < recommendations.count {
            let currentSong = recommendations[currentIndex]

            if let previewURL = currentSong.previewURL {
                songLabel.text = currentSong.name
                artistLabel.text = currentSong.finalArtists
                loadAlbumArt(from: currentSong.albumCover)
                playPreview(urlString: previewURL)
                return
            } else {
                // Increment index if current song has no preview
                currentIndex += 1
            }
        }

        print("No more songs with previews available")
    }

    
    
    func loadAlbumArt(from url: String?) 
        {
        guard let urlString = url, let imageURL = URL(string: urlString) else {
            albumImageView.image = nil // or a placeholder image
            return
        }
            
       
            
            
        
        // Asynchronously load the image
        DispatchQueue.global().async 
        {
            if let data = try? Data(contentsOf: imageURL),
               let image = UIImage(data: data) 
            {
                DispatchQueue.main.async
                {
                    self.albumImageView.image = image
                    
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        
    }
    
    
    
    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) 
    {
        
        if (swipeLock == true)
        {
            print("Swipe is locked. Ignoring swipe.")
            return
        }

        
        
        let isRightSwipe = gesture.direction == .right
        let swipeAction: SwipeAction = isRightSwipe ? .liked : .disliked
        let labelColor: UIColor = isRightSwipe ? mint : blush
        let borderColor: CGColor = isRightSwipe ? mint.cgColor : blush.cgColor

        songLabel.textColor = labelColor
        artistLabel.textColor = labelColor
        albumImageView.layer.borderColor = borderColor
        albumImageView.layer.borderWidth = 2 // Adjust border width as needed
        
        
        
        // Log the swipe action
            if currentIndex < recommendations.count {
                let currentSong = recommendations[currentIndex]
                let logEntry = SwipeLogEntry(song: currentSong, action: swipeAction, timestamp: Date())
                swipeHistory.append(logEntry)
            }
        
        swipeLock = true

        // Delay for 1 second before showing next recommendation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) 
        {
            self.swipeLock = false
            // Increment the current index and update UI
            self.currentIndex = (self.currentIndex + 1) % self.recommendations.count
            self.displayCurrentRecommendation()

            // Reset colors after showing next recommendation
            self.songLabel.textColor = .black
            self.artistLabel.textColor = .black
            self.albumImageView.layer.borderColor = UIColor.clear.cgColor
            self.albumImageView.layer.borderWidth = 0
            self.playButton.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
            
        }
        
        if let tabBarVC = self.tabBarController as? UITabBarController,
               let viewControllers = tabBarVC.viewControllers {
                   for viewController in viewControllers {
                       if let logVC = viewController as? LogViewController {
                           logVC.swipedSongs = self.swipeHistory
                       }
                   }
            }
        
    
    }
    
    // Play preview URL
        func playPreview(urlString: String) 
        {
            guard let url = URL(string: urlString) else { return }
            player = AVPlayer(url: url)
            
            
            
            NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(playerDidFinishPlaying),
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: player?.currentItem
                )
            
            
            
            player?.play() // Start playing immediately
        }

        

    @objc func playerDidFinishPlaying(note: NSNotification) {
        player?.seek(to: CMTime.zero)
        player?.pause()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        
        if let tabBarVC = self.tabBarController as? UITabBarController,
               let viewControllers = tabBarVC.viewControllers {
                   for viewController in viewControllers {
                       if let logVC = viewController as? LogViewController {
                           logVC.swipedSongs = self.swipeHistory
                       }
                   }
            }

        away = true
        // Pause the audio player
        player?.pause()
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (away == true)
        {
            
            if (pause == false)
            {
                playButton.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
        
            away = false
        }
        
        if (pause == false)
        {
            player?.play()
        }

    }
    
    

    
}






