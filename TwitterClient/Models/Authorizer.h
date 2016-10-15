//
//  Authorizer.h
//  TwitterClient
//
//  Created by Tomas Garrido on 9/20/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet.h"
#import "TweetTableViewCell.h"
#import "TweetTableViewController.h"

@interface Authorizer : NSObject
@property(nonatomic, strong, readonly)NSError *lastError;


-(BOOL)isAuthorized;
-(void)test;
+(NSString *)percentEncode:(NSString *)stringToEncode;
-(void)authorize:(void(^)(void))completionHandler;
-(void)authorizeStep3:(NSString *)token completionHandler:(void(^)(void))completionHandler;
-(NSURL *)oauthAuthorizeURL;

-(NSArray *)getTweetsWithMaxId:(NSString *)maxId sinceId:(NSString *)sinceId;
-(void)createTweet:(Tweet *)tweet sourceController:(TweetTableViewController *)source;
-(void)loadPictureOfTweet:(Tweet *)tweet cell:(TweetTableViewCell *)cell photoCache:(NSMutableDictionary *)photoCache;
@end
