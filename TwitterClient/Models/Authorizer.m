//
//  Authorizer.m
//  TwitterClient
//
//  Created by Tomas Garrido on 9/20/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "Authorizer.h"

@interface Authorizer()

@property(readonly, nonatomic) NSString * oauthBaseURL;
@property(readonly, nonatomic) NSString * oauthRequestTokenURL;


@end

@implementation Authorizer
@synthesize oauthRequestTokenURL = _oauthRequestTokenURL;
static const NSString* _oauthBaseURL = @"https://api.twitter.com/oauth/";

-(NSString *)oauthBaseURL {
    
}
    
-(NSString *)oauthRequestTokenURL {
    if (!_oauthRequestTokenURL) _oauthRequestTokenURL = [oauthBaseURL stringByAppendString:@"request_token"];
    return _oauthRequestTokenURL;
}
@end
