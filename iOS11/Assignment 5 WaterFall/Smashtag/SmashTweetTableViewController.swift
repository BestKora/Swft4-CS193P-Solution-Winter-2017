//
//  SmashTweetTableViewController.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 5/29/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class SmashTweetTableViewController: TweetTableViewController {
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    override func insertTweets(_ newTweets: [Tweet]){
        super.insertTweets(newTweets)
        if searchText != nil {
        updateDatabase(with: newTweets)
        }
    }
    
    private func updateDatabase(with tweets: [Tweet]){
            container?.performBackgroundTask{ [weak self] (context) in
  // one by one
 /*           for twitterInfo in tweets {
                //add tweet
               _ = try? TweetD.findTweetAndCheckMentions(for: twitterInfo,
                                                         with: (self?.searchText)!,
                                                         in: context)
            }
 */
// all more effective
                try? TweetD.newTweets(for: tweets,
                                     with: (self?.searchText)!,
                                     in: context)
    
            try? context.save()
            self?.printDatabaseStatistics()
        }
    }
    
    private func printDatabaseStatistics(){
        //on the main queue context
        if let context = container?.viewContext{
            context.perform{
                if let tweetCount = ( try? context.fetch( TweetD.fetchRequest()
                                                    as NSFetchRequest<TweetD> ))?.count{
                    print("\(tweetCount) tweets")
                }
                if let mentionsCount =  try? context.count(for: MentionD.fetchRequest()){
                    print ("\(mentionsCount) mentions")
                }
            }
        }
    }
 }
