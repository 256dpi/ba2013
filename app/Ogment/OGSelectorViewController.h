//
//  OGSelectorViewController.h
//  Ogment
//
//  Created by Joël Gähwiler on 01.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
  OGSelectorTypeAttack,
  OGSelectorTypeProtection,
  OGSelectorTypeStrategy
} OGSelectorType;

@protocol OGSelectorViewControllerDelegate <NSObject>
@optional
- (void)didEndSelection:(id)selectorViewController;
@end

@interface OGSelectorViewController : UIViewController

@property (nonatomic, weak) id <OGSelectorViewControllerDelegate> delegate;
@property (nonatomic) OGSelectorType type;
@property (nonatomic) BOOL useTimer;

- (id)initWithType:(OGSelectorType)type;
- (NSString*)selectedSelector;
- (void)close;

@end
