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
#import "Tweet.h"

static const NSString *const CONSUMER_KEY = @"YnKSYRew3EgY16wq1yVEw";
static NSString * CONSUMER_SECRET = @"JwVZSButJKxP3htInh3qcuX51OM4ORD6Pxd2A3rq1JM";
static const NSString *const OAUTH_URL_BASE = @"https://api.twitter.com/oauth/";
static const NSString *const OAUTH_VERSION = @"1.0";
static const NSString *const OAUTH_SIGNATURE_METHOD = @"HMAC-SHA1";

@interface Authorizer()
@property(strong, nonatomic)NSString *oauthToken;
@property(strong, nonatomic)NSString *oauthRequestToken;
@property(strong, nonatomic)NSString *oauthTokenSecret;
@property(strong, nonatomic)NSMutableDictionary *bodyParameters;
@property(strong, nonatomic)NSMutableDictionary *queryParameters;
@property(strong, nonatomic, readwrite)NSError *lastError;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
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

-(NSString *)oauthToken {
    if ( _oauthToken) {
        return _oauthToken;
    } else {
        return self.oauthRequestToken;
    }
}

-(void)test {
    [self authorize:nil];
}

-(BOOL)isAuthorized {
    return self.lastError ==nil && self.oauthToken != nil;
}

-(NSString *)generateNonce {
    //return @"6364d3968bdd1cdc0ee3b64896dcee8d";
    return [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

-(NSString *)generateTimestamp {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%d", (int)timeInterval];
}

+(NSURL *)oauthRequestTokenURL {
    if (!_oauthRequestTokenURL) _oauthRequestTokenURL = [NSURL URLWithString:[OAUTH_URL_BASE stringByAppendingString:@"request_token"]];
    return _oauthRequestTokenURL;
}

-(NSURL *)oauthAuthorizeURL {
    if (!_oauthAuthorizeURL) _oauthAuthorizeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@authorize?oauth_token=%@",
                                                                        OAUTH_URL_BASE,
                                                                        self.oauthToken]];
    return _oauthAuthorizeURL;
}

+(NSURL *)oauthAccessTokenURL {
    if (!_oauthAccessTokenURL) _oauthAccessTokenURL = [NSURL  URLWithString:[OAUTH_URL_BASE stringByAppendingString:@"access_token"]];
    return _oauthAccessTokenURL;
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
    if (self.oauthTokenSecret) {
       // oauthKeys[@"oauth_token_secret"] = self.oauthTokenSecret;
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
    if (self.oauthTokenSecret) {
        [signingKey appendString:[Authorizer percentEncode:self.oauthTokenSecret]];
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


-(void)authorizeStep1 {
    [self.bodyParameters removeAllObjects];
    [self.queryParameters removeAllObjects];

    NSDictionary *headers = @{@"Authorization" : [self generateAuthorizationHeader:@"POST"
                                                                               url:[Authorizer oauthRequestTokenURL] callback:@"oob"]};
    Sender *sender = [Sender new];
    [sender postData:nil url:[Authorizer oauthRequestTokenURL] headers:headers queryParameters:nil
   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (error) {
            self.lastError = error;
            dispatch_semaphore_signal(self.semaphore);
            return;
        }
       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
       
       if (httpResponse.statusCode != 200) {
           [self handleResponseError:httpResponse returnedData:data];
           dispatch_semaphore_signal(self.semaphore);
           return;
           
       }
       NSDictionary *params = [Utilities responseQueryDataToDictionary:data];
       if ([params[@"oauth_callback_confirmed"] isEqualToString:@"true"]) {
           self.oauthRequestToken = params[@"oauth_token"];
           //self.oauthTokenSecret = params[@"oauth_token_secret"];
       } else {
           [self logout];
       }
       dispatch_semaphore_signal(self.semaphore);
   }];
}

-(void)logout {
    self.oauthToken = nil;
    self.oauthTokenSecret = nil;
    self.oauthRequestToken = nil;
}

-(void)authorize:(void(^)(void))completionHandler {
    self.semaphore = dispatch_semaphore_create(0);
    [self authorizeStep1];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
   
    completionHandler();

}

-(void)authorizeStep3:(NSString *)token completionHandler:(void(^)(void))completionHandler {
    [self confirmToken:token];
    self.semaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    completionHandler();
}

-(void)confirmToken:(NSString *)token {
    [self.bodyParameters removeAllObjects];
    [self.queryParameters removeAllObjects];

    self.bodyParameters[@"oauth_verifier"] = token;
    NSDictionary *headers = @{@"Authorization" : [self generateAuthorizationHeader:@"POST"
                                                                               url:[Authorizer oauthAccessTokenURL] callback:nil]};
    Sender *sender = [Sender new];
    NSData *postData = [[NSString stringWithFormat:@"oauth_verifier=%@", token] dataUsingEncoding:NSUTF8StringEncoding];
    [sender postData:postData url:[Authorizer oauthAccessTokenURL] headers:headers queryParameters:nil
   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
       if (error) {
           self.lastError = error;
           dispatch_semaphore_signal(self.semaphore);
           return;
       }
       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

       if (httpResponse.statusCode != 200) {
           [self handleResponseError:httpResponse returnedData:data];
           dispatch_semaphore_signal(self.semaphore);
           return;
           
       }
       NSDictionary *params = [Utilities responseQueryDataToDictionary:data];
       if (params[@"oauth_token"]) {
           self.oauthToken = params[@"oauth_token"];
           self.oauthTokenSecret = params[@"oauth_token_secret"];
       } else {
           [self logout];
       }
       dispatch_semaphore_signal(self.semaphore);
   }];
}

-(void)handleResponseError:(NSHTTPURLResponse *)httpResponse returnedData:(NSData *)data{
    NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"\n\n------------------------- ERROR -----------------------------------\n");
    NSLog(@"Response HTTP Status code: %ld\n", httpResponse.statusCode);
    NSLog(@"Response HTTP Headers:\n%@\n", httpResponse.allHeaderFields);
    NSLog(@"Response Body:\n%@\n", body);
    NSError *jsonError;
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError) {
        // Error parsing json body
        self.lastError = [NSError errorWithDomain:jsonError.domain code:jsonError.code userInfo:jsonError.userInfo];
        dispatch_semaphore_signal(self.semaphore);
        return;
    }
    // Create error object with JSON errors array.
    NSDictionary *userInfo = @{@"errors" : responseJSON[@"errors"]};
    self.lastError = [NSError errorWithDomain:@"Authorizer" code:httpResponse.statusCode userInfo:userInfo];

}

-(NSArray *)getTweetsWithMaxId:(NSString *)maxId sinceId:(NSString *)sinceId {
    [self.bodyParameters removeAllObjects];
    [self.queryParameters removeAllObjects];
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    NSDictionary *headers = @{@"Authorization" : [self generateAuthorizationHeader:@"GET"
                                                                                url:url callback:nil]};
    __block NSArray *tweetsArray = [NSMutableArray new];
    Sender *sender = [Sender new];
    [sender getData:url headers:headers queryParameters:nil
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
           if (error) {
               self.lastError = error;
               dispatch_semaphore_signal(self.semaphore);
               return;
           }
           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
           
           if (httpResponse.statusCode != 200) {
               [self handleResponseError:httpResponse returnedData:data];
               dispatch_semaphore_signal(self.semaphore);
               return;
               
           }
            // create tweets array
        
            tweetsArray = [self createTweetsArrayWithData:data];
           dispatch_semaphore_signal(self.semaphore);
        }];

    self.semaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return tweetsArray;
}

-(NSArray *)createTweetsArrayWithData:(NSData *)data {
    NSMutableArray *tweetsArray = [NSMutableArray new];
    //NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSError *jsonError;
    NSArray *tweets = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    if (jsonError) {
        self.lastError = [NSError errorWithDomain:jsonError.domain code:jsonError.code userInfo:jsonError.userInfo];
        dispatch_semaphore_signal(self.semaphore);
        return tweetsArray;
    }
    for (NSDictionary *tweet in tweets) {
        [tweetsArray addObject:[[Tweet alloc] initWithDictionary:tweet]];
    }
    return tweetsArray;
}

-(void)createTweet:(Tweet *)tweet sourceController:(TweetTableViewController *)source {
    [self.bodyParameters removeAllObjects];
    [self.queryParameters removeAllObjects];
    self.bodyParameters[@"status"] = tweet.content;
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    NSDictionary *headers = @{@"Authorization" : [self generateAuthorizationHeader:@"POST"
                                                                               url:url callback:nil]};
    Sender *sender = [Sender new];
    NSData *postData = [[NSString stringWithFormat:@"status=%@", [Authorizer percentEncode:tweet.content]] dataUsingEncoding:NSUTF8StringEncoding];

    [sender postData:postData url:url headers:headers queryParameters:self.queryParameters
   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
       if (error) {
           self.lastError = error;
           dispatch_semaphore_signal(self.semaphore);
           return;
       }
       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
       
       if (httpResponse.statusCode != 200) {
           [self handleResponseError:httpResponse returnedData:data];
           dispatch_semaphore_signal(self.semaphore);
           return;
           
       } else {
           NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
           NSLog(@"\n\n======================== createTweet ===================================\n");
           NSLog(@"Response.statusCode = %ld", (long)httpResponse.statusCode);
           NSLog(@"Response HTTP Headers:\n%@\n", httpResponse.allHeaderFields);
           NSLog(@"Response Body:\n%@\n", body);
       }
      // NSDictionary *params = [Utilities responseQueryDataToDictionary:data];
      dispatch_semaphore_signal(self.semaphore);
   }];
   self.semaphore = dispatch_semaphore_create(0);
   dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

-(void)loadPictureOfTweet:(Tweet *)tweet cell:(TweetTableViewCell *)cell photoCache:(NSMutableDictionary *)photoCache {
    if ([tweet.pictureURLString length] > 0) {
        
        NSURL *url = [NSURL URLWithString:tweet.pictureURLString];
        __block TweetTableViewCell * blockCell = cell;
        __block NSMutableDictionary *blockPhotoCache = photoCache;
        __block Tweet * blockTweet = tweet;
        Sender *sender = [Sender new];
        [sender getData:url headers:nil queryParameters:nil
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
          if (!error) {
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
              if (httpResponse.statusCode != 200) {
                  [self handleResponseError:httpResponse returnedData:data];
              } else {
                  blockTweet.picture = [UIImage imageWithData:data];
                  blockPhotoCache[tweet.userIdString] = blockTweet.picture;
                  dispatch_async(dispatch_get_main_queue(), ^{
                    blockCell.tweetererPicture.image = blockTweet.picture;
                  });
              }
          } else {
              NSLog(@"\n\n---------- loadPictureOfTweet ----------\n");
              NSLog(@"Error: %@", [error localizedDescription]);
          }
      }];
    }
}

@end
