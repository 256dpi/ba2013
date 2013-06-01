//
//  OGDemoViewController.m
//  Ogment
//
//  Created by Joël Gähwiler on 01.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "ECClient.h"

#import "OGGeneral.h"
#import "OGDemoViewController.h"
#import "OGLine.h"
#import "OGTheme.h"
#import "OGGameEventHandler.h"
#import "OGSingleCountdown.h"

@implementation OGDemoViewController {
  UILabel* _titleLabel;
  UILabel* _statusLabel;
  UILabel* _questionLabel;
  UIButton* _endGameButton;
  UIButton* _startSearchButton;
  OGLine* _line;  

  NSArray* _demoQuestions;  
  OGGameEventHandler* _gameEventHandler;
  
  ECEventHandler* _gameStartedHandler;
  ECEventHandler* _gameEndedHandler;
  ECEventHandler* _shutdownHandler;
}

- (void)loadView
{
  self.view = [[UIView alloc] init];
  
  _demoQuestions = @[@"Von welchem technischen Gerät stammt der Begriff 08/15?",@"Welches nordamerikanische Territorium wurde am 3. Januar 1959 zum 49. Bundesstaat?",@"In welchem Land sind die Wombats beheimatet?",@"Wo im menschlichen Körper befindet sich das Würfelbein?",@"Welche Insel ist die grösster der Welt?"];
  
  _titleLabel = [OGTheme labelWithAlignment:OGAlignmentBottomCenter andSize:CGSizeMake(300,50) andPoint:CGPointMake(512, 180)];
  _titleLabel.textAlignment = NSTextAlignmentCenter;
  _titleLabel.text = @"TUTORIAL";
  _titleLabel.font = [OGTheme titleFont];
  
  _statusLabel = [OGTheme labelWithAlignment:OGAlignmentTopCenter andSize:CGSizeMake(500,50) andPoint:CGPointMake(512, 180)];
  _statusLabel.textAlignment = NSTextAlignmentCenter;
  _statusLabel.text = @"Im Tutorial Modus kannst du das Spiel ausprobieren, indem du gegen dich selber spielst.";
  _statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
  _statusLabel.numberOfLines = 0;
  
  _questionLabel = [OGTheme labelWithAlignment:OGAlignmentCenterCenter andSize:CGSizeMake(500,200) andPoint:CGPointMake(512, 768/2)];
  _questionLabel.textAlignment = NSTextAlignmentCenter;
  _questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
  _questionLabel.numberOfLines = 0;
  _questionLabel.font = [OGTheme taskFont];
  [self randomQuestion];
  
  _endGameButton = [OGTheme buttonWithAlignment:OGAlignmentCenterCenter andPoint:CGPointMake(256, 650) andTitle:@"VERLASSEN"];
  _startSearchButton = [OGTheme buttonWithAlignment:OGAlignmentCenterCenter andPoint:CGPointMake(768, 650) andTitle:@"SUCHE STARTEN"];
  
  [_endGameButton addTarget:self action:@selector(endGame) forControlEvents:UIControlEventTouchUpInside];
  [_startSearchButton addTarget:self action:@selector(startSearch) forControlEvents:UIControlEventTouchUpInside];
  
  _line = [OGLine lineWithArray:@[@0,@650, @1024,@650] andFrame:CGRectMake(0, 0, 1024, 768)];
  
  _gameStartedHandler = [[ECClient sharedClient] registerHandlerBlock:^(ECEvent *event) {
    _gameEventHandler = [[OGGameEventHandler alloc] init];
    _gameEventHandler.delegate = self;
    [_gameEventHandler handleEventsWithViewController:self inMode:event.payload];
    _endGameButton.hidden = YES;
    _startSearchButton.hidden = YES;
  } forEvent:@"game_started"];
  
  _gameEndedHandler = [[ECClient sharedClient] registerHandlerBlock:^(ECEvent *event) {
    [_gameEventHandler stop];
    _endGameButton.hidden = NO;
    _startSearchButton.hidden = NO;
    delay_block(1, ^void{
      [self.navigationController popToViewController:self animated:YES];
    });
  } forEvent:@"game_ended"];
  
  _shutdownHandler = [[ECClient sharedClient] registerInlineHandlerBlock:^(ECEvent *event) {
    [[ECClient sharedClient] dispatchInlineEventWithType:@"game_time_end" andPayload:nil];
  } forEvent:@"shutdown"];
  
  [self.view addSubview:_line];
  [self.view addSubview:_titleLabel];
  [self.view addSubview:_statusLabel];
  [self.view addSubview:_endGameButton];
  [self.view addSubview:_startSearchButton];
  [self.view addSubview:_questionLabel];
}

- (void)endGame
{
  [[ECClient sharedClient] removeHandler:_gameStartedHandler];
  [[ECClient sharedClient] removeHandler:_gameEndedHandler];
  [[ECClient sharedClient] removeInlineHandler:_shutdownHandler];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)startSearch
{
  [[ECClient sharedClient] dispatchEventWithType:@"request_new_game" andPayload:@""];
}

- (void)randomQuestion
{
  int i = arc4random_uniform([_demoQuestions count]-1);
  _questionLabel.text = _demoQuestions[i];
}

#pragma mark - OGGameEventHandlerDelgate

- (void)didCancelGame {}

@end
