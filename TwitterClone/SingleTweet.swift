//
//  SingleTweet.swift
//  TwitterClone
//
//  Created by Sam Wong on 12/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import UIKit

class SingleTweet: UIView {
    
    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var favouriteCount: UILabel!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.profileImageView.layer.borderWidth = 4.0
        self.profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.profileImageView.layer.cornerRadius = 10.0
        self.profileImageView.clipsToBounds = true
        
    }
    
}