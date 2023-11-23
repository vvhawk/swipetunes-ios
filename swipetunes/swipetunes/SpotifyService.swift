//
//  SpotifyService.swift
//  swipetunes
//
//  Created by Vasanth Banumurthy on 11/15/23.
//

import Foundation



class SpotifyService {
    static let shared = SpotifyService()

    func fetchTopTracks(accessToken: String, completion: @escaping (Result<TopTracksResponse, Error>) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/top/tracks?limit=5&offset=2")!
        //let url = URL(string: "https://api.spotify.com/v1/me/top/tracks?limit=6")!
        
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let topTracksResponse = try JSONDecoder().decode(TopTracksResponse.self, from: data)
                completion(.success(topTracksResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func getRecommendations(seeds: [String], seedType: SeedType, accessToken: String, completion: @escaping (Result<RecommendationResponse, Error>) -> Void) {
        
        //let seeds =seeds.joined(separator: ",")
        let joinedSeeds = seeds.joined(separator: ",")
        
        let seedParameter = (seedType == .tracks) ? "seed_tracks" : "seed_artists"
        
        //let url = URL(string: "https://api.spotify.com/v1/recommendations?seed_tracks=\(seeds)")!
        
        let url = URL(string: "https://api.spotify.com/v1/recommendations?\(seedParameter)=\(joinedSeeds)")!
        
        print("Fetching recommendations from URL: \(url)")
 

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching recommendations: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No data received for recommendations")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let recommendationsResponse = try JSONDecoder().decode(RecommendationResponse.self, from: data)
                print("Successfully fetched recommendations: \(recommendationsResponse.tracks?.count ?? 0) tracks")
                completion(.success(recommendationsResponse))
            } catch {
                print("Error decoding recommendations: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    func fetchTopArtists(accessToken: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/top/artists?limit=5")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                // Decode the JSON response to extract artist IDs
                let response = try JSONDecoder().decode(TopArtistsResponse.self, from: data)
                let artistIDs = response.items?.compactMap { $0.id } ?? []
                completion(.success(artistIDs))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

        
}
