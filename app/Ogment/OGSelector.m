//
//  OGSelector.m
//  Ogment
//
//  Created by Joël Gähwiler on 01.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "OGSelector.h"
#import "OGTheme.h"

#define OG_SELECTOR_INSET 30

@implementation OGSelector {
  UILabel* _titleLabel;
  UILabel* _descriptionLabel;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    CGRect rect = CGRectInset(frame, OG_SELECTOR_INSET, OG_SELECTOR_INSET);
    
    _titleLabel = [OGTheme labelWithAlignment:OGAlignmentTopLeft andSize:CGSizeMake(rect.size.width, abs(rect.size.height/3)) andPoint:CGPointMake(OG_SELECTOR_INSET, OG_SELECTOR_INSET)];
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    _titleLabel.opaque = NO;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [OGTheme defaultFontBold];
    
    _descriptionLabel = [OGTheme labelWithAlignment:OGAlignmentBottomLeft andSize:CGSizeMake(rect.size.width, abs(rect.size.height/3*2)) andPoint:CGPointMake(OG_SELECTOR_INSET , rect.size.height+OG_SELECTOR_INSET)];
    _descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _descriptionLabel.textAlignment = NSTextAlignmentCenter;
    _descriptionLabel.numberOfLines = 0;
    _descriptionLabel.opaque = NO;
    _descriptionLabel.backgroundColor = [UIColor clearColor];
    
    self.selected = NO;
    
    [self addSubview:_titleLabel];
    [self addSubview:_descriptionLabel];
  }
  return self;
}

- (void)drawRect:(CGRect)rect
{  
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  
  [[UIColor blackColor] set];
  CGContextSetLineWidth(ctx, 2);
  CGContextStrokeRect(ctx, CGRectInset(self.bounds, 1, 1));
}

- (void)setID:(NSString *)id andTitle:(NSString *)title andDescription:(NSString *)description
{
  self.id = id;
  _titleLabel.text = title;
  _descriptionLabel.text = description;
}

- (void)setSelected:(BOOL)selected {
  _selected = selected;
  if(self.selected) {
    self.backgroundColor = [UIColor blackColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _descriptionLabel.textColor = [UIColor whiteColor];
    _descriptionLabel.font = [OGTheme defaultFontBold];
  } else {
    self.backgroundColor = [UIColor whiteColor];
    _titleLabel.textColor = [UIColor blackColor];
    _descriptionLabel.textColor = [UIColor blackColor];
    _descriptionLabel.font = [OGTheme defaultFont];
  }
}

@end
