//
//  NewTweetViewController.m
//  TwitterClient
//
//  Created by Tomas Garrido on 10/11/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "NewTweetViewController.h"

@interface NewTweetViewController ()
@property (weak, nonatomic) IBOutlet UITextView *tweetContent;
@property (weak, nonatomic) IBOutlet UILabel *characterCount;

@end

@implementation NewTweetViewController
- (IBAction)tweetButton:(id)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= 140;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if(textView.tag == 0) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
        textView.tag = 1;
    }
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if([textView.text length] == 0)
    {
        textView.text = @"Foobar placeholder";
        textView.textColor = [UIColor lightGrayColor];
        textView.tag = 0;
    }
}

@end
