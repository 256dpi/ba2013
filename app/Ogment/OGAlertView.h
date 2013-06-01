//
//  OGAlertView.h
//  Ogment
//
//  Created by Joël Gähwiler on 23.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OGPopup.h"

@interface OGAlertView : OGPopup

- (id)initWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle;

@end
