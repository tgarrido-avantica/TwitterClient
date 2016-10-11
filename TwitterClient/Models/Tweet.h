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

@property(strong,readonly,nonatomic)NSString *content;
@property(strong, readonly, nonatomic) UIImage *picture;

- (instancetype)initWithDictionary:(NSDictionary *)tweet;
@end
