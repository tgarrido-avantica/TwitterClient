//
//  Authorizer.m
//  TwitterClient
//
//  Created by Tomas Garrido on 9/20/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "Authorizer.h"
static const NSString *const CONSUMER_KEY = @"YnKSYRew3EgY16wq1yVEw";
static const NSString *const CONSUMER_SECRET = @"JwVZSButJKxP3htInh3qcuX51OM4ORD6Pxd2A3rq1JM";
static const NSString *const OAUTH_URL_BASE = @"https://api.twitter.com/oauth/";

@interface Authorizer()

@end

@implementation Authorizer

static NSURL * _oauthRequestTokenURL = nil;
static NSURL * _oauthAuthorizeURL = nil;
static NSURL * _oauthAccessTokenURL = nil;

-(void)test {
    NSLog(@"Data %@", [self generateNonce]);
}

-(NSString *)generateNonce {
    return [[NSUUID UUID] UUIDString];
}

-(NSString *)generateTimestamp {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%d", (int)timeInterval];
}

+(NSURL *)oauthRequestTokenURL {
    if (!_oauthRequestTokenURL) _oauthRequestTokenURL = [NSURL URLWithString:[OAUTH_URL_BASE stringByAppendingString:@"request_token"]];
    return _oauthRequestTokenURL;
}

+(NSURL *)oauthAuthorizeURL {
    if (!_oauthAuthorizeURL) _oauthAuthorizeURL = [NSURL URLWithString:[OAUTH_URL_BASE stringByAppendingString:@"authorize"]];
    return _oauthAuthorizeURL;
}

+(NSURL *)oauthAccessTokenURL {
    if (!_oauthAccessTokenURL) _oauthAccessTokenURL = [NSURL  URLWithString:[OAUTH_URL_BASE stringByAppendingString:@"access_token"]];
    return _oauthAuthorizeURL;
}

-(NSString *)oauthVersion {
    return @"1.0";
}

-(NSData *)calculateAuthorizationHeaderWithQueryParameters:(NSDictionary *)queryParameters bodyParameters:(NSDictionary *)bodyParameters {
    NSData *result = [NSData new];
    return result;
}

-(NSString *)percentEncode:(NSString *)stringToEncode {
    return  [stringToEncode stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

-(void)postSignedData:(NSData *)postData authorizationHeader:(NSString *)authorizationHeader{
    NSString *postLength = [NSString stringWithFormat:@"%lu" , (unsigned long)[postData length]];
    NSURL *url = [NSURL URLWithString:@"http://172.16.231.19/redmine23/login"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
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

-(NSString *)encodeStringBase64:(NSString *)stringToEncode {
    // Create NSData object
    NSData *nsdata = [stringToEncode dataUsingEncoding:NSUTF8StringEncoding];
    // Get NSString from NSData object in Base64
    return [nsdata base64EncodedStringWithOptions:0];
}

-(NSData *)encodeDataBase64:(NSData *)dataToEncode {
    // Convert to Base64 data
    return [dataToEncode base64EncodedDataWithOptions:0];
}
@end
