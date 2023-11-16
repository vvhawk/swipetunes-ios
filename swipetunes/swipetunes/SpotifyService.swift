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

    func getRecommendations(seedTracks: [String], accessToken: String, completion: @escaping (Result<RecommendationResponse, Error>) -> Void) {
        let seeds = seedTracks.joined(separator: ",")
        let url = URL(string: "https://api.spotify.com/v1/recommendations?seed_tracks=\(seeds)")!

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
                let recommendationsResponse = try JSONDecoder().decode(RecommendationResponse.self, from: data)
                completion(.success(recommendationsResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}
