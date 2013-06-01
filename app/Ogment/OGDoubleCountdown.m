//
//  OGDoubleCountdown.m
//  Ogment
//
//  Created by Joël Gähwiler on 30.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <UIView+DrawRectBlock.h>

#import "OGDoubleCountdown.h"
#import "OGSingleCountdown.h"

#define OG_DOUBLE_COUNTDOWN_CIRCLE_SHADOW 2
#define OG_DOUBLE_COUNTDOWN_INNER_SIZE 0.6

@implementation OGDoubleCountdown {
  OGSingleCountdown* _innerCountdown;
  OGSingleCountdown* _outerContdown;
  UIView* _circle;
}

- (void)_commonInit
{
  self.opaque = NO;
  
  float inset = self.bounds.size.width-self.bounds.size.width*OG_DOUBLE_COUNTDOWN_INNER_SIZE;
  _innerCountdown = [[OGSingleCountdown alloc] initWithFrame:CGRectInset(self.bounds, inset/2, inset/2)];
  _outerContdown = [[OGSingleCountdown alloc] initWithFrame:self.bounds];

  _circle = [UIView viewWithFrame:CGRectInset(self.bounds, inset/2-OG_DOUBLE_COUNTDOWN_CIRCLE_SHADOW, inset/2-OG_DOUBLE_COUNTDOWN_CIRCLE_SHADOW) drawRectBlock:^(CGRect rect) {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    CGContextFillEllipseInRect(ctx, _circle.bounds);
  }];
  _circle.opaque = NO;
  
  [self addSubview:_outerContdown];
  [self addSubview:_circle];
  [self addSubview:_innerCountdown];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if(self) {
    [self _commonInit];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self _commonInit];
  }
  return self;
}

- (void)setOuterProgress:(float)progress
{
  [_outerContdown setProgress:progress];
}

- (void)setInnerProgress:(float)progress
{
  [_innerCountdown setProgress:progress];
}

@end
