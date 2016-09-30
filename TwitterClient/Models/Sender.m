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

@interface Sender()
@end

@implementation Sender

-(void)postData:(NSData *)postData url:(NSURL *)url headers:(NSDictionary *)headers
 queryParameters:(NSDictionary *)queryParameters;
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    if (postData) {
    NSString *postLength = [NSString stringWithFormat:@"%lu" , (unsigned long)[postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
    }
      NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    if (queryParameters) {
        NSMutableArray *queryItems = [NSMutableArray array];
        for (NSString *key in queryParameters) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:queryParameters[key]]];
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
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSLog(@"Request.url = %@", [[request URL] absoluteString]);
    NSLog(@"Request.headers= %@", [request allHTTPHeaderFields]);
    NSLog(@"Request.HTTPBody= %@", [request HTTPBody]);
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      if (error) {
                                          // Handle error...
                                          return;
                                      }
                                      
                                      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                          NSLog(@"Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
                                          NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response allHeaderFields]);
                                      }
                                      
                                      NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      NSLog(@"Response Body:\n%@\n", body);
                                  }];
    [task resume];
}
@end
