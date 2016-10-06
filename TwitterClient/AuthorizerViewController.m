//
//  AuthorizerViewController.m
//  TwitterClient
//
//  Created by Tomas Garrido on 10/4/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "AuthorizerViewController.h"
#import <WebKit/WebKit.h>
#import "ModalStatusViewController.h"
#import "Utilities.h"
#import "Authorizer.h"

@interface AuthorizerViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *webView;

@property (weak, nonatomic) IBOutlet UITextField *pinField;

@property (strong, nonatomic) ModalStatusViewController *statusController;
@end

@implementation AuthorizerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
 }

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    Authorizer *authorizer = [Utilities authorizer];
    if (!authorizer.isAuthorized) {
        self.statusController = [Utilities showStatusModalWithMessage:@"Authenticating" source:self];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[Utilities authorizer] authorize:^ {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self authorizationStep2];
                });
            }];
        });
    }
    

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

- (void) authorizationStep2 {
    [self.statusController dismissViewControllerAnimated:NO completion:nil];
    Authorizer *authorizer = [Utilities authorizer];
    if (authorizer.isAuthorized) {
        NSURL *url=[authorizer oauthAuthorizeURL];
        NSURLRequest *request=[NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}
@end
