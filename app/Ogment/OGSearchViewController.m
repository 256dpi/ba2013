//
//  OGSearchViewController.m
//  Ogment
//
//  Created by Joël Gähwiler on 02.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <SSToolkit/SSTextField.h>

#import "ECClient.h"

#import "OGSearchViewController.h"
#import "OGSingleCountdown.h"
#import "OGTheme.h"
#import "OGLine.h"

@implementation OGSearchViewController {
  UILabel* _titleLabel;
  UILabel* _descriptionLabel;
  SSTextField* _searchField;
  UIButton* _searchButton;
  OGSingleCountdown* _countdown;
  OGLine* _line;
  UIActivityIndicatorView* _indicator;
  UIButton* _closeButton;
  
  ECEventHandler* _gameTimeProgressHandler;
  ECEventHandler* _releaseSearchHandler;
}

- (id)init
{
  if(self = [super init]) {
    self.useTimer = YES;
  }
  return self;
}

- (void)loadView
{
  self.view = [[UIView alloc] init];
  
  _line = [OGLine lineWithArray:@[@0,@650, @512,@650, @512,@295, @512,@650, @1024,@650] andFrame:CGRectMake(0, 0, 1024, 768)];
  
  _titleLabel = [OGTheme labelWithAlignment:OGAlignmentBottomCenter andSize:CGSizeMake(600,50) andPoint:CGPointMake(512, 180)];
  _titleLabel.textAlignment = NSTextAlignmentCenter;
  _titleLabel.text = @"NEUE SUCHE";
  _titleLabel.font = [OGTheme titleFont];
  
  _descriptionLabel = [OGTheme labelWithAlignment:OGAlignmentTopCenter andSize:CGSizeMake(600, 50) andPoint:CGPointMake(512, 180)];
  _descriptionLabel.textAlignment = NSTextAlignmentCenter;
  _descriptionLabel.text = @"Suche einen Artikel auf Wikipedia.";
  
  _searchField = [OGTheme textFieldWithAlignment:OGAlignmentCenterCenter andSIze:CGSizeMake(500, 60) andPoint:CGPointMake(512, 295)];
  _searchField.placeholder = @"Suchbegriff eingeben...";
  _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
  _searchField.delegate = self;
  _searchField.autocorrectionType = UITextAutocorrectionTypeNo;
  
  _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  _indicator.center = CGPointMake(732, 295);
  _indicator.hidesWhenStopped = YES;
  
  _searchButton = [OGTheme buttonWithAlignment:OGAlignmentCenterCenter andPoint:CGPointMake(512, 375) andTitle:@"SUCHEN"];
  [_searchButton addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
  
  _closeButton = [OGTheme buttonWithAlignment:OGAlignmentCenterCenter andPoint:CGPointMake(256, 650) andTitle:@"SUCHE BEENDEN"];
  [_closeButton addTarget:self action:@selector(endSearch) forControlEvents:UIControlEventTouchUpInside];
  
  _releaseSearchHandler = [[ECClient sharedClient] registerInlineHandlerBlock:^(ECEvent *event) {
    _searchButton.hidden = NO;
    _searchField.enabled = YES;
    [_indicator stopAnimating];
  } forEvent:@"release_search"];
  
  [self.view addSubview:_line];
  [self.view addSubview:_titleLabel];
  [self.view addSubview:_searchButton];
  [self.view addSubview:_searchField];
  [self.view addSubview:_indicator];
  [self.view addSubview:_closeButton];
  [self.view addSubview:_descriptionLabel];
  
  if(self.useTimer) {
    _countdown = [[OGSingleCountdown alloc] initWithFrame:CGRectMake(472, 610, 80, 80)];
    
    _gameTimeProgressHandler = [[ECClient sharedClient] registerInlineHandlerBlock:^(ECEvent *event) {
      [_countdown setProgress:[event.payload floatValue]];
    } forEvent:@"game_time_progress"];
    
    [self.view addSubview:_countdown];
  }
}

- (void)search
{
  if(_searchField.text.length > 0) {
    _searchButton.hidden = YES;
    _searchField.enabled = NO;
    [_indicator startAnimating];
    [self.delegate didStartSearch:self];    
  }
}

- (void)endSearch
{
  [[ECClient sharedClient] dispatchEventWithType:@"end_game" andPayload:@""];
}

- (NSString *)searchTerm
{
  if(_searchField.text) {
    return _searchField.text;
  }
  return @"";
}

- (void)close
{
  [[ECClient sharedClient] removeInlineHandler:_gameTimeProgressHandler];
  [[ECClient sharedClient] removeInlineHandler:_releaseSearchHandler];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
  [aTextField resignFirstResponder];
  [self search];
  return YES;
}

@end
