//
//  LogViewController.swift
//  swipetunes
//
//  Created by Vasanth Banumurthy on 11/16/23.
//

import Foundation
import UIKit
import AVFoundation

class LogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var logTableView: UITableView!
    
    // Your data model array
    var swipedSongs: [SwipeLogEntry] = [] // Update this with your actual data model
    
    let lilac = UIColor(hex: "9BB6FB")
    let mint = UIColor(hex: "5ECDA4")
    let blush = UIColor(hex: "FB9B9B")
    
    
    var lilacWithAlpha: UIColor?
    var mintWithAlpha: UIColor?
    var blushWithAlpha: UIColor?
    
    var player: AVPlayer?
    
    var currentlyPlayingIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTableView.dataSource = self
        logTableView.delegate = self
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(swipeHistoryUpdated), name: .swipeHistoryUpdated, object: nil)
        //
        logTableView.tableFooterView = UIView()
        
        // Now adjust the alpha component within viewDidLoad
        mintWithAlpha = mint.withAlphaComponent(0.5) // 50% opacity
        blushWithAlpha = blush.withAlphaComponent(0.5) // 50% opacity
        
        lilacWithAlpha = lilac.withAlphaComponent(0.5) // 50% opacity
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil // Listen for any AVPlayerItem
        )
        
    }
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return swipedSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "SwipeLogCell", for: indexPath)
        //        let song = swipedSongs[indexPath.row]
        //        // Configure the cell with data from logEntry
        //        cell.albumImageView.image = UIImage(named: song.albumCover) // if albumCover is a string of image name
        //            cell.artistLabel.text = song.finalArtists
        //            cell.songLabel.text = song.name
        //        return cell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwipeLogCell", for: indexPath) as? SwipeLogTableViewCell else {
            fatalError("Failed to dequeue SwipeLogTableViewCell")
        }
        
        
        let entry = swipedSongs[indexPath.row]
        // Assuming you have these outlets in your custom cell class
        
        
        //cell.albumImageView = nil
        
        
        
        if let imageView = cell.albumImageView {
            imageView.image = nil
        }
        
        //cell.albumImageView?.image = nil
        
        cell.playingIndicatorImageView?.image = nil
        
        
        cell.artistLabel.text = entry.song.finalArtists
        cell.songLabel.text = entry.song.name
        
    
        
        // Load album cover image from URL
        if let urlString = entry.song.albumCover, let imageURL = URL(string: urlString) {
            // Asynchronously load the image
            URLSession.shared.dataTask(with: imageURL) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.albumImageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.albumImageView.image = UIImage(named: "defaultAlbumImage") // Your default image
                    }
                }
            }.resume()
        } else {
            cell.albumImageView.image = UIImage(named: "defaultAlbumImage") // Your default image
        }
        
        
        // Set the background color based on the swipe action
        switch entry.action {
        case .liked:
            cell.backgroundColor = mintWithAlpha
        case .disliked:
            cell.backgroundColor = blushWithAlpha
        default:
            cell.backgroundColor = .clear // Or any default color
        }
        
        
        // Custom selection view
        let selectionView = UIView()
        selectionView.backgroundColor = lilac
        cell.selectedBackgroundView = selectionView
        
        
        // Add swipe gesture recognizers
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe(_:)))
        rightSwipeGesture.direction = .right
        cell.addGestureRecognizer(rightSwipeGesture)
        
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe(_:)))
        leftSwipeGesture.direction = .left
        cell.addGestureRecognizer(leftSwipeGesture)
        
        
        
        
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                    let selectedSong = swipedSongs[indexPath.row].song
                    if let previewURL = selectedSong.previewURL {
                        playPreview(urlString: previewURL)
                    }
        
        let entry = swipedSongs[indexPath.row]
        if let previewURLString = entry.song.previewURL, let previewURL = URL(string: previewURLString) {
            if currentlyPlayingIndexPath == indexPath {
                // The same cell is tapped, stop the preview
                player?.pause()
                tableView.deselectRow(at: indexPath, animated: true)
                currentlyPlayingIndexPath = nil
            } else {
                // A different cell is tapped, play the preview
                player = AVPlayer(url: previewURL)
                player?.play()
                if let currentlyPlayingIndexPath = currentlyPlayingIndexPath {
                    tableView.deselectRow(at: currentlyPlayingIndexPath, animated: true)
                }
                currentlyPlayingIndexPath = indexPath
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // Reload the table view data
        logTableView.reloadData()
        
    }
    
    func playPreview(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        player = AVPlayer(url: url)
        player?.play() // Start playing immediately
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        
    }
    
    
    @objc func handleRightSwipe(_ gesture: UISwipeGestureRecognizer) {
        if let cell = gesture.view as? SwipeLogTableViewCell, let indexPath = logTableView.indexPath(for: cell) {
            
            
            if indexPath == currentlyPlayingIndexPath {
                player?.pause()
                currentlyPlayingIndexPath = nil
            }
            
            
            var entry = swipedSongs[indexPath.row]
            if entry.action == .disliked {
                entry.action = .liked
                swipedSongs[indexPath.row] = entry
                logTableView.reloadRows(at: [indexPath], with: .fade)
            }
            logTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @objc func handleLeftSwipe(_ gesture: UISwipeGestureRecognizer) {
        if let cell = gesture.view as? SwipeLogTableViewCell, let indexPath = logTableView.indexPath(for: cell) {
            
            
            if indexPath == currentlyPlayingIndexPath {
                player?.pause()
                currentlyPlayingIndexPath = nil
            }
            
            
            var entry = swipedSongs[indexPath.row]
            if entry.action == .liked {
                entry.action = .disliked
                swipedSongs[indexPath.row] = entry
                logTableView.reloadRows(at: [indexPath], with: .fade)
            }
            logTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        if let indexPath = currentlyPlayingIndexPath {
            logTableView.deselectRow(at: indexPath, animated: true)
            currentlyPlayingIndexPath = nil
            
        }
    }
    
    
    func updatePlayingIndicator(at indexPath: IndexPath, isPlaying: Bool) {
        if let cell = logTableView.cellForRow(at: indexPath) as? SwipeLogTableViewCell {
            cell.playingIndicatorImageView?.image = isPlaying ? UIImage(named: "spotifyIconBlack") : nil
            print("updating icon")
        }
        
    }
    
    
}
