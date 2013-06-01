//
//  OGTheme.h
//  Ogment
//
//  Created by Joël Gähwiler on 23.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSTextField;

typedef enum {
  OGAlignmentTopLeft,
  OGAlignmentTopCenter,
  OGAlignmentTopRight,
  OGAlignmentBottomLeft,
  OGAlignmentBottomCenter,
  OGAlignmentBottomRight,
  OGAlignmentCenterLeft,
  OGAlignmentCenterCenter,
  OGAlignmentCenterRight,
} OGAlignment;

@interface OGTheme : NSObject

+ (UIButton*)buttonWithAlignment:(OGAlignment)alignment andPoint:(CGPoint)point andTitle:(NSString*)title;
+ (UILabel*)labelWithAlignment:(OGAlignment)alignment andSize:(CGSize)size andPoint:(CGPoint)point;
+ (SSTextField*)textFieldWithAlignment:(OGAlignment)alignment andSIze:(CGSize)size andPoint:(CGPoint)point;

+ (UIFont*)defaultFont;
+ (UIFont*)defaultFontBold;
+ (UIFont*)titleFont;
+ (UIFont*)taskFont;

+ (UIColor*)grayColor;

+ (void)styleLabel:(UILabel*)label;
+ (void)styleButton:(UIButton*)button;
+ (void)styleSegmentedControl:(UISegmentedControl*)control;
+ (void)styleTextField:(SSTextField*)textField;
+ (void)styleTableView:(UITableView*)tableView;
+ (void)styleTableViewCell:(UITableViewCell*)tableViewCell;

@end
