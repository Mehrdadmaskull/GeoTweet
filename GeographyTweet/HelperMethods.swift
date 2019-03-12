//
//  HelperMethods.swift
//  GeographyTweet
//
//  Created by Mehrdad Ahmadi on 2019-03-07.
//  Copyright © 2019 Mehrdad Ahmadi. All rights reserved.
//

import Foundation

class HelperMethods {
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ""
        return dateFormatter
    }
    
    static func formatString(toDate: String) -> Date {
        return dateFormatter.date(from: toDate)!
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
