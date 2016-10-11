//
//  Utilities.m
//  TwitterClient
//
//  Created by Tomás Garrido Sandino on 3/10/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"
#import "AppDelegate.h"

@interface Utilities()

@end

@implementation Utilities

+(NSDictionary *)responseQueryDataToDictionary:(NSData *)responseData {
    NSString *data = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSArray *keyValues = [data componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    for(NSString *keyValue in keyValues) {
        NSArray *tokens = [keyValue componentsSeparatedByString:@"="];
        params[(NSString *)[tokens firstObject]] = (NSString *)[tokens lastObject];
    }
    return params;
}

+(Authorizer *)authorizer {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.authorizer;
}


+(ModalStatusViewController *) showStatusModalWithMessage:(NSString *)message
                                                   source:(UIViewController *)source{
    UIStoryboard *storyboard = source.storyboard; // [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ModalStatusViewController *status = [storyboard instantiateViewControllerWithIdentifier:@"modalStatusViewController"];
    
    [source.view.window.rootViewController  presentViewController:status animated:NO completion:nil];
    [status setMessage:message];
    return status;
}

@end
