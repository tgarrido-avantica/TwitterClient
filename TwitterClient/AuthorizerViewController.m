//
//  AuthorizerViewController.m
//  TwitterClient
//
//  Created by Tomas Garrido on 10/4/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "AuthorizerViewController.h"
#import <WebKit/WebKit.h>
@interface AuthorizerViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation AuthorizerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url=[NSURL URLWithString:@"https://api.twitter.com/oauth/authenticate"];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
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

@end
