//
//  APIService.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import Foundation

final class APIService {
    static let shared = APIService()
    
    private init() {}
    
    struct Constants {
        static let baseURL = "https://api.spotify.com/v1"
        static let albums = "/albums"
        static let categories = "/browse/categories"
        static let userProfile = "/me"
        static let playlists = "/playlists"
        static let newReleases = "/browse/new-releases"
        static let featuredPlaylists = "/browse/featured-playlists"
        static let recommendations = "/recommendations"
        static let genreRecommendations = "/recommendations/available-genre-seeds"
        static let search = "/search"
        static let getUserPlaylists = "/me/playlists"
        static let getUserAlbums = "/me/albums"
        static let addAlbumToLibrary = ""
    }
    
    enum HTTPMethod: String {
        case GET
        case PUT
        case POST
        case DELETE
    }
    
    enum APIError: Error {
        case failedToGetData
        case failedToDecodeData
        case failedToPutData
    }
    
    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
        AuthService.shared.withValidToken { token in
            guard let url = url else {
                return
            }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            completion(request)
        }
    }
    
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + Constants.userProfile), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return completion(.failure(APIError.failedToGetData))
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(UserProfile.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(APIError.failedToDecodeData))
                }
            }
            
            task.resume()
        }
    }
    
    public func getNewReleases(completion: @escaping ((Result<NewReleasesResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseURL + Constants.newReleases), type: HTTPMethod.GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return completion(.failure(APIError.failedToGetData))
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(NewReleasesResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(APIError.failedToDecodeData))
                }
            }
            
            task.resume()
        }
    }
    
    public func getFeaturedPlaylists(completion: @escaping ((Result<FeaturedPlaylistResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseURL + Constants.featuredPlaylists), type: HTTPMethod.GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return completion(.failure(APIError.failedToGetData))
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(FeaturedPlaylistResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(APIError.failedToDecodeData))
                }
            }
            
            task.resume()
        }
    }
    
    public func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetailsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + Constants.albums + "/\(album.id)"), type: HTTPMethod.GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return completion(.failure(APIError.failedToGetData))
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(AlbumDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(APIError.failedToDecodeData))
                }
            }
            
            task.resume()
        }
    }
    
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetailsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + Constants.playlists + "/\(playlist.id)"), type: HTTPMethod.GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return completion(.failure(APIError.failedToGetData))
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(PlaylistDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(APIError.failedToDecodeData))
                }
            }
            
            task.resume()
        }
    }
    
    public func getCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + Constants.categories), type: HTTPMethod.GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return completion(.failure(APIError.failedToGetData))
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(CategoriesResponse.self, from: data)
                    completion(.success(result.categories.items))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(APIError.failedToDecodeData))
                }
            }
            
            task.resume()
        }
    }
    
    public func getCategoryPlaylists(category: Category, completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + Constants.categories + "/\(category.id)/playlists"), type: HTTPMethod.GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return completion(.failure(APIError.failedToGetData))
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(FeaturedPlaylistResponse.self, from: data)
                    completion(.success(result.playlists.items))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(APIError.failedToDecodeData))
                }
            }
            
            task.resume()
        }
    }
    
    public func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void) {
        let type = [
            "album",
            "artist",
            "playlist",
            "track"
        ]
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        createRequest(
            with: URL(string: Constants.baseURL + Constants.search + "?limit=10&type=\(type.joined(separator: ","))&q=\(queryEncoded)"),
            type: HTTPMethod.GET) { request in
                let task = URLSession.shared.dataTask(with: request) { data, _, error in
                    guard let data = data, error == nil else {
                        return completion(.failure(APIError.failedToGetData))
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let result = try decoder.decode(SearchResponse.self, from: data)
                        
                        var searchResults: [SearchResult] = []
                        searchResults.append(contentsOf: result.albums.items.compactMap({ .album(model: $0 )}))
                        searchResults.append(contentsOf: result.artists.items.compactMap({ .artist(model: $0 )}))
                        searchResults.append(contentsOf: result.playlists.items.compactMap({ .playlist(model: $0 )}))
                        searchResults.append(contentsOf: result.tracks.items.compactMap({ .track(model: $0 )}))
                        
                        completion(.success(searchResults))
                    } catch {
                        print(error.localizedDescription)
                        completion(.failure(APIError.failedToDecodeData))
                    }
                }
                
                task.resume()
            }
    }
    
    // MARK: - Albums
    
    public func getCurrentUserAlbums(completion: @escaping (Result<[Album], Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + Constants.getUserAlbums),
            type: HTTPMethod.GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return completion(.failure(APIError.failedToGetData))
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(AlbumResponse.self, from: data)
                    completion(.success(result.items))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(APIError.failedToDecodeData))
                }
            }
            
            task.resume()
        }
    }
    
    public func addAlbumToLibrary(album: Album, completion: @escaping (Result<Bool, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + Constants.addAlbumToLibrary + "?ids=\(album.id)"),
            type: HTTPMethod.PUT
        ) { request in
            var request = request
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                guard error == nil else {
                    return completion(.failure(APIError.failedToGetData))
                }
                
                if let code = (response as? HTTPURLResponse)?.statusCode, code == 200 {
                    completion(.success(true))
                } else {
                    completion(.failure(APIError.failedToPutData))
                }
            }
            
            task.resume()
        }
    }
    
    // MARK: - Playlists
    
    public func getCurrentUserPlaylists(completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseURL + Constants.getUserPlaylists),
            type: HTTPMethod.GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return completion(.failure(APIError.failedToGetData))
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(PlaylistResponse.self, from: data)
                    completion(.success(result.items))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(APIError.failedToDecodeData))
                }
            }
            
            task.resume()
        }
    }
    
    public func createPlaylist(with name: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let profile):
                let urlString = Constants.baseURL + "/users/\(profile.id)/playlists"
                
                self?.createRequest(with: URL(string: urlString), type: .POST) { request in
                    var request = request
                    let json = [
                        "name": name
                    ]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                    
                    let task = URLSession.shared.dataTask(with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            return completion(.failure(APIError.failedToGetData))
                        }
                        
                        do {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let _ = try decoder.decode(Playlist.self, from: data)
                            completion(.success(true))
                        } catch {
                            print(error.localizedDescription)
                            completion(.failure(APIError.failedToDecodeData))
                        }
                    }
                    
                    task.resume()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    public func addTrackToPlaylist(track: Track, playlist: Playlist, completion: @escaping (Result<Bool, Error>) -> Void) {
        let urlString = Constants.baseURL + "/playlists/\(playlist.id)/tracks"
        
        createRequest(with: URL(string: urlString), type: .POST) { request in
            var request = request
            let json = [
                "uris": [
                    "spotify:track:\(track.id)"
                ]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return completion(.failure(APIError.failedToGetData))
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                        completion(.success(true))
                    } else {
                        completion(.failure(APIError.failedToGetData))
                    }
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(APIError.failedToDecodeData))
                }
            }
            
            task.resume()
        }
    }
    
    public func removeTrackFromPlaylist(track: Track, playlist: Playlist, completion: @escaping (Result<Bool, Error>) -> Void) {
        let urlString = Constants.baseURL + "/playlists/\(playlist.id)/tracks"
        
        createRequest(with: URL(string: urlString), type: .DELETE) { request in
            var request = request
            let json = [
                "tracks": [
                    [
                        "uri": "spotify:track:\(track.id)"
                    ]
                ]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    return completion(.failure(APIError.failedToGetData))
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                        completion(.success(true))
                    } else {
                        completion(.failure(APIError.failedToGetData))
                    }
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(APIError.failedToDecodeData))
                }
            }
            
            task.resume()
        }
    }
}
