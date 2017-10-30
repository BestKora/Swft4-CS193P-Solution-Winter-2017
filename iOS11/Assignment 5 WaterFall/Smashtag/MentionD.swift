//
//  MensionD.swift
//  Smashtag
//
//  Created by Tatiana Kornilova on 5/31/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class MentionD: NSManagedObject {
    static func findOrCreateMention(withKeyword keyword: String,
                                    andType type: String,
                                    andTerm searchTerm: String,
                                    in context: NSManagedObjectContext) throws -> MentionD
    {
        let request : NSFetchRequest<MentionD> = MentionD.fetchRequest()
        //keyword, searchTerm and type is the unique identifier
        request.predicate = NSPredicate(format: "keyword LIKE[cd] %@ AND searchTerm =[cd] %@",
                                                                          keyword, searchTerm)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert (matches.count == 1, "mension,findorcreatemension -- database inconsistency")
                return matches[0]
            } else {
                let mention = MentionD (context: context)
                mention.count = 0
                mention.keyword = keyword.lowercased()
                mention.searchTerm = searchTerm
                mention.type = type
                return mention
            }
        }
        catch {
            throw error
        }
    }
    
    static func checkMention(for tweet: TweetD,
                                    withKeyword keyword: String,
                                    andType type: String,
                                    andTerm searchTerm: String,
                                    in context: NSManagedObjectContext) throws -> MentionD
    {
        do {
            let mention = try findOrCreateMention(withKeyword:keyword,
                                               andType: type,
                                               andTerm: searchTerm,
                                               in: context)
            
            if let tweetsSet = mention.tweets as? Set<TweetD>, !tweetsSet.contains(tweet) {
                mention.addToTweets(tweet)
                mention.count =  Int32((mention.count) + 1)
            }
            return mention
            
        } catch {
            throw error
        }
    }
    
}
