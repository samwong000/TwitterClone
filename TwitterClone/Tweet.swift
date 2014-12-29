//
//  Tweet.swift
//  TwitterClone
//
//  Created by Sam Wong on 06/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

// foundation object of iOS

// UIKit covers foundation, so it is a good practise to import UIKit
import UIKit

class Tweet {
    
    var text : String
    var id : String
    var profileImageURL : String
    var profileImage : UIImage?
    var userName : String
    var retweetCount : Int
    var favouritesCount : Int?
    var userId : String
    var profileBackgroundURL : String
    var profileBackgroundImage : UIImage?

    init(tweetInfo : NSDictionary ) {
        //declare userInfo dictionary var
        var tweetUserInfo = tweetInfo["user"] as NSDictionary
        self.text = tweetInfo["text"] as String
        self.id = tweetInfo["id_str"] as String
        self.retweetCount = tweetInfo["retweet_count"] as Int
        self.userName = tweetUserInfo["name"] as String
        self.profileImageURL = tweetUserInfo["profile_image_url_https"] as String
        self.userId = tweetUserInfo["id_str"] as String
        self.profileBackgroundURL = tweetUserInfo["profile_background_image_url"] as String
    }
    
    class func parseJSONDataIntoSingleTweet(rawJSONData : NSData, tweet : Tweet) -> Tweet {
        var error: NSError?
        
        if let tweetDictionary = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSDictionary {
            tweet.favouritesCount = tweetDictionary["favorite_count"] as? Int
        }
        return tweet
    }
    
    class func parseJSONDataIntoTweets(rawJSONData : NSData ) -> [Tweet]? {
        var error : NSError?
        if let JSONArray = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSArray {
            
            //using JSON sort method
            //            var descriptor: NSSortDescriptor = NSSortDescriptor(key: "text", ascending: true)
            //            var sortedJSONArray: NSArray = JSONArray.sortedArrayUsingDescriptors([descriptor])
            
            // constructor to initialise a new tweets array object
            var tweets = [Tweet]()
            //println(tweets[0])
            for JSONDictionary in JSONArray {
                if let tweetDictionary = JSONDictionary as? NSDictionary {
                    var newTweet = Tweet(tweetInfo: tweetDictionary)
                    tweets.append(newTweet)
                }
            }
            
            //using array sort method
            //tweets.sort{$1.text > $0.text}
            //println(tweets[0])
            return tweets
        }
        return nil
    }
    
}
