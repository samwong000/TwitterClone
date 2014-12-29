//
//  SingleUserTweetsViewControler.swift
//  TwitterClone
//
//  Created by Sam Wong on 09/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import UIKit

class UserTimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var tweet : Tweet!
    var tweets : [Tweet]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Obj-C equivalent
        //Customerview *customView = [[[NSBundle] mainBundle] loadNibNamed: @"HeaderCell" owner:nil options: nil] lastObject];
        var headerView = NSBundle.mainBundle().loadNibNamed("HeaderCell", owner: self, options: nil).last as HeaderCell
        
        headerView.profileImageView.image = self.tweet.profileImage
        headerView.retweetCount.text = self.tweet.retweetCount.description
        headerView.favouriteCount.text = self.tweet.favouritesCount?.description
        
        //add headerView onto screen
        self.tableView.tableHeaderView?.addSubview(headerView)

        // Add user time line
        self.tableView.registerNib(UINib(nibName: "TweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TWEET_CELL")
        
        // make API call to get user time line
        NetworkController.sharedInstance.fetchUserTimeLine(tweet.userId, { (errorDescription, tweets) -> (Void) in
            if errorDescription != nil {
                // alert the user that something went wrong
            } else {
                self.tweets = tweets
                self.tableView.reloadData()
            }
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tweets != nil {
            return self.tweets!.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("TWEET_CELL", forIndexPath: indexPath) as TweetCell
        
        let tweet = self.tweets?[indexPath.row]
        
        cell.tweetLabel.text = tweet?.text
        
        if tweet?.profileImage != nil {
            cell.tweetImageView.image = tweet?.profileImage
        } else {
            //make asyn call
            NetworkController.sharedInstance.downloadUserImageForTweet(tweet!, completionHandler: { (image) -> (Void) in
                let cellForImage = self.tableView.cellForRowAtIndexPath(indexPath) as TweetCell?
                cellForImage?.tweetImageView.image = image
            })
        }
        
        return cell
    }


}
