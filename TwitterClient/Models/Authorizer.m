//
//  Authorizer.m
//  TwitterClient
//
//  Created by Tomas Garrido on 9/20/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "Authorizer.h"
#import <CommonCrypto/CommonHMAC.h>
#import "Sender.h"
#import "Utilities.h"

static const NSString *const CONSUMER_KEY = @"YnKSYRew3EgY16wq1yVEw";
static NSString * CONSUMER_SECRET = @"JwVZSButJKxP3htInh3qcuX51OM4ORD6Pxd2A3rq1JM";
static const NSString *const OAUTH_URL_BASE = @"https://api.twitter.com/oauth/";
static const NSString *const OAUTH_VERSION = @"1.0";
static const NSString *const OAUTH_SIGNATURE_METHOD = @"HMAC-SHA1";

@interface Authorizer()
@property(nonatomic)NSString *oauthToken;
@property(nonatomic)NSString *oauthTokenSecret;
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
    self.bodyParameters = [NSMutableDictionary new];
    self.queryParameters = [NSMutableDictionary new];
    return self;
}

-(void)test {
    [self authorize];
}

-(BOOL)isAuthorized {
    return self.oauthToken != nil;
}

-(void)authorize {
    NSDictionary *headers = @{@"Authorization" : [self generateAuthorizationHeader:@"POST"
                                                                               url:[Authorizer oauthRequestTokenURL] callback:@"oob"]};
    Sender *sender = [Sender new];
    [sender postData:nil url:[Authorizer oauthRequestTokenURL] headers:headers queryParameters:nil
   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         
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
       NSDictionary *params = [Utilities responseQueryDataToDictionary:data];
       if (![params[@"oauth_callback_confirmed"] isEqualToString:@"true"]) {
           self.oauthToken = params[@"oauth_token"];
           self.oauthTokenSecret = params[@"oauth_token_secret"];
           // Turn
       } else {
#warning Handle a bad response from Twitter
       }
     }];
}

-(NSString *)generateNonce {
    //return @"6364d3968bdd1cdc0ee3b64896dcee8d";
    return [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

-(NSString *)generateTimestamp {
    //return @"1475271244";
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

-(NSString *)generateAuthorizationHeader:(NSString *)method url:(NSURL *)url callback:(NSString *)callback{
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"OAuth "];
    NSMutableDictionary *oauthKeys = [[NSMutableDictionary alloc] initWithDictionary:   @{@"oauth_consumer_key" : CONSUMER_KEY,
                                @"oauth_nonce" : [self generateNonce],
                                @"oauth_signature_method" : OAUTH_SIGNATURE_METHOD,
                                @"oauth_timestamp" : [self generateTimestamp],
                                @"oauth_version" : OAUTH_VERSION}];
    if (self.oauthToken) {
        oauthKeys[@"oauth_token"] = self.oauthToken;
    }
    if (callback) {
        oauthKeys[@"oauth_callback"] = [Authorizer percentEncode:callback];
    }
    oauthKeys[@"oauth_signature"] = [Authorizer percentEncode:[self generateSignature:oauthKeys method:method url:url]];
    NSArray *keys = [[oauthKeys allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (NSString *key in keys) {
        [tempArray addObject:[NSString stringWithFormat:@"%@=\"%@\"",key, oauthKeys[key]]];
    }
    [result appendString:[tempArray componentsJoinedByString:@", "]];
    return result;
}

-(NSString *)generateSignature:(NSMutableDictionary *)oauthKeys method:(NSString *)method url:(NSURL *)url {
    NSMutableDictionary *encodedFields = [NSMutableDictionary new];
    [oauthKeys enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        encodedFields[[Authorizer percentEncode:key]] = [Authorizer percentEncode:value] ;
    }];
    [self.queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        encodedFields[[Authorizer percentEncode:key]] = [Authorizer percentEncode:value] ;
    }];
    [self.bodyParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        encodedFields[[Authorizer percentEncode:key]] = [Authorizer percentEncode:value] ;
    }];
    NSMutableArray *parameters = [NSMutableArray new];
    NSArray *keys = [[encodedFields allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in keys) {
        [parameters addObject:[NSString stringWithFormat:@"%@=%@", key, encodedFields[key]]];
    }
    NSString *parameterString = [parameters componentsJoinedByString:@"&"];
    NSMutableString *signatureBaseString = [NSMutableString stringWithString:method];
    [signatureBaseString appendString: [NSString stringWithFormat:@"&%@&%@", [Authorizer percentEncode:[url  absoluteString]], [Authorizer percentEncode:parameterString]]];
    NSMutableString *signingKey = [NSMutableString stringWithFormat:@"%@&", [Authorizer percentEncode:CONSUMER_SECRET]];
    if (self.oauthToken) {
        [signingKey appendString:[Authorizer percentEncode:self.oauthToken]];
    }
    return [self encodeDataBase64:[self sha1:signatureBaseString key:signingKey]];
}

+(NSString *)percentEncode:(NSString *)stringToEncode {
    return  [stringToEncode stringByAddingPercentEncodingWithAllowedCharacters:[Authorizer URLFullCharacterSet]];
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

- (NSData *)sha1:(NSString *)inputStr key:(NSString *)key {
    const char *cStr = [inputStr UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH ];
    CCHmac(kCCHmacAlgSHA1, [key UTF8String], [key length], cStr, [inputStr length], result);
    return [NSData dataWithBytes:result length:CC_SHA1_DIGEST_LENGTH ];
}

@end
