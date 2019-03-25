//
//  TweetTableViewCell.swift
//  GeographyTweet
//
//  Created by Mehrdad Ahmadi on 2019-03-03.
//  Copyright © 2019 Mehrdad Ahmadi. All rights reserved.
//

import UIKit
import AlamofireImage

class TweetTableViewCell: UITableViewCell {
    
    
    // MARK: - Variables
    
    var tweet: Tweet! {
        didSet {
            username.text = "@\(tweet.user.username)"
            name.text = tweet.user.name
            if let profileImg = tweet.user.profileImg {
                profilePicture.af_setImage(withURL: profileImg, placeholderImage: nil, filter: nil, progress: nil, progressQueue: .global(qos: .background), imageTransition: .crossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)
            }
            date.text = HelperMethods.prettyDateFormat(date: tweet.createdAt)
            content.text = tweet.fullContent?.fullContent ?? tweet.text
        }
    }
    // MARK: - IBOutlets
    
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var content: UILabel!
//    @IBOutlet weak var media: UILabel!
}
