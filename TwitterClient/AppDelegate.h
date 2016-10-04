//
//  AppDelegate.h
//  TwitterClient
//
//  Created by Tomás Garrido Sandino on 19/9/16.
//  Copyright © 2016 Tomás Garrido Sandino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Authorizer.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (strong, nonatomic, readonly) Authorizer *authorizer;

- (void)saveContext;


@end

