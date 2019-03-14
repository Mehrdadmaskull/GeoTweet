//
//  NetworkManager.swift
//  GeographyTweet
//
//  Created by Mehrdad Ahmadi on 2019-03-04.
//  Copyright © 2019 Mehrdad Ahmadi. All rights reserved.
//

import Foundation
import Alamofire
import OAuthSwift

class NetworkManager {
    
    // MARK: - Variables
    
    private static let apiURL = URL(string: "https://api.twitter.com/")!
    private static let archivePath = "1.1/tweets/search/fullarchive/Dev.json"
    //?query=point_radius:[-73.578593 45.496896 20mi]&maxResults=10"
    
    private static var oauth: OAuth1Swift!
    private static var oauthToken: String?
    private static var oauthTokenSecret: String?
    private static var userID: String?
    private static var username: String?
    
    private static var bearerToken: String?
    
    
    // MARK: - Methods

    static func oauthTwitter() {
        oauth = OAuth1Swift(consumerKey: AppConfig.consumerKey, consumerSecret: AppConfig.secretKey, requestTokenUrl: AppConfig.tokenURL, authorizeUrl: AppConfig.authorizeURL, accessTokenUrl: AppConfig.accessTokenURL)
        
        oauth.authorizeURLHandler = TwitterOAuthViewController()
        
        let _ = oauth.authorize(withCallbackURL: AppConfig.callbackURL, success: { (credential, response, params) in
            self.oauthToken = credential.oauthToken
            self.oauthTokenSecret = credential.oauthTokenSecret
            self.userID = params["user_id"] as? String
            self.username = params["screen_name"] as? String
            
            do {
                let oauthItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "oauthToken")
                let oauthSecretItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "oauthTokenSecret")
                
                try oauthItem.savePassword(credential.oauthToken)
                try oauthSecretItem.savePassword(credential.oauthTokenSecret)
                
                UserDefaults.standard.set(true, forKey: "hasOAuthToken")
            }
            catch {
                print("Error saving to keychain\n\(error)\n\(error.localizedDescription)")
            }
            
            print("Got the access token \(credential.oauthToken)")
            print("Got the access secret \(credential.oauthTokenSecret)")
            
        }) { (error) in
            print("Error happened in OAuth \(error)\n\(error.localizedDescription)")
        }
    }
    
    static func basicAuthTwitter() {
        let api = "\(AppConfig.consumerKey):\(AppConfig.secretKey)"
        let apiBase64 = api.data(using: .utf8)!.base64EncodedString()
        let bearerURL = apiURL.appendingPathComponent("oauth2/token")
        
        let authorization = "Basic ".appending(apiBase64)
        
        let headers: HTTPHeaders = ["Authorization": authorization, "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"]
        let params: Parameters = ["grant_type": "client_credentials"]
        
        Alamofire.request(bearerURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in

            if response.result.isSuccess, response.response?.statusCode == 200, let data = response.data {
                do {
                    guard let object = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: String] else { return }
                    if object["token_type"] == "bearer" {
                        bearerToken = object["access_token"]
                        
                        do {
                            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "bearerToken")
                            try passwordItem.savePassword(bearerToken!)
                            print("Got the bearer token \(bearerToken!)")
                            UserDefaults.standard.set(true, forKey: "hasBearerToken")
                        }
                        catch {
                            print("Error saving to keychain\n\(error)\n\(error.localizedDescription)")
                        }
                    }
                }
                catch {
                    print("Error happened \(error)\n\(error.localizedDescription)")
                }
            }
            else {
                print("Response was \(response)")
            }
        }
    }
    
    static func retrieveRecentTweets(latitude: Double, longitude: Double, radius: Int, keyword: String? = nil, maxResults: Int = 10, completion: @escaping ([Tweet]) -> Void) {
        checkForExistingToken(.bearer)
//        var urlPath = "\(archivePath)?query="
//        if let keyword = keyword {
//            urlPath.append("\((keyword)) ")
//        }
//        urlPath.append("point_radius:[\(longitude) \(latitude) \(radius)&maxResults=\(maxResults)")

        var query = ""
        if let keyword = keyword {
            query.append("\((keyword)) ")
        }
        query.append("point_radius:[\(longitude) \(latitude) \(radius)mi]")
        let params: Parameters = ["query": query, "maxResults": maxResults]
        
        let fullArchiveURL = apiURL.appendingPathComponent(archivePath)
        
        guard let bearerToken = bearerToken else { return }
        let header: HTTPHeaders = ["Authorization": "Bearer \(bearerToken)"]

        Alamofire.request(fullArchiveURL, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: header).responseJSON { (responseData) in
            
            guard let response = responseData.response, responseData.result.isSuccess, let data = responseData.data else {
                print("An error happened retrieving tweets\n\(responseData.error)\(responseData.error?.localizedDescription)")
                return
            }
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .formatted(HelperMethods.dateFormat(type: .toDate))
            do {
                let tweets = try jsonDecoder.decode(APIResult.self, from: data).results
                completion(tweets)
            }
            catch {
                print("Error happened during decoding\n\(error)\(error.localizedDescription)")
            }
        }
    }
    
    private static func checkForExistingToken(_ type: TokenType) {
        switch type {
        case .bearer:
            if bearerToken == nil {
                if !HelperMethods.existingToken(type) {
                    basicAuthTwitter()
                }
                else {
                    do {
                        let bearerItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "bearerToken")
                        bearerToken = try bearerItem.readPassword()
                    }
                    catch {
                        print("There was an error retrieving bearerToken from Keychain\n\(error)")
                    }
                }
            }
        case .oauth:
            if bearerToken == nil {
                if !HelperMethods.existingToken(type) {
                    oauthTwitter()
                }
                else {
                    do {
                        let oauthItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "oauthToken")
                        let oauthSecretItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "oauthTokenSecret")
                        
                        oauthToken = try oauthItem.readPassword()
                        oauthTokenSecret = try oauthSecretItem.readPassword()
                    }
                    catch {
                        print("There was an error retrieving bearerToken from Keychain\n\(error)")
                    }
                }
            }
        }
    }
}
