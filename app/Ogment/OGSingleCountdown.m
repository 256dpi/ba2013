//
//  OGSingleCountdown.m
//  Ogment
//
//  Created by Joël Gähwiler on 30.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "OGSingleCountdown.h"

#define OG_SINGLE_COUNTDOWN_LINE_WEIGHT 2.0f
#define OG_SINGLE_COUNTDOWN_LINE_SPACING 4.0f

#define DEGREES_TO_RADIANS(d) ((d) * 0.0174532925199432958f)
#define RADIANS_TO_DEGREES(r) ((r) * 57.29577951308232f)

@implementation OGSingleCountdown {
  float _progress;
}

- (void)_commonInit
{
  self.opaque = NO;
  _progress = 0.0f;
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

- (void)setProgress:(float)progress
{
  _progress = fmaxf(0.0f, fminf(1.0f, progress));
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
  
  [[UIColor whiteColor] set];
  CGContextFillEllipseInRect(context, self.bounds);
  
  [[UIColor blackColor] set];
  CGContextSetLineWidth(context, OG_SINGLE_COUNTDOWN_LINE_WEIGHT);
  CGContextStrokeEllipseInRect(context, CGRectInset(self.bounds, OG_SINGLE_COUNTDOWN_LINE_WEIGHT/2, OG_SINGLE_COUNTDOWN_LINE_WEIGHT/2));
  
	CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	CGFloat radius = center.y-OG_SINGLE_COUNTDOWN_LINE_SPACING;
	CGFloat angle = DEGREES_TO_RADIANS((360.0f * _progress) + -90.0f);
	CGPoint points[3] = {
		CGPointMake(center.x, OG_SINGLE_COUNTDOWN_LINE_SPACING),
		center,
		CGPointMake(center.x + radius * cosf(angle), center.y + radius * sinf(angle))
	};
  
  [[UIColor blackColor] set];
  if (_progress > 0.0f) {
    CGContextAddLines(context, points, sizeof(points) / sizeof(points[0]));
    CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(-90.0f), angle, false);
    CGContextDrawPath(context, kCGPathEOFill);
	}
}

@end
