//
//  TweetTableViewCell.m
//  TwitterClient
//
//  Created by Tomás Garrido Sandino on 10/10/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "TweetTableViewCell.h"
@interface TweetTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *tweetererLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetContentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tweetererPicture;

@end

@implementation TweetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
