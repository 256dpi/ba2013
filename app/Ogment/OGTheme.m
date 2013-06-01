//
//  OGTheme.m
//  Ogment
//
//  Created by Joël Gähwiler on 23.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <SSToolkit/SSTextField.h>

#import "OGTheme.h"

@implementation OGTheme

+ (UIButton *)buttonWithAlignment:(OGAlignment)alignment andPoint:(CGPoint)point andTitle:(NSString *)title
{
  UIButton* button = [[UIButton alloc] init];
  [self styleButton:button];
  [button setTitle:title forState:UIControlStateNormal];
  
  CGSize textSize = [title sizeWithFont:[self defaultFont]];
  textSize.width += 20*2;
  textSize.height += 20*2-9;
  
  CGRect frame = CGRectMake(0, 0, textSize.width, textSize.height);
  [button setFrame:[self _alignFrame:frame withAlignment:alignment andPoint:point]];
  
  return button;
}

+ (UILabel *)labelWithAlignment:(OGAlignment)alignment andSize:(CGSize)size andPoint:(CGPoint)point;
{
  UILabel* label = [[UILabel alloc] init];
  [self styleLabel:label];
  
  CGRect frame = CGRectMake(0, 0, size.width, size.height);
  [label setFrame:[self _alignFrame:frame withAlignment:alignment andPoint:point]];
  
  return label;
}

+ (SSTextField *)textFieldWithAlignment:(OGAlignment)alignment andSIze:(CGSize)size andPoint:(CGPoint)point
{
  SSTextField* textField = [[SSTextField alloc] init];
  [self styleTextField:textField];
  
  CGSize textSize = [@"TEST" sizeWithFont:[self defaultFont]];
  textSize.height += 15*2;
  
  CGRect frame = CGRectMake(0, 0, size.width, textSize.height);
  [textField setFrame:[self _alignFrame:frame withAlignment:alignment andPoint:point]];
  
  return textField;
}

+ (UIFont*)defaultFont
{
  return [UIFont fontWithName:@"Quicksand-Regular" size:17];
}

+ (UIFont*)defaultFontBold
{
  return [UIFont fontWithName:@"Quicksand-Bold" size:17];
}

+ (UIFont*)titleFont
{
  return [UIFont fontWithName:@"Quicksand-Regular" size:30];
}

+ (UIFont*)taskFont
{
  return [UIFont fontWithName:@"Quicksand-Bold" size:30];
}

+ (UIColor *)grayColor
{
  return [UIColor colorWithWhite:0.6 alpha:1];
}

+ (void)styleLabel:(UILabel *)label
{
  label.font = [self defaultFont];
}

+ (void)styleButton:(UIButton *)button
{
  button.titleLabel.font = [self defaultFontBold];
  
  button.titleEdgeInsets = UIEdgeInsetsMake(22,20,20,20);

  [button setBackgroundImage:[[UIImage imageNamed:@"Button-normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(3,3,3,3)] forState:UIControlStateNormal];
  [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

  [button setBackgroundImage:[[UIImage imageNamed:@"Button-highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(3,3,3,3)] forState:UIControlStateHighlighted];
  [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

+ (void)styleSegmentedControl:(UISegmentedControl*)control
{
  [control setBackgroundImage:[[UIImage imageNamed:@"Button-normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(3,3,3,3)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  
  [control setBackgroundImage:[[UIImage imageNamed:@"Button-highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(3,3,3,3)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
}

+ (void)styleTextField:(SSTextField *)textField
{
  [textField setBorderStyle:UITextBorderStyleLine];
  textField.layer.borderWidth = 2;
  textField.font = [self defaultFont];
  textField.textEdgeInsets = UIEdgeInsetsMake(15, 20, 0, 20);
  textField.clearButtonEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);
  textField.backgroundColor = [UIColor whiteColor];
}

+ (void)styleTableView:(UITableView *)tableView
{
  tableView.separatorColor = [UIColor blackColor];
  tableView.layer.borderWidth = 2;
  tableView.layer.borderColor = [UIColor blackColor].CGColor;
}

+ (void)styleTableViewCell:(UITableViewCell *)tableViewCell
{
  tableViewCell.textLabel.font = [self defaultFontBold];
  
  UIView* background = [[UIView alloc] init];
  [background setBackgroundColor:[UIColor blackColor]];
  [tableViewCell setSelectedBackgroundView:background];
}

#pragma mark - Helpers

+ (CGRect)_alignFrame:(CGRect)frame withAlignment:(OGAlignment)alignment andPoint:(CGPoint)point
{
  switch (alignment) {
    case OGAlignmentTopLeft:
      frame.origin.x = point.x;
      frame.origin.y = point.y;
      break;
    case OGAlignmentTopCenter:
      frame.origin.x = point.x-abs(frame.size.width/2);
      frame.origin.y = point.y;
      break;
    case OGAlignmentTopRight:
      frame.origin.x = point.x-frame.size.width;
      frame.origin.y = point.y;
      break;
    case OGAlignmentCenterLeft:
      frame.origin.x = point.x;
      frame.origin.y = point.y-abs(frame.size.height/2);
      break;
    case OGAlignmentCenterCenter:
      frame.origin.x = point.x-abs(frame.size.width/2);
      frame.origin.y = point.y-abs(frame.size.height/2);
      break;
    case OGAlignmentCenterRight:
      frame.origin.x = point.x-frame.size.width;
      frame.origin.y = point.y-abs(frame.size.height/2);
      break;
    case OGAlignmentBottomLeft:
      frame.origin.x = point.x;
      frame.origin.y = point.y-frame.size.height;
      break;
    case OGAlignmentBottomCenter:
      frame.origin.x = point.x-abs(frame.size.width/2);
      frame.origin.y = point.y-frame.size.height;
      break;
    case OGAlignmentBottomRight:
      frame.origin.x = point.x-frame.size.width;
      frame.origin.y = point.y-frame.size.height;
      break;
  }
  return frame;
}

@end
