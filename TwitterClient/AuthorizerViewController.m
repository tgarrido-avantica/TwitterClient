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
#import "TweetTableViewController.h"

typedef enum direction
{
    UP,
    DOWN
} Direction;


@interface AuthorizerViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *pinField;
@property (strong, nonatomic) ModalStatusViewController *statusController;
@property (weak, nonatomic) IBOutlet UIView *pinView;
@end

@implementation AuthorizerViewController {
    // Instance variables
    UITextField *activeField;
    CGFloat previousYPosition;
    BOOL firstTime;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.webView.delegate = self;
    self.pinField.delegate = self;
    [self registerForKeyboardNotifications];
    
    firstTime = YES;
 }

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    Authorizer *authorizer = [Utilities authorizer];
    if (!authorizer.isAuthorized && firstTime) {
        firstTime = NO;
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
    self.statusController = nil;
    Authorizer *authorizer = [Utilities authorizer];
    if (authorizer.isAuthorized) {
        NSURL *url=[authorizer oauthAuthorizeURL];
        NSURLRequest *request=[NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    } else {
        NSString* errorString = [NSString stringWithFormat:@"<html><center><font size=+5 color='red'>"
                                 "An error occurred getting authorization:<br>%@</font></center></html>",
                                 authorizer.lastError.localizedDescription];
        [self.webView loadHTMLString:errorString baseURL:nil];
    }
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // starting the load, show the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString *documentContent = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('oauth_pin').outerHTML"];
    NSLog(@"\n------------------------\n%@", documentContent);
    Authorizer *authorizer = [Utilities authorizer];
    if (authorizer.isAuthorized) {
        if ([documentContent length] > 0) {
            // Extract pin
            NSRange range = [documentContent rangeOfString:@"<code>"];
            if (range.location != NSNotFound) {
                NSString *pin = [documentContent substringWithRange:NSMakeRange(range.location + range.length, 7)];
                self.pinField.text = pin;
            }
            self.pinView.hidden = NO;
        }
        
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // load error, hide the activity indicator in the status bar
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // report the error inside the webview
    NSString* errorString = [NSString stringWithFormat:@"<html><center><font size=+5 color='red'>"
                             "An error occurred loading response:<br>%@</font></center></html>",
                             error.localizedDescription];
    [self.webView loadHTMLString:errorString baseURL:nil];
}

#pragma mark - Keyboard handling
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    if (activeField == self.pinField) {
        [self moveKeyboardWithDirection:UP notification:aNotification];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self moveKeyboardWithDirection:DOWN notification:aNotification];
}

- (void)moveKeyboardWithDirection:(Direction)direction notification:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGRect bkgndRect = activeField.superview.frame;

    if (direction == UP) {
        previousYPosition = bkgndRect.origin.y;
        bkgndRect.origin.y -= kbSize.height;
        UIScrollView *webScrollView = self.webView.scrollView;
        [webScrollView scrollRectToVisible:CGRectMake(webScrollView.contentSize.width - 1, webScrollView.contentSize.height - 1, 1, 1) animated:YES];
    } else {
        bkgndRect.origin.y = previousYPosition;
    }
    [activeField.superview setFrame:bkgndRect];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

#pragma mark Authorization last step
- (IBAction)continueButton:(UIButton *)sender {
    [self.pinField resignFirstResponder];
    self.statusController = [Utilities showStatusModalWithMessage:@"Confirming pin" source:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Utilities authorizer] authorizeStep3:self.pinField.text completionHandler:^ {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self authorizationStep3];
            });
        }];
    });
    
}

- (void) authorizationStep3 {
    [self.statusController dismissViewControllerAnimated:NO completion:nil];
    Authorizer *authorizer = [Utilities authorizer];
    if (authorizer.isAuthorized) {
        // navigate to Tweets view
        TweetTableViewController *tweetViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tweetsViewController"];
        NSArray *controllers = [NSArray arrayWithObject:tweetViewController];
        UINavigationController *navigator = self.navigationController;
        //[self.navigationController pushViewController:tweetViewController animated:NO];
        [navigator setViewControllers:controllers];
        

    } else {
        NSString* errorString = [NSString stringWithFormat:@"<html><center><font size=+5 color='red'>"
                                 "An error occurred confirming Pin:<br>%@</font></center></html>",
                                 authorizer.lastError.localizedDescription];
        [self.webView loadHTMLString:errorString baseURL:nil];
    }
}
@end
