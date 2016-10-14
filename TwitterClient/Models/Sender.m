//
//  Sender.m
//  TwitterClient
//
//  Created by Tomas Garrido on 9/29/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sender.h"
#import "Authorizer.h"
#import <UIKit/UIKit.h>

@interface Sender()
@end

@implementation Sender

-(void)postData:(NSData *)postData url:(NSURL *)url headers:(NSDictionary *)headers
queryParameters:(NSDictionary *)queryParameters
completionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    if (postData) {
    NSString *postLength = [NSString stringWithFormat:@"%lu" , (unsigned long)[postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    if (queryParameters) {
        NSMutableArray *queryItems = [NSMutableArray array];
        for (NSString *key in queryParameters) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:[Authorizer percentEncode:queryParameters[key]]]];
        }
        components.queryItems = queryItems;
        [request setURL:components.URL];
    } else {
        [request setURL:url];
    }

    [request setHTTPMethod:@"POST"];
    if (headers) {
        [headers enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
            [request setValue:value forHTTPHeaderField:key];
        }];
    }

    NSLog(@"\n\n======================== POST ===================================\n");
    NSLog(@"Request.url = %@", [[request URL] absoluteString]);
    NSLog(@"Request.headers= %@", [request allHTTPHeaderFields]);
    NSLog(@"Request.HTTPBody= %@", [request HTTPBody]);
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfiguration.timeoutIntervalForRequest = 30.0;
    sessionConfiguration.timeoutIntervalForResource = 60.0;
    sessionConfiguration.URLCache = nil;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:completionHandler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [task resume];
    [session finishTasksAndInvalidate];
}

-(void)getData:(NSURL *)url headers:(NSDictionary *)headers
queryParameters:(NSDictionary *)queryParameters
completionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    if (queryParameters) {
        NSMutableArray *queryItems = [NSMutableArray array];
        for (NSString *key in queryParameters) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:[Authorizer percentEncode:queryParameters[key]]]];
        }
        components.queryItems = queryItems;
        [request setURL:components.URL];
    } else {
        [request setURL:url];
    }
    
    [request setHTTPMethod:@"GET"];
    if (headers) {
        [headers enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
            [request setValue:value forHTTPHeaderField:key];
        }];
    }
 //   [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSLog(@"\n\n======================== GET ===================================\n");
    NSLog(@"Request.url = %@", [[request URL] absoluteString]);
    NSLog(@"Request.headers= %@", [request allHTTPHeaderFields]);
    NSLog(@"Request.HTTPBody= %@", [request HTTPBody]);
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfiguration.timeoutIntervalForRequest = 30.0;
    sessionConfiguration.timeoutIntervalForResource = 60.0;
    sessionConfiguration.URLCache = nil;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:completionHandler];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [task resume];
    [session finishTasksAndInvalidate];
}

@end
