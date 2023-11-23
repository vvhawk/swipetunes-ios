//
//  SpotifyModels.swift
//  swipetunes
//
//  Created by Vasanth Banumurthy on 11/15/23.
//

import Foundation

// MARK: - RecommendationResponse
struct RecommendationResponse: Codable {
    let tracks: [DisplaySong]?
}

// MARK: - DisplaySong
struct DisplaySong: Codable {
    let name: String?
    let trackID: String?
    let artists: [Artist]?
    let album: Album?
    let previewURL: String?

    enum CodingKeys: String, CodingKey {
        case name
        case trackID = "id"
        case artists
        case album
        case previewURL = "preview_url"
    }

    var finalArtists: String? {
        artists?.map { $0.name }.joined(separator: ", ")
    }

    var albumCover: String? {
        album?.images?.first?.url
    }
}

// MARK: - Artist
struct Artist: Codable {
    let name: String
}

// MARK: - Album
struct Album: Codable {
    let images: [Image]?
}

// MARK: - Image
struct Image: Codable {
    let url: String
}


// MARK: - TopTracksResponse
struct TopTracksResponse: Codable {
    let items: [TopTrack]?
}

// MARK: - TopTrack
struct TopTrack: Codable {
    let id: String?
}

// MARK: - TopArtistsResponse
struct TopArtistsResponse: Codable {
    let items: [TopArtist]?
}

// MARK: - TopArtist
struct TopArtist: Codable {
    let id: String
    let genres: [String]  // Include this only if you plan to use genres for something else
}

enum SeedType {
    case tracks
    case artists
}
