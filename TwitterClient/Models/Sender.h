//
//  Sender.h
//  TwitterClient
//
//  Created by Tomas Garrido on 9/29/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

@interface Sender:NSObject

-(void)postData:(NSData *)postData url:(NSURL *)url headers:(NSDictionary *)headers
queryParameters:(NSDictionary *)queryParameters
completionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

-(void)getData:(NSURL *)url headers:(NSDictionary *)headers
queryParameters:(NSDictionary *)queryParameters
completionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
@end
