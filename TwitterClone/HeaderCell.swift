//
//  HeaderCell.swift
//  TwitterClone
//
//  Created by Sam Wong on 09/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import UIKit


class HeaderCell : UIView {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var favouriteCount: UILabel!
    @IBOutlet weak var retweetCount: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // rounded image
//        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
//        self.profileImageView.layer.masksToBounds = true
        
        self.profileImageView.layer.borderWidth = 4.0
        self.profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.profileImageView.layer.cornerRadius = 10.0
        self.profileImageView.clipsToBounds = true
    }
    
}
