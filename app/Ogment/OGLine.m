//
//  OGLine.m
//  Ogment
//
//  Created by Joël Gähwiler on 01.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "OGLine.h"
#import "OGTheme.h"

@implementation OGLine

+ (OGLine *)lineWithArray:(NSArray *)array andFrame:(CGRect)frame
{
  OGLine* line = [[OGLine alloc] initWithFrame:frame];
  line.opaque = NO;
  line.pointArray = array;
  return line;
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetStrokeColorWithColor(context, [OGTheme grayColor].CGColor);
  CGContextSetLineWidth(context, 2);
  
  if(self.pointArray.count % 2 != 0) {
    [NSException raise:@"Provided array of points is odd" format:@"array has size of %d", self.pointArray.count];
  }
  
  if(self.pointArray.count > 1) {
    CGContextMoveToPoint(context, [self.pointArray[0] intValue], [self.pointArray[1] intValue]);
  }
  
  int i = 2;
  while(i < self.pointArray.count) {
    CGContextAddLineToPoint(context, [self.pointArray[i] intValue], [self.pointArray[i+1] intValue]);
    i += 2;
  }
  
  CGContextStrokePath(context);
}

@end
