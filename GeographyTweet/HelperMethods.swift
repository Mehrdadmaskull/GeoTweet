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
    
    static func existingToken(_ type: TokenType) -> Bool {
        switch type {
        case .bearer:
            let bearerToken = UserDefaults.standard.value(forKey: "hasBearerToken") as? Bool
            if bearerToken == nil || bearerToken! == false {
                return false
            }
        case .oauth:
            let oauthToken = UserDefaults.standard.value(forKey: "hasOAuthToken") as? Bool
            if oauthToken == nil || oauthToken! == false {
                return false
            }
        }
        return true
    }
}

enum TokenType {
    case bearer
    case oauth
}
