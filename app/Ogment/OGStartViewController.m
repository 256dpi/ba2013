//
//  OGStartViewController.m
//  Ogment
//
//  Created by Joël Gähwiler on 30.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <UIView+DrawRectBlock.h>

#import "ECClient.h"

#import "OGStartViewController.h"
#import "OGLobbyViewController.h"
#import "OGDemoViewController.h"
#import "OGRulesViewController.h"
#import "OGTheme.h"
#import "OGLine.h"

@implementation OGStartViewController {
  UIButton* _startGameButton;
  UIButton* _startTutorialButton;
  UIButton* _openRulesButton;
  UIButton* _restartButton;
  UIImageView* _logoView;
  OGLine* _line;
}

- (void)loadView
{
  self.view = [[UIView alloc] init];
  
  _openRulesButton = [OGTheme buttonWithAlignment:OGAlignmentCenterRight andPoint:CGPointMake(431, 650) andTitle:@"REGELN LESEN"];
  _startTutorialButton = [OGTheme buttonWithAlignment:OGAlignmentCenterCenter andPoint:CGPointMake(512, 650) andTitle:@"TUTORIAL"];
  _startGameButton = [OGTheme buttonWithAlignment:OGAlignmentCenterLeft andPoint:CGPointMake(593, 650) andTitle:@"SPIEL BEGINNEN"];
  _restartButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _restartButton.frame = CGRectMake(0, 0, 44, 44);
  
  [_openRulesButton addTarget:self action:@selector(openRules) forControlEvents:UIControlEventTouchUpInside];
  [_startTutorialButton addTarget:self action:@selector(startTutorial) forControlEvents:UIControlEventTouchUpInside];
  [_startGameButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
  [_restartButton addTarget:self action:@selector(restart) forControlEvents:UIControlEventTouchUpInside];
  
  _logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];
  _logoView.center = CGPointMake(512, 325);
  
  _line = [OGLine lineWithArray:@[@0,@650, @1024,@650] andFrame:CGRectMake(0, 0, 1024, 768)];
  
  [self.view addSubview:_line];
  [self.view addSubview:_openRulesButton];
  [self.view addSubview:_startGameButton];
  [self.view addSubview:_startTutorialButton];
  [self.view addSubview:_logoView];
  [self.view addSubview:_restartButton];
}

- (void)startTutorial
{
  OGDemoViewController* demoViewController = [[OGDemoViewController alloc] init];
  [self.navigationController pushViewController:demoViewController animated:YES];
  
  [[ECClient sharedClient] dispatchEventWithType:@"activness_changed" andPayload:[NSNumber numberWithBool:NO]];
}

- (void)startGame
{
  OGLobbyViewController* lobbyViewController = [[OGLobbyViewController alloc] init];
  [self.navigationController pushViewController:lobbyViewController animated:YES];
  
  [[ECClient sharedClient] dispatchEventWithType:@"activness_changed" andPayload:[NSNumber numberWithBool:YES]];
}

- (void)openRules
{
  OGRulesViewController* rulesViewController = [[OGRulesViewController alloc] init];
  [self.navigationController pushViewController:rulesViewController animated:YES];
}

- (void)restart
{
  exit(0);
}

@end
