//
//  NetworkController.swift
//  TwitterClone
//
//  Created by Sam Wong on 08/10/2014.
//  Copyright (c) 2014 21. All rights reserved.
//

import Foundation
import Accounts
import Social



class NetworkController {

    var imageCache = NSCache()
    var twitterAccount : ACAccount?
    let imageQueue = NSOperationQueue()
    // example can be found on http://www.raywenderlich.com/76341/use-nsoperation-nsoperationqueue-swift
    
    init () {
    }
    
    //singleton instantiation
//    class var controller: NetworkController {
//        //struct is less overhead in code
//        struct Static {
//            static var onceToken :dispatch_once_t = 0
//            static var instance : NetworkController? = nil
//        }
//        dispatch_once(&Static.onceToken) {
//            Static.instance = NetworkController()
//        }
//        return Static.instance!
//    }
    
    class var sharedInstance: NetworkController {
        struct Singleton {
            static let instance = NetworkController()
        }
        return Singleton.instance
    }
    
    
    func downloadUserImageForTweet(tweet: Tweet, completionHandler: (image: UIImage) -> (Void)) {
        //place the code in background thread
        self.imageQueue.addOperationWithBlock { () -> Void in
            
            var profileImage : UIImage?
            var data:NSData? = self.imageCache.objectForKey(tweet.profileImageURL) as? NSData
            
            //if the image data exists in cache
            if let goodData = data {
                //assign to the tweet object directly
                profileImage = UIImage(data: goodData)
            } else {
                //otherwise, load the image
                let url = NSURL(string: tweet.profileImageURL)
                let imageData = NSData(contentsOfURL: url!)
                profileImage = UIImage(data: imageData!)
                
                self.imageCache.setObject(imageData!, forKey: tweet.profileImageURL)
            }
                
            tweet.profileImage = profileImage
            
            //return to main thread
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(image: profileImage!)
            })
        }
    }
    
    func fetchTweetInfo (tweet : Tweet, completionHandler : (errorDescription : String?, tweet : Tweet?) -> (Void) ) {
        
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/show.json?id=" + tweet.id )
        let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil) // or parameters: ["id": tweet.id]
        
        twitterRequest.account = self.twitterAccount
        twitterRequest.performRequestWithHandler { (data, httpResponse, error) -> Void in
            if error == nil {
                switch httpResponse.statusCode {
                case 200...299:
                    //println(httpResponse)
                    let tweetInfo = Tweet.parseJSONDataIntoSingleTweet(data, tweet: tweet)
                    
                    // we have to return to main thread to reload the data
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        completionHandler(errorDescription: nil, tweet: tweetInfo)
                    })
                case 400...499:
                    //println("clients fault")
                    println(httpResponse)
                case 500...599:
                    println("servers fault")
                default: println("something bad happened")
                    
                }
            }
        }
    }
    
    func fetchUserTimeLine (userId : String, completionHander: (errorDescription : String?, tweets: [Tweet]?) -> (Void) ) {
        
        //https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=twitterapi&count=2
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json?user_id=" + userId)
        let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil) // or parameters: ["user_id": tweet.id]
        
        twitterRequest.account = self.twitterAccount
        twitterRequest.performRequestWithHandler { (data, httpResponse, error) -> Void in
            if error == nil {
                switch httpResponse.statusCode {
                case 200...299:
                    println(data)
                    let tweetInfo = Tweet.parseJSONDataIntoTweets(data)
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        completionHander(errorDescription: nil, tweets: tweetInfo)
                    })
                case 400...499:
                    //println("clients fault")
                    println(httpResponse)
                case 500...599:
                    println("servers fault")
                default: println("something bad happened")
                }
            }
        }
    }
    
    func fetchHomeLine (sinceID : String?, maxID : String?, completionHandler : (errorDescription : String?, tweets : [Tweet]?) -> (Void) ) {
        
        var parameter : String?
        var twitterRequest : SLRequest!
        
        //first time connection to Twitter account
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        //this is an async process running on background thread (managed by Apple Thread API), it may take time to come back
        accountStore.requestAccessToAccountsWithType(accountType, options: nil, {
            (granted : Bool, error : NSError!) -> Void in
            
            //first closure expression to access twitter account
            if granted {
                //accountType is a local variable, closure block capturing keeps it alive
                let accounts = accountStore.accountsWithAccountType(accountType)
                
                self.twitterAccount = accounts.first as ACAccount?
                
                // Setup Twitter Request
                //the api URL can be found on http://dev.twitter.com/rest
                var urlString : String
                
                if sinceID != nil {
                    urlString = "https://api.twitter.com/1.1/statuses/home_timeline.json?since_id=" + sinceID!
                } else if maxID != nil {
                    urlString = "https://api.twitter.com/1.1/statuses/home_timeline.json?max_id=" + maxID!
                } else {
                    urlString = "https://api.twitter.com/1.1/statuses/home_timeline.json"
                }
                
                let url = NSURL(string: urlString)
                
                let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil)
                twitterRequest.account = self.twitterAccount
                
                //if network connection fails, please check the Twitter simulator setting
                twitterRequest.performRequestWithHandler({(data, httpResponse, error) -> Void in
                    
                    if error == nil {
                        switch httpResponse.statusCode {
                        case 200...299:
                            // we are on a background queue aka thread (it happens in performRequestWithHandler func)
                            println("good")
                            let tweets = Tweet.parseJSONDataIntoTweets(data)
                            println(tweets?.count)
                            
                            // we have to return to main thread to reload the data
                            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                completionHandler(errorDescription: nil, tweets: tweets)
                            })
                            
                        case 400...499:
                            println("clients fault")
                            println(httpResponse)
                        case 500...599:
                            println("servers fault")
                        default: println("something bad happened")
                            
                        }
                    }
                    
                })
                
            }
        })

    }
}