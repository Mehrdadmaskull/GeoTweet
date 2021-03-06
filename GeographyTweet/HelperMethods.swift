//
//  HelperMethods.swift
//  GeographyTweet
//
//  Created by Mehrdad Ahmadi on 2019-03-07.
//  Copyright © 2019 Mehrdad Ahmadi. All rights reserved.
//

import Foundation

class HelperMethods {
    
    public enum DateFormatterType {
        case toString, toDate
    }
    
    static func dateFormat(type: DateFormatterType) -> DateFormatter {
        let df = dateFormatter
        switch type {
        case .toDate:
            df.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
        case .toString:
            df.dateFormat = "yyyy-MM-dd"
        }
        return df
    }
    
    static func prettyDateFormat(date: Date) -> String {
        let now = Date()
        let duration = DateInterval(start: date, end: now).duration
        switch duration {
        case 0..<60*60:
            return "\(Int(duration)/60)m"
        case 60*60..<60*60*24:
            return "\(Int(duration)/3600)h"
        default:
            let df = dateFormat(type: .toString)
            return df.string(from: date)
        }
    }
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        return dateFormatter
    }
    
    static func existingToken(_ type: TokenType) -> (bit: TokenBit, value: Bool) {
        switch type {
        case .bearer:
            let bearerToken = UserDefaults.standard.value(forKey: "hasBearerToken") as? Bool
            if bearerToken == nil || bearerToken! == false {
                return (bit: .failure, value: false)
            }
            return (bit: .bearer, value: true)
        case .oauth:
            let oauthToken = UserDefaults.standard.value(forKey: "hasOAuthToken") as? Bool
            if oauthToken == nil || oauthToken! == false {
                return (bit: .failure, value: false)
            }
            return (bit: .oauth, value: true)
        }
    }
    
    static func persistTweets(_ data: Data) {
            UserDefaults.standard.set(data, forKey: "TweetsData")
    }
    
    static func retrievePersistedTweets() -> [Tweet]? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormat(type: .toDate))
        var tweets: [Tweet]? = nil
        guard let tweetsData = UserDefaults.standard.value(forKey: "TweetsData") as? Data else { return tweets }
        do {
            tweets = try decoder.decode(APIResult.self, from: tweetsData).results
        }
        catch {
            print("Couldn't retrieve persisted tweets \n\(error)")
        }
        return tweets
    }
}

enum TokenType {
    case bearer
    case oauth
}

struct TokenBit: OptionSet {
    let rawValue: UInt8
    
    static let bearer = TokenBit(rawValue: 01 << 0)
    static let oauth = TokenBit(rawValue: 10 << 0)
    static let success = TokenBit(rawValue: 11 << 0)
    static let failure = TokenBit(rawValue: 00 << 0)
}
