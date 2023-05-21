//
//  AuthService.swift
//  Spotify
//
//  Created by jake on 2/15/23.
//

import Foundation

final class AuthService {
    static let shared = AuthService()
    
    private struct Constants {
        static let clientID = "9be7c6ec8c47414099e53923c360de38"
        static let clientSecret = "750eecb6a428486d899c47a0a5bc02ff"
        static let authorize = "https://accounts.spotify.com/authorize"
        static let accessToken = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://www.jakecgardner.com"
        static let scopes = [
            "playlist-read-private",
            "playlist-modify-private",
            "user-follow-read",
            "user-library-modify",
            "user-library-read",
            "user-read-email",
            "user-read-private"
        ].joined(separator: "%20")
    }
    
    private init() {}
    
    private var isRefreshingToken: Bool = false
    
    public var signInURL: URL? {
        let redirectURI = Constants.redirectURI
        let base = Constants.authorize
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scopes)&redirect_uri=\(redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expiration_date") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    public func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: Constants.accessToken) else {
            return completion(false)
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let basicToken = Constants.clientID + ":" + Constants.clientSecret
        guard let encodedToken = basicToken.data(using: .utf8)?.base64EncodedString() else {
            print("base64 encoding failed")
            return completion(false)
        }
        request.setValue("Basic \(encodedToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return completion(false)
            }
            
            do {
                let decoded = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: decoded)
                completion(true)
            } catch {
                print(error)
                completion(false)
            }
        }
        
        task.resume()
    }
    
    private func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refreshToken = result.refresh_token {
            UserDefaults.standard.setValue(refreshToken, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expiration_date")
    }
    
    private func refreshIfNeeded(completion: @escaping (Bool) -> Void) {
        guard shouldRefreshToken else {
            return completion(true)
        }
        
        guard let refreshToken = self.refreshToken else {
            return completion(true)
        }
        
        guard let url = URL(string: Constants.accessToken) else {
            return completion(false)
        }
        
        isRefreshingToken = true
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = components.query?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let basicToken = Constants.clientID + ":" + Constants.clientSecret
        guard let encodedToken = basicToken.data(using: .utf8)?.base64EncodedString() else {
            print("base64 encoding failed")
            return completion(false)
        }
        request.setValue("Basic \(encodedToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            self?.isRefreshingToken = false
            
            guard let data = data, error == nil else {
                return completion(false)
            }
            
            do {
                let decoded = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: decoded)
                
                self?.onRefreshHandlers.forEach({ $0(decoded.access_token) })
                self?.onRefreshHandlers.removeAll()
                
                completion(true)
            } catch {
                print(error)
                completion(false)
            }
        }
        
        task.resume()
    }
    
    private var onRefreshHandlers: [((String) -> Void)] = []
    
    public func withValidToken(completion: @escaping (String) -> Void) {
        guard !isRefreshingToken else {
            onRefreshHandlers.append(completion)
            return
        }
        
        if shouldRefreshToken {
            refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
            }
        } else if let token = self.accessToken {
            completion(token)
        }
    }
    
    public func signOut(completion: (Bool) ->Void) {
        UserDefaults.standard.setValue(nil, forKey: "access_token")
        UserDefaults.standard.setValue(nil, forKey: "refresh_token")
        UserDefaults.standard.setValue(nil, forKey: "expiration_date")
        completion(true)
    }
}
