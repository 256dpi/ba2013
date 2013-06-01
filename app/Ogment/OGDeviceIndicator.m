//
//  OGDeviceIndicator.m
//  Ogment
//
//  Created by Joël Gähwiler on 01.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "OGDeviceIndicator.h"

@implementation OGDeviceIndicator {
  OGDeviceIndicatorState _state;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setState:OGDeviceIndicatorStateInactive];
    self.backgroundColor = [UIColor whiteColor];
  }
  return self;
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  [[UIColor blackColor] set];
  CGContextSetLineWidth(ctx, 2);
  
  switch (_state) {
    case OGDeviceIndicatorStateInactive:
      CGContextStrokeRect(ctx, CGRectInset(self.bounds, 1, 1));
      break;
    case OGDeviceIndicatorStateActive:
      CGContextStrokeRect(ctx, CGRectInset(self.bounds, 1, 1));
      CGContextMoveToPoint(ctx, self.bounds.origin.x, self.bounds.origin.y);
      CGContextAddLineToPoint(ctx, self.bounds.size.width+self.bounds.origin.x, self.bounds.size.height+self.bounds.origin.y);
      CGContextMoveToPoint(ctx, self.bounds.origin.x+self.bounds.size.width, self.bounds.origin.y);
      CGContextAddLineToPoint(ctx, self.bounds.origin.x, self.bounds.size.height+self.bounds.origin.y);
      CGContextStrokePath(ctx);
      break;
    case OGDeviceIndicatorStateLeader:
      CGContextFillRect(ctx, CGRectInset(self.bounds, 1, 1));
      break;
  }
}

-(void)setState:(OGDeviceIndicatorState)state
{
  _state = state;
  [self setNeedsDisplay];
}

@end
