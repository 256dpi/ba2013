//
//  OGAlertView.m
//  Ogment
//
//  Created by Joël Gähwiler on 23.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "OGPopup.h"

@implementation OGPopup {
  UIWindow* _window;
  CGFloat _backgroundAlpha;
  CGFloat _animationLength;
}

- (id)initWithFrame:(CGRect)frame
{
  if(self = [super initWithFrame:frame]) {
    _backgroundAlpha = 1;
    _animationLength = 0.3f;
  }
  return self;
}

- (void) show {
  [self showAnimated:YES];
}

- (void) showAnimated:(BOOL)animated {
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.transform = CGAffineTransformMakeRotation(-90*M_PI/180.0);
  _window.windowLevel = UIWindowLevelAlert;
  _window.backgroundColor = [UIColor blackColor];
  
  self.center = CGPointMake(CGRectGetMidX(_window.bounds), CGRectGetMidY(_window.bounds));
  [_window addSubview:self];
  [_window makeKeyAndVisible];
  
  if (animated) {
    _window.alpha = 0.0f;
    __block UIWindow *animationWindow = _window;
    [UIView animateWithDuration:_animationLength delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^() {
      animationWindow.alpha = _backgroundAlpha;
    } completion:nil];
  } else {
    _window.alpha = _backgroundAlpha;
  }
}

- (void) hide {
  [self hideAnimated:YES];
}

- (void) hideAnimated:(BOOL)animated {
  if (animated) {
    __block UIWindow *animationWindow = _window;
    [UIView animateWithDuration:_animationLength delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^() {
      animationWindow.alpha = 0.0f;
    } completion:^(BOOL finished) {
      _window.hidden = YES;
      _window = nil;
    }];
  } else {
    _window.hidden = YES;
    _window = nil;
  }
}

@end
