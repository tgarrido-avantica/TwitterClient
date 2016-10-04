//
//  Utilities.h
//  TwitterClient
//
//  Created by Tomás Garrido Sandino on 3/10/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import "Authorizer.h"

@interface Utilities : NSObject

+(NSDictionary *)responseQueryDataToDictionary:(NSData *)responseData;

+(Authorizer *)authorizer;

@end
