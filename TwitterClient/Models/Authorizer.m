//
//  Authorizer.m
//  TwitterClient
//
//  Created by Tomas Garrido on 9/20/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "Authorizer.h"
#import <CommonCrypto/CommonDigest.h>

static const NSString *const CONSUMER_KEY = @"YnKSYRew3EgY16wq1yVEw";
static NSString * CONSUMER_SECRET = @"JwVZSButJKxP3htInh3qcuX51OM4ORD6Pxd2A3rq1JM";
static const NSString *const OAUTH_URL_BASE = @"https://api.twitter.com/oauth/";
static const NSString *const OAUTH_VERSION = @"1.0";
static const NSString *const OAUTH_SIGNATURE_METHOD = @"HMAC-SHA1";

@interface Authorizer()
@property(nonatomic)NSString *oauthToken;
@property(nonatomic)NSMutableDictionary *bodyParameters;
@property(nonatomic)NSMutableDictionary *queryParameters;
@end

@implementation Authorizer

static NSURL * _oauthRequestTokenURL = nil;
static NSURL * _oauthAuthorizeURL = nil;
static NSURL * _oauthAccessTokenURL = nil;
static NSCharacterSet *_URLFullCharacterSet;

-(instancetype)init {
    self = [super init];
    self.oauthToken=@"";
    self.bodyParameters = [NSMutableDictionary new];
    self.queryParameters = [NSMutableDictionary new];
    return self;
}

-(void)test {
    NSLog(@"Data %@", [self generateAuthorizationHeader:@"POST" url:[[Authorizer oauthAuthorizeURL] absoluteString] ]);
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

+(NSCharacterSet *)URLFullCharacterSet {
    if (!_URLFullCharacterSet) _URLFullCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"&= \"#%/:<>?@[\\]^`{|},"] invertedSet];
    return _URLFullCharacterSet;
}

-(NSString *)generateAuthorizationHeader:(NSString *)method url:(NSString *)url {
    __block NSMutableString *result = [[NSMutableString alloc] initWithString:@"OAuth "];
    NSMutableDictionary *oauthKeys = [[NSMutableDictionary alloc] initWithDictionary:   @{@"oauth_consumer_key" : CONSUMER_KEY,
                                @"oauth_nonce" : [self generateNonce],
                                @"oauth_signature_method" : OAUTH_SIGNATURE_METHOD,
                                @"oauth_timestamp" : [self generateTimestamp],
                                @"oauth_token" : self.oauthToken}];
    oauthKeys[@"oauth_signature"] = [self generateSignature:oauthKeys method:method url:url];
    [oauthKeys enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        [result appendString:[NSString stringWithFormat:@"%@=%@",key, value]];
    }];
    return result;
}

-(NSString *)generateSignature:(NSMutableDictionary *)oauthKeys method:(NSString *)method url:(NSString *)url {
    NSMutableDictionary *encodedFields = [NSMutableDictionary new];
    [oauthKeys enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        encodedFields[[self percentEncode:key]] = [self percentEncode:value] ;
    }];
    [self.queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        encodedFields[[self percentEncode:key]] = [self percentEncode:value] ;
    }];
    [self.bodyParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        encodedFields[[self percentEncode:key]] = [self percentEncode:value] ;
    }];
    NSMutableArray *parameters = [NSMutableArray new];
    NSLog(@"%@",[encodedFields allKeys]);
    [encodedFields enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        encodedFields[[self percentEncode:key]] = [self percentEncode:value] ;
        [parameters addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }];
    NSString *parameterString = [parameters componentsJoinedByString:@"&"];
    [parameters removeAllObjects];
    NSMutableString *signatureBaseString = [NSMutableString stringWithString:method];
    [signatureBaseString appendString: [NSString stringWithFormat:@"&%@&%@", [self percentEncode:url], [self percentEncode:parameterString]]];
    NSString *signingKey = [NSString stringWithFormat:@"%@&%@", [self percentEncode:CONSUMER_SECRET], [self percentEncode:self.oauthToken]];
    NSString *signature = [NSString stringWithFormat:@"%@%@", signatureBaseString, signingKey];
    return [self encodeDataBase64:[self sha1:signature]];
}

-(NSString *)percentEncode:(NSString *)stringToEncode {
    return  [stringToEncode stringByAddingPercentEncodingWithAllowedCharacters:[Authorizer URLFullCharacterSet]];
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

-(NSString *)encodeDataBase64:(NSData *)dataToEncode {
    // Convert to Base64 data
    return [dataToEncode base64EncodedStringWithOptions:0];
}

- (NSData *)sha1:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH ];
    CC_SHA1(cStr, (int)strlen(cStr), result);
    return [NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH ];
}

@end
