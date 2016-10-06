//
//  Utilities.h
//  TwitterClient
//
//  Created by Tomás Garrido Sandino on 3/10/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "Authorizer.h"
#import "ModalStatusViewController.h"

@interface Utilities : NSObject

+(NSDictionary *)responseQueryDataToDictionary:(NSData *)responseData;

+(Authorizer *)authorizer;

+(ModalStatusViewController *) showStatusModalWithMessage:(NSString *)message
                                                   source:(UIViewController *)source;

@end
