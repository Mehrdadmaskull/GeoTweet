//
//  TweetTableViewCell.swift
//  GeographyTweet
//
//  Created by Mehrdad Ahmadi on 2019-03-03.
//  Copyright © 2019 Mehrdad Ahmadi. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    
    // MARK: - Variables
    
    var tweet: Tweet! {
        didSet {
            distance.text = "10mi"
            username.text = tweet.user.username
            if let profileImg = tweet.user.profileImg {
                do {
                    profilePicture.image = try UIImage(data: Data(contentsOf: profileImg))
                }
                catch {
                    // TODO: Replace with a placeholder image
                    profilePicture.image = UIImage()
                }
            }
            date.text = tweet.createdAt
            content.text = tweet.fullContent?.fullContent ?? tweet.text
        }
    }
    // MARK: - IBOutlets
    
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var content: UILabel!
//    @IBOutlet weak var media: UILabel!
//    @IBOutlet weak var tweet: UILabel!
//    @IBOutlet weak var tweet: UILabel!
}
