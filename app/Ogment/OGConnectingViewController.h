//
//  OGConnectingViewController.h
//  Ogment
//
//  Created by Joël Gähwiler on 14.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OGAppDelegate;

@interface OGConnectingViewController : UIViewController

@property (weak, nonatomic) OGAppDelegate* delegate;

- (void)presentConnectionFailedState;
- (void)presentReconnectingState;

@end
