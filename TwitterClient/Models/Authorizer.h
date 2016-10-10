//
//  Authorizer.h
//  TwitterClient
//
//  Created by Tomas Garrido on 9/20/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Authorizer : NSObject
@property(nonatomic, strong, readonly)NSError *lastError;


-(BOOL)isAuthorized;
-(void)test;
+(NSString *)percentEncode:(NSString *)stringToEncode;
-(void)authorize:(void(^)(void))completionHandler;
-(void)authorizeStep3:(NSString *)token completionHandler:(void(^)(void))completionHandler;
-(NSURL *)oauthAuthorizeURL;
@end
