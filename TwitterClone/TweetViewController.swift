//
//  SingleTweetViewController.swift
//  TwitterClone
//
//  Created by Sam Wong on 08/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController {

    var tweet : Tweet!
    
    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add SingleTweet xib
        var singleTweet = NSBundle.mainBundle().loadNibNamed("SingleTweet", owner: self, options: nil).last as SingleTweet
        
        singleTweet.profileImageView.image = self.tweet.profileImage
        singleTweet.retweetCount.text = self.tweet.retweetCount.description
        singleTweet.tweetTextView.text = self.tweet.text
        
        if self.tweet.favouritesCount == nil {
            NetworkController.sharedInstance.fetchTweetInfo(tweet, completionHandler: { (errorDescription, tweet) -> (Void) in
                if errorDescription != nil {
                    // alert the user that something went wrong
                } else {
                    self.tweet = tweet
                    singleTweet.favouriteCount.text = self.tweet.favouritesCount?.description
                }
            })
        } else {
            singleTweet.favouriteCount.text = tweet.favouritesCount?.description
        }
        
        // add gesture to the headerView's profielImageView control
        var imageTapRecognizer = UITapGestureRecognizer(target: self, action: "showUserTimeLineVC")
        singleTweet.profileImageView.addGestureRecognizer(imageTapRecognizer)
        
        //add headerView onto screen
        singleTweet.frame = self.containerView.frame
        self.containerView.addSubview(singleTweet)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showUserTimeLineVC() {
        // open main storyboard, click on the respective view controller -> inspector view -> set storyBoardID
        let destinationVC = self.storyboard?.instantiateViewControllerWithIdentifier("SingleUserTweetsVC") as UserTimeLineViewController
        
        destinationVC.tweet = self.tweet
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }

    
}
