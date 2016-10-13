//
//  NewTweetViewController.m
//  TwitterClient
//
//  Created by Tomas Garrido on 10/11/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "NewTweetViewController.h"
#import "Tweet.h"

@interface NewTweetViewController ()
@property (weak, nonatomic) IBOutlet UITextView *tweetContent;
@property (weak, nonatomic) IBOutlet UILabel *characterCount;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tweetButton;


@end

@implementation NewTweetViewController
- (IBAction)tweetButton:(id)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tweetContent.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger len = textView.text.length + (text.length - range.length);
    if (len > 0 && len <=140) {
        self.tweetButton.enabled = true;
    } else {
        self.tweetButton.enabled = false;
    }
    self.characterCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)len];
    return  len <= 140;
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
        [self setPlaceHolderForField:textView];
    } else {
        self.tweetButton.enabled = true;
    }
    
}

-(void)setPlaceHolderForField:(UITextView *) textView {
    textView.text = @"Whats's happening...";
    textView.textColor = [UIColor lightGrayColor];
    textView.tag = 0;
    self.tweetButton.enabled = false;
}


#pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.
    [self.view endEditing:YES];
    if (self.tweetButton == sender) {
        self.tweet = [Tweet new];
        self.tweet.content = self.tweetContent.text;
    }
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
