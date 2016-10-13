//
//  NewTweetViewController.h
//  TwitterClient
//
//  Created by Tomas Garrido on 10/11/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface NewTweetViewController : UIViewController <UITextViewDelegate>
@property(strong, nonatomic) Tweet *tweet;
@end
