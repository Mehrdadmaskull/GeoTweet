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
}
