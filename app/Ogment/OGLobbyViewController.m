//
//  OGLobbyViewController.m
//  Ogment
//
//  Created by Joël Gähwiler on 01.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "ECClient.h"

#import "OGGeneral.h"
#import "OGLobbyViewController.h"
#import "OGTheme.h"
#import "OGLine.h"
#import "OGDeviceIndicator.h"
#import "OGSingleCountdown.h"
#import "OGGameEventHandler.h"

@implementation OGLobbyViewController {
  UILabel* _titleLabel;
  UILabel* _statusLabel;
  UIButton* _endGameButton;
  UIButton* _startSearchButton;
  OGLine* _line;
  OGLine* _rect;
  OGDeviceIndicator* _currentDevice;
  OGDeviceIndicator* _facingDevice;
  OGDeviceIndicator* _rightDevice;
  OGDeviceIndicator* _leftDevice;
  OGSingleCountdown* _gameCountdown;
  
  NSTimer* _gameTimer;
  double _gameSeconds;
  
  BOOL _blocked;
  BOOL _playable;
  
  OGGameEventHandler* _gameEventHandler;
  
  ECEventHandler* _deviceMatrixChangeHandler;
  ECEventHandler* _gameStartedHandler;
  ECEventHandler* _gameEndedHandler;
  ECEventHandler* _shutdownHandler;
}

- (void)loadView
{
  _blocked = NO;
  _playable = NO;
  
  self.view = [[UIView alloc] init];
  
  _titleLabel = [OGTheme labelWithAlignment:OGAlignmentBottomCenter andSize:CGSizeMake(300,50) andPoint:CGPointMake(512, 180)];
  _titleLabel.textAlignment = NSTextAlignmentCenter;
  _titleLabel.text = @"AKTUELLES SPIEL";
  _titleLabel.font = [OGTheme titleFont];
  
  _statusLabel = [OGTheme labelWithAlignment:OGAlignmentTopCenter andSize:CGSizeMake(400,50) andPoint:CGPointMake(512, 180)];
  _statusLabel.textAlignment = NSTextAlignmentCenter;
  _statusLabel.text = @"Warte auf Server...";
  
  _endGameButton = [OGTheme buttonWithAlignment:OGAlignmentCenterCenter andPoint:CGPointMake(256, 650) andTitle:@"VERLASSEN"];
  _startSearchButton = [OGTheme buttonWithAlignment:OGAlignmentCenterCenter andPoint:CGPointMake(768, 650) andTitle:@"SUCHE STARTEN"];
  
  _startSearchButton.hidden = YES;
  
  [_endGameButton addTarget:self action:@selector(endGame) forControlEvents:UIControlEventTouchUpInside];
  [_startSearchButton addTarget:self action:@selector(startSearch) forControlEvents:UIControlEventTouchUpInside];
  
  _line = [OGLine lineWithArray:@[@0,@650, @512,@650, @512,@489, @512,@650, @1024,@650] andFrame:CGRectMake(0, 0, 1024, 768)];
  _rect = [OGLine lineWithArray:@[@427,@299, @597,@299, @597,@469, @427,@469, @427,@298] andFrame:CGRectMake(0, 0, 1024, 768)];
  
  _currentDevice = [[OGDeviceIndicator alloc] initWithFrame:CGRectMake(487, 444, 50, 50)];
  _facingDevice = [[OGDeviceIndicator alloc] initWithFrame:CGRectMake(487, 274, 50, 50)];
  _leftDevice = [[OGDeviceIndicator alloc] initWithFrame:CGRectMake(404, 359, 50, 50)];
  _rightDevice = [[OGDeviceIndicator alloc] initWithFrame:CGRectMake(572, 359, 50, 50)];
  
  [_currentDevice setState:OGDeviceIndicatorStateActive];
  
  _gameCountdown = [[OGSingleCountdown alloc] initWithFrame:CGRectMake(472, 610, 80, 80)];
  _gameCountdown.hidden = YES;
  
  _deviceMatrixChangeHandler = [[ECClient sharedClient] registerHandlerBlock:^(ECEvent *event) {
    int opponents = 0;
    NSDictionary* data = event.payload;
    NSArray* matrix = @[ @[@"left", _leftDevice], @[@"right", _rightDevice], @[@"facing", _facingDevice] , @[@"current",_currentDevice] ];
    for (NSArray* pair in matrix) {
      if([[data objectForKey:pair[0]] intValue] == 2) {
        [pair[1] setState:OGDeviceIndicatorStateLeader];
      } else if([[data objectForKey:pair[0]] intValue] == 1) {
        [pair[1] setState:OGDeviceIndicatorStateActive];
        if(![@"current" isEqualToString:pair[0]]) {
          opponents++;
        }
      } else {
        [pair[1] setState:OGDeviceIndicatorStateInactive];
      }
    }
    if(opponents>0) {
      _playable = YES;
      [self updateGUI];
      if(!_blocked) {
        _statusLabel.text = [NSString stringWithFormat:@"Spiele mit %d Spieler", opponents];
      }
    } else {
      _playable = NO;
      [self updateGUI];
      if(!_blocked) {
        _statusLabel.text = @"Keine Spieler zurzeit aktiv";
      }
    }
  } forEvent:@"active_device_matrix_changed"];
  
  _gameStartedHandler = [[ECClient sharedClient] registerHandlerBlock:^(ECEvent *event) {
    _blocked = YES;
    [self updateGUI];
    _gameSeconds = 0;
    _gameTimer = [NSTimer scheduledTimerWithTimeInterval:OG_TIMER_RESOLUTION target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_gameTimer forMode:NSRunLoopCommonModes];
    _statusLabel.text = @"Suche wurde betätigt";
    _gameEventHandler = [[OGGameEventHandler alloc] init];
    [_gameEventHandler handleEventsWithViewController:self inMode:event.payload];
  } forEvent:@"game_started"];
  
  _gameEndedHandler = [[ECClient sharedClient] registerHandlerBlock:^(ECEvent *event) {
    [_gameTimer invalidate];
    _blocked = NO;
    [self updateGUI];
    _statusLabel.text = @"Suche wurde beendet";
    [_gameEventHandler stop];
    delay_block(1, ^void{
      [self.navigationController popToViewController:self animated:YES];
    });
  } forEvent:@"game_ended"];
  
  _shutdownHandler = [[ECClient sharedClient] registerInlineHandlerBlock:^(ECEvent *event) {
    if(_gameTimer) {
      [_gameTimer invalidate];
    }
    [[ECClient sharedClient] dispatchInlineEventWithType:@"game_time_end" andPayload:nil];
  } forEvent:@"shutdown"];
  
  [self.view addSubview:_line];
  [self.view addSubview:_rect];
  [self.view addSubview:_titleLabel];
  [self.view addSubview:_statusLabel];
  [self.view addSubview:_endGameButton];
  [self.view addSubview:_startSearchButton];
  [self.view addSubview:_currentDevice];
  [self.view addSubview:_facingDevice];
  [self.view addSubview:_leftDevice];
  [self.view addSubview:_rightDevice];
  [self.view addSubview:_gameCountdown];
}

- (void)updateGUI
{
  _endGameButton.hidden = _blocked;
  _startSearchButton.hidden = !_playable || _blocked;
  _gameCountdown.hidden = !_blocked;
}

- (void)endGame
{
  [[ECClient sharedClient] dispatchEventWithType:@"activness_changed" andPayload:[NSNumber numberWithBool:NO]];
  [[ECClient sharedClient] removeHandler:_gameStartedHandler];
  [[ECClient sharedClient] removeHandler:_gameEndedHandler];
  [[ECClient sharedClient] removeHandler:_deviceMatrixChangeHandler];
  [[ECClient sharedClient] removeInlineHandler:_shutdownHandler];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)startSearch
{
  [[ECClient sharedClient] dispatchEventWithType:@"request_new_game" andPayload:@""];
}

- (void)onTick:(NSTimer *)timer
{
  _gameSeconds += OG_TIMER_RESOLUTION;
  [[ECClient sharedClient] dispatchInlineEventWithType:@"game_time_progress" andPayload:[NSNumber numberWithFloat:_gameSeconds/OG_GAME_TIME]];
  [_gameCountdown setProgress:_gameSeconds/OG_GAME_TIME];
  if(_gameSeconds > OG_GAME_TIME) {
    [_gameTimer invalidate];
    [[ECClient sharedClient] dispatchInlineEventWithType:@"game_time_end" andPayload:nil];
    [[ECClient sharedClient] dispatchEventWithType:@"end_game" andPayload:@""];
  }
}

#pragma mark - OGGameHandlerDelegate

- (void)didCancelGame {}

@end
