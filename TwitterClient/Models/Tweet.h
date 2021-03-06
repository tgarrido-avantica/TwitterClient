//
//  Tweet.h
//  TwitterClient
//
//  Created by Tomás Garrido Sandino on 10/10/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tweet : NSObject

@property(strong, readwrite,nonatomic)NSString *content;
@property(strong, readwrite, nonatomic) UIImage *picture;
@property(strong, readwrite, nonatomic) NSString *pictureURLString;
@property(strong, readwrite, nonatomic) NSString *createdBy;
@property(strong, readwrite, nonatomic) NSString *createdAt;
@property(strong, readwrite, nonatomic) NSString *idString;
@property(strong, readwrite, nonatomic) NSString *userIdString;

- (instancetype)initWithDictionary:(NSDictionary *)tweet;
@end
