//
//  OGGameEventHandler.m
//  Ogment
//
//  Created by Joël Gähwiler on 01.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "ECClient.h"

#import "OGGameEventHandler.h"
#import "OGSelectorViewController.h"
#import "OGSearchViewController.h"
#import "OGAlertView.h"
#import "OGCreateFakeResultViewController.h"
#import "OGResultsViewController.h"
#import "OGResultViewController.h"
#import "OGManipulatePageViewController.h"
#import "OGGeneral.h"

@implementation OGGameEventHandler {
  UIViewController* _viewController;
  OGSearchViewController* _searchViewController;
  NSString* _mode;
  
  NSArray* _lastResults;
  
  ECEventHandler* _selectAttackHandler;
  ECEventHandler* _gameCancelHandler;
  ECEventHandler* _displayResultsHandler;
  ECEventHandler* _createFakeResultHandler;
  ECEventHandler* _requestPageHandler;
  ECEventHandler* _manipulatePageHandler;
}

- (void)handleEventsWithViewController:(id)viewController inMode:(NSString *)mode
{
  _viewController = viewController;
  _mode = mode;
  
  _selectAttackHandler = [[ECClient sharedClient] registerHandlerBlock:^(ECEvent *event) {
    OGSelectorViewController* attackSelectorViewController = [[OGSelectorViewController alloc] initWithType:OGSelectorTypeAttack];
    attackSelectorViewController.delegate = self;
    attackSelectorViewController.useTimer = ![self isDemo];
    [_viewController.navigationController pushViewController:attackSelectorViewController animated:YES];
  } forEvent:@"select_attack"];
  
  _gameCancelHandler = [[ECClient sharedClient] registerHandlerBlock:^(ECEvent *event) {
    OGAlertView* alert;
    if([@"denial_of_service" isEqualToString:event.payload]) {
      alert = [[OGAlertView alloc] initWithTitle:@"DENIAL OF SERVICE" message:@"Der Zug wurde durch einen 'Denial of Service' Angriff sofort beendet." cancelButtonTitle:@"OK"];
    } else if([@"fake_result" isEqualToString:event.payload]) {
      alert = [[OGAlertView alloc] initWithTitle:@"PHISHING" message:@"Der Zug wurde durch einen 'PHISHING' Angriff sofort beendet." cancelButtonTitle:@"OK"];
    }
    [alert show];
    [self cancel];
  } forEvent:@"game_canceled"];
  
  _createFakeResultHandler = [[ECClient sharedClient] registerHandlerBlock:^(ECEvent *event) {
    OGCreateFakeResultViewController* createFakeResultController = [[OGCreateFakeResultViewController alloc] init];
    createFakeResultController.useTimer = ![self isDemo];
    [_viewController.navigationController pushViewController:createFakeResultController animated:YES];
  } forEvent:@"create_fake_result"];
  
  _displayResultsHandler = [[ECClient sharedClient] registerHandlerBlock:^(ECEvent *event) {
    OGResultsViewController* resultsViewController = [[OGResultsViewController alloc] init];
    _lastResults = event.payload;
    resultsViewController.results = event.payload;
    resultsViewController.useTimer = ![self isDemo];
    delay_block(1, ^{
      [_viewController.navigationController pushViewController:resultsViewController animated:YES];
    });
  } forEvent:@"display_results"];
  
  _requestPageHandler = [[ECClient sharedClient] registerHandlerBlock:^(ECEvent *event) {
    OGResultViewController* resultViewController = [[OGResultViewController alloc] init];
    resultViewController.content = event.payload[@"page"];
    resultViewController.url = event.payload[@"url"];
    resultViewController.useTimer = ![self isDemo];
    for(NSDictionary* item in _lastResults) {
      if([item[@"url"] isEqualToString:event.payload[@"url"]]) {
        if([item[@"type"] isEqualToString:@"censored"]) {
          resultViewController.censored = YES;
        }
      }
    }
    [_viewController.navigationController pushViewController:resultViewController animated:YES];
  } forEvent:@"display_page"];
  
  _manipulatePageHandler = [[ECClient sharedClient] registerHandlerBlock:^(ECEvent *event) {
    OGManipulatePageViewController* manipulatePageViewController = [[OGManipulatePageViewController alloc] init];
    manipulatePageViewController.content = event.payload[@"page"];
    manipulatePageViewController.url = event.payload[@"url"];
    manipulatePageViewController.useTimer = ![self isDemo];
    [_viewController.navigationController pushViewController:manipulatePageViewController animated:YES];
  } forEvent:@"manipulate_page"];
  
  OGSelectorViewController* selectorViewController;
  
  if([self isDemo] || [self isOpponent]) {
    selectorViewController = [[OGSelectorViewController alloc] initWithType:OGSelectorTypeStrategy];
  } else if([self isPlayer]) {
    selectorViewController = [[OGSelectorViewController alloc] initWithType:OGSelectorTypeProtection];
  }
  
  selectorViewController.delegate = self;
  selectorViewController.useTimer = ![self isDemo];
  [_viewController.navigationController pushViewController:selectorViewController animated:YES];
}

- (void)stop
{
  if(_searchViewController) {
    [_searchViewController close];
  }
  [[ECClient sharedClient] removeHandler:_selectAttackHandler];
  [[ECClient sharedClient] removeHandler:_gameCancelHandler];
  [[ECClient sharedClient] removeHandler:_createFakeResultHandler];
  [[ECClient sharedClient] removeHandler:_displayResultsHandler];
  [[ECClient sharedClient] removeHandler:_requestPageHandler];
  [[ECClient sharedClient] removeHandler:_manipulatePageHandler];
}

- (void)cancel
{
  [self stop];
  [self.delegate didCancelGame];
}

#pragma mark - OGSelectorViewControllerDelegate

- (void)didEndSelection:(OGSelectorViewController*)selectorViewController
{
  NSMutableArray *controllers = [NSMutableArray arrayWithArray:_viewController.navigationController.viewControllers];
  [controllers removeLastObject];
  
  switch(selectorViewController.type) {
    case OGSelectorTypeStrategy: {
      [[ECClient sharedClient] dispatchEventWithType:@"strategy_changed" andPayload:selectorViewController.selectedSelector];
      if([self isDemo]) {
        OGSelectorViewController* protectionSelectorViewController = [[OGSelectorViewController alloc] initWithType:OGSelectorTypeProtection];
        protectionSelectorViewController.delegate = self;
        protectionSelectorViewController.useTimer = ![self isDemo];
        [controllers addObject:protectionSelectorViewController];
      }
      break;
    }
    case OGSelectorTypeProtection: {
      [[ECClient sharedClient] dispatchEventWithType:@"protection_changed" andPayload:selectorViewController.selectedSelector];
      _searchViewController = [[OGSearchViewController alloc] init];
      _searchViewController.delegate = self;
      _searchViewController.useTimer = ![self isDemo];
      [controllers addObject:_searchViewController];
      break;
    }
    case OGSelectorTypeAttack:
      [[ECClient sharedClient] dispatchEventWithType:@"attack_selected" andPayload:selectorViewController.selectedSelector];
      break;
  }
  
  [selectorViewController close];
  
  [_viewController.navigationController setViewControllers:controllers animated:YES];
}

#pragma mark - OGSearchViewControllerDelegate

- (void)didStartSearch:(id)searchViewController
{
  [[ECClient sharedClient] dispatchEventWithType:@"new_search" andPayload:[searchViewController searchTerm]];
}

#pragma mark - Helpers

- (BOOL)isDemo
{
  return [_mode isEqualToString:@"demo"];
}

- (BOOL)isPlayer
{
  return [_mode isEqualToString:@"player"];
}

- (BOOL)isOpponent
{
  return [_mode isEqualToString:@"opponent"];
}

@end
