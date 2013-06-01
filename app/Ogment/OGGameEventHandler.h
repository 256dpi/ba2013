//
//  OGGameEventHandler.h
//  Ogment
//
//  Created by Joël Gähwiler on 01.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OGSelectorViewController.h"
#import "OGSearchViewController.h"
#import "OGResultsViewController.h"

@protocol OGGameEventHandlerDelegate <NSObject>
@optional
- (void)didCancelGame;
@end

@interface OGGameEventHandler : NSObject <OGSelectorViewControllerDelegate,OGSearchViewControllerDelegate>

@property (nonatomic,weak) id <OGGameEventHandlerDelegate> delegate;

- (void)handleEventsWithViewController:(id)viewController inMode:(NSString*)mode;
- (void)stop;

@end
