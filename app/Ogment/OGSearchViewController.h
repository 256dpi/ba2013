//
//  OGSearchViewController.h
//  Ogment
//
//  Created by Joël Gähwiler on 02.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OGSearchViewControllerDelegate <NSObject>
@optional
- (void)didStartSearch:(id)searchViewController;
@end

@interface OGSearchViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id <OGSearchViewControllerDelegate> delegate;
@property (nonatomic) BOOL useTimer;

- (NSString*)searchTerm;
- (void)close;

@end
