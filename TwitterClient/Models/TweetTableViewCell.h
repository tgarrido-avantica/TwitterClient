//
//  TweetTableViewCell.h
//  TwitterClient
//
//  Created by Tomás Garrido Sandino on 10/10/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *tweetererLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tweetererPicture;
@property (weak, nonatomic) IBOutlet UITextView *tweetContent;

@end
