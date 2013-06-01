//
//  OGAlertView.m
//  Ogment
//
//  Created by Joël Gähwiler on 23.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "OGAlertView.h"
#import "OGTheme.h"

@implementation OGAlertView {
  UIView* _background;
  UILabel* _titleLabel;
  UILabel* _messageLabel;
  UIButton* _cancelButton;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle
{
  if(self = [self initWithFrame:CGRectMake(0, 0, 400, 300)]) {
    
    _background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 300)];
    _background.backgroundColor = [UIColor whiteColor];
    
    _titleLabel = [OGTheme labelWithAlignment:OGAlignmentTopLeft andSize:CGSizeMake(400, 100) andPoint:CGPointMake(0, 0)];
    _titleLabel.text = title;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [OGTheme defaultFontBold];
    
    _messageLabel = [OGTheme labelWithAlignment:OGAlignmentTopLeft andSize:CGSizeMake(350, 150) andPoint:CGPointMake(25, 75)];
    _messageLabel.text = message;
    _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.numberOfLines = 0;
    
    _cancelButton = [OGTheme buttonWithAlignment:OGAlignmentTopCenter andPoint:CGPointMake(200, 225) andTitle:cancelButtonTitle];
    [_cancelButton addTarget:self action:@selector(didClickOnButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_background];
    [self addSubview:_titleLabel];
    [self addSubview:_messageLabel];
    [self addSubview:_cancelButton];
  }
  return self;
}

- (void)didClickOnButton
{
  [self hide];
}

@end
