//
//  OGRulesViewController.m
//  Ogment
//
//  Created by Joël Gähwiler on 27.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "OGRulesViewController.h"
#import "OGTheme.h"

@implementation OGRulesViewController {
  UIScrollView* _scrollView;
  UIButton* _closeButton;
}

- (void)loadView
{
  self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
  
  _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
  UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rules.png"]];
  _scrollView.contentSize = image.frame.size;
  [_scrollView addSubview:image];
  
  _closeButton = [OGTheme buttonWithAlignment:OGAlignmentTopRight andPoint:CGPointMake(1024-20, 20) andTitle:@"SCHLIESSEN"];
  [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:_scrollView];
  [self.view addSubview:_closeButton];
}

- (void)close
{
  [self.navigationController popViewControllerAnimated:YES];
}

@end
