//
//  Tweet.swift
//  GeographyTweet
//
//  Created by Mehrdad Ahmadi on 2019-03-03.
//  Copyright © 2019 Mehrdad Ahmadi. All rights reserved.
//

import MapKit

struct User: Codable {
    var id: String
    var name: String
    var username: String
    var profileImg: String
    
    var profileImgURL: URL {
        return URL(string: profileImg)!
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case username = "screen_name"
        case profileImg = "profile_banner_url"
    }
}

struct BoundingBox: Codable {
    var coordinates: [[Double]]
    
    private enum CodingKeys: String, CodingKey {
        case coordinates
    }
}

struct Place: Codable {
    var id: String
    var name: String
    var boundingBox: BoundingBox
    
    var coordinates: (latitude: Double, longitude: Double) {
        var longSum: Double = 0
        var latSum: Double = 0
        for coord in boundingBox.coordinates {
            longSum += coord.first!
            latSum += coord.last!
        }
        let avgLat = latSum / Double(boundingBox.coordinates.count)
        let avgLong = longSum / Double(boundingBox.coordinates.count)
        
        return (latitude: avgLat, longitude: avgLong)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name = "full_name"
        case boundingBox = "bounding_box"
    }
}

struct ExtendedTweet: Codable {
    var fullContent: String
    
    private enum CodingKeys: String, CodingKey {
        case fullContent = "full_text"
    }
}

class Tweet: NSObject, Codable, MKAnnotation {
    
    // MARK: - Variables
    
    var createdAt: String
    var id: String
    var text: String
    var truncated: Bool
    
    var user: User
    var fullContent: ExtendedTweet
    var place: Place
    
    var date: Date {
        return HelperMethods.formatString(toDate: createdAt)
    }
    
    
    // MARK: - Codable
    
    private enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case id
        case text
        case truncated
        case place
        case user
        case fullContent = "extended_tweet"
    }
    
    
    // MARK: - Initializer
    
    required init(from decoder: Decoder) throws {
        let tweetValues = try decoder.container(keyedBy: CodingKeys.self)
        createdAt = try tweetValues.decode(String.self, forKey: .createdAt)
        id = try tweetValues.decode(String.self, forKey: .id)
        text = try tweetValues.decode(String.self, forKey: .text)
        truncated = try tweetValues.decode(Bool.self, forKey: .truncated)
        user = try tweetValues.decode(User.self, forKey: .user)
        fullContent = try tweetValues.decode(ExtendedTweet.self, forKey: .fullContent)
        place = try tweetValues.decode(Place.self, forKey: .place)
    }
    
    
    // MARK: - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D {
        get {
            let coord = CLLocationCoordinate2D(latitude: place.coordinates.latitude, longitude: place.coordinates.longitude)
            return coord
        }
    }
    
//    var title: String? {
//        get {
//            return username
//        }
//    }
}