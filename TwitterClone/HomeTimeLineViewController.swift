//
//  HomeTimeLineViewController.swift
//  TwitterClone
//
//  Created by Sam Wong on 06/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import UIKit
import Accounts
import Social

class HomeTimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // create an empty tweets array
    //var sinceId : String?
    var tweets : [Tweet]?
    var twitterAccount : ACAccount?
    var refreshControl:UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //use TweetCell.xib, MUST add this code
        self.tableView.registerNib(UINib(nibName: "TweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TWEET_CELL")
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 68.0;
        
        NetworkController.sharedInstance.fetchHomeLine(nil, maxID: nil, { (errorDescription, tweets) -> (Void) in
            if errorDescription != nil {
                // alert the user that something went wrong
            } else {
                if tweets != nil {
                    self.tweets = tweets
                    self.tableView.reloadData()
                }
            }
        })
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Release to refresh")
        self.refreshControl.addTarget(self, action: "fetchNewHomeLine:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        //add twitter icon to navigation bar
        let image = UIImage(named: "tweeterIcon.ico")
        self.navigationController?.navigationBar.topItem?.titleView = UIImageView(image: image)

    }
    
    func fetchNewHomeLine(sender:AnyObject)
    {
        let tweet = self.tweets?[0]
        
        //refresh new homeline with send_id param
        NetworkController.sharedInstance.fetchHomeLine(tweet!.id, maxID: nil, { (errorDescription, tweets) -> (Void) in
            if errorDescription != nil {
                // alert the user that something went wrong
                println(errorDescription)
            } else {
                //if new tweets contains data
                if tweets != nil {
                    self.tweets = self.tweets! + tweets!
                    self.tableView.reloadData()
                }
            }
        })
        
        self.refreshControl.endRefreshing()
    }

    // this func gets triggered when user clicks on the row
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // open main storyboard, click on the respective view controller -> inspector view -> set storyBoardID
        let destinationVC = self.storyboard?.instantiateViewControllerWithIdentifier("SingleTweetVC") as TweetViewController
        let tweet = self.tweets?[indexPath.row]
        destinationVC.tweet = tweet
        
        self.navigationController?.pushViewController(destinationVC, animated: true)
        
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

    //infinite scrolling
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == (tweets!.count - 1) {
            let tweet = self.tweets?.last
            NetworkController.sharedInstance.fetchHomeLine(nil, maxID: tweet?.id, { (errorDescription, tweets) -> (Void) in
                if errorDescription != nil {
                    println(errorDescription)
                } else {
                    var newTweets = tweets!
                    //Need to remove the first tweet to get rid of repeat
                    let removeRepeatedFirstTweet = newTweets.removeAtIndex(0)
                    for newTweet in newTweets {
                        self.tweets?.append(newTweet)
                    }
                    self.tableView.reloadData()
                }
            })
        }
    }
    
}
