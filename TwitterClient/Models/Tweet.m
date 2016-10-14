//
//  Tweet.m
//  TwitterClient
//
//  Created by Tomás Garrido Sandino on 10/10/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "Tweet.h"

@interface Tweet()

@end

@implementation Tweet
- (instancetype)initWithDictionary:(NSDictionary *)tweet{
    self = [super init];
    self.content = tweet[@"text"];
    self.createdBy = tweet[@"user"][@"name"];
    self.pictureURLString = tweet[@"user"][@"profile_image_url_https"];
    self.createdAt = tweet[@"created_at"];
    self.idString = tweet[@"id_str"];
    self.userIdString = tweet[@"user"][@"id_str"];
    return self;
}
@end
