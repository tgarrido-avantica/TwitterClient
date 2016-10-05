//
//  ViewController.m
//  TwitterClient
//
//  Created by Tomás Garrido Sandino on 19/9/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "LoginViewController.h"
#import "Authorizer.h"
#import "Utilities.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    Authorizer *authorizer = [Utilities authorizer];
    [authorizer test];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
