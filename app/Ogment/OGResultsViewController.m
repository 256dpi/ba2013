//
//  OGResultsViewController.m
//  Ogment
//
//  Created by Joël Gähwiler on 02.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "ECClient.h"

#import "OGResultsViewController.h"
#import "OGLine.h"
#import "OGTheme.h"
#import "OGSingleCountdown.h"

@implementation OGResultsViewController {
  UITableView* _tableView;
  OGLine* _line;
  UIButton* _closeButton;
  OGSingleCountdown* _countdown;
  UIActivityIndicatorView* _indicator;
  
  NSIndexPath* _currentSelection;
  
  ECEventHandler* _gameTimeProgressHandler;
  ECEventHandler* _releaseResultsHandler;
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
  
  _closeButton = [OGTheme buttonWithAlignment:OGAlignmentCenterCenter andPoint:CGPointMake(256, 650) andTitle:@"ZURÜCK"];
  [_closeButton addTarget:self action:@selector(newSearch) forControlEvents:UIControlEventTouchUpInside];
  
  _tableView = [[UITableView alloc] initWithFrame:CGRectMake(50, 50, 924, 514) style:UITableViewStylePlain];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  
  [OGTheme styleTableView:_tableView];
  
  _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  _indicator.hidesWhenStopped = YES;
  
  _releaseResultsHandler = [[ECClient sharedClient] registerInlineHandlerBlock:^(ECEvent *event) {
    _tableView.userInteractionEnabled = YES;
    if(_currentSelection) {
      [_tableView deselectRowAtIndexPath:_currentSelection animated:YES];
      _currentSelection = nil;
      _closeButton.hidden = NO;
      [_indicator stopAnimating];
    }
  } forEvent:@"release_results"];
  
  [self.view addSubview:_line];
  [self.view addSubview:_tableView];
  [self.view addSubview:_closeButton];
  [self.view addSubview:_indicator];
  
  if(self.useTimer) {
    _countdown = [[OGSingleCountdown alloc] initWithFrame:CGRectMake(472, 610, 80, 80)];
    
    _gameTimeProgressHandler = [[ECClient sharedClient] registerInlineHandlerBlock:^(ECEvent *event) {
      [_countdown setProgress:[event.payload floatValue]];
    } forEvent:@"game_time_progress"];
    
    [self.view addSubview:_countdown];
  }
}

- (void)close
{
  [[ECClient sharedClient] removeInlineHandler:_gameTimeProgressHandler];
}

- (void)newSearch
{
  [self close];
  [[ECClient sharedClient] dispatchInlineEventWithType:@"release_search" andPayload:nil];
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary* item = self.results[indexPath.row];
  
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"string-cell"];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"string-cell"];
    [OGTheme styleTableViewCell:cell];
  }
  cell.textLabel.text = item[@"title"];
  if(![item[@"type"] isEqualToString:@"ad"]) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.userInteractionEnabled = YES;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = NO;
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary* item = self.results[indexPath.row];
  
  if([item[@"type"] isEqualToString:@"fake"]) {
    [[ECClient sharedClient] dispatchEventWithType:@"fake_result_selected" andPayload:@""];
  } else {
    [[ECClient sharedClient] dispatchEventWithType:@"request_page" andPayload:self.results[indexPath.row][@"url"]];
  }
  
  CGRect rectOfCellInTableView = [_tableView rectForRowAtIndexPath:indexPath];
  CGRect rectOfCellInSuperview = [_tableView convertRect:rectOfCellInTableView toView:[self.view superview]];
  
  _indicator.center = CGPointMake(925, rectOfCellInSuperview.origin.y+22);
  [_indicator startAnimating];
  
  _currentSelection = indexPath;
  tableView.userInteractionEnabled = NO;
  _closeButton.hidden = YES;
}

@end
