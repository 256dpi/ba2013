//
//  OGAlertView.h
//  Ogment
//
//  Created by Joël Gähwiler on 23.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OGPopup : UIView

- (void) show;
- (void) showAnimated:(BOOL)animated;
- (void) hide;
- (void) hideAnimated:(BOOL)animated;

@end
