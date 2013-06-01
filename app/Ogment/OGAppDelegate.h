//
//  OGAppDelegate.h
//  Ogment
//
//  Created by Joël Gähwiler on 14.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECClient.h"

@class OGConnectingViewController;

@interface OGAppDelegate : UIResponder <UIApplicationDelegate,ECClientDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController* navigationController;
@property (strong, nonatomic) OGConnectingViewController* connectingViewController;

- (void)reconnect;

@end
