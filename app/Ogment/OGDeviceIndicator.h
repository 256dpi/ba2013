//
//  OGDeviceIndicator.h
//  Ogment
//
//  Created by Joël Gähwiler on 01.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
  OGDeviceIndicatorStateActive,
  OGDeviceIndicatorStateInactive,
  OGDeviceIndicatorStateLeader
} OGDeviceIndicatorState;

@interface OGDeviceIndicator : UIView

- (void)setState:(OGDeviceIndicatorState)state;

@end
