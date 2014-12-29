//
//  TweetCell.swift
//  TwitterClone
//
//  Created by Sam Wong on 07/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
  
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var tweetLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // rounded corner
        tweetImageView.layer.cornerRadius = 9.0
        tweetImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
