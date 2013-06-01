//
//  OGSelectorViewController.m
//  Ogment
//
//  Created by Joël Gähwiler on 01.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "ECClient.h"

#import "OGGeneral.h"
#import "OGSelectorViewController.h"
#import "OGLine.h"
#import "OGSelector.h"
#import "OGTheme.h"
#import "OGDoubleCountdown.h"

@implementation OGSelectorViewController {
  UILabel* _titleLabel;
  UILabel* _descriptionLabel;
  OGSelector* _leftSelector;
  OGSelector* _centerSelector;
  OGSelector* _rightSelector;
  OGLine* _line;
  OGLine* _line2;
  OGDoubleCountdown* _countdown;
  UIButton* _endButton;
  
  NSTimer* _timer;
  double _seconds;
  
  ECEventHandler* _gameTimeProgressHandler;
  ECEventHandler* _gameTimeEndHandler;
}

- (id)initWithType:(OGSelectorType)type
{
  if(self = [self init]) {
    self.type = type;
    self.useTimer = YES;
  }
  return self;
}

- (void)loadView
{
  self.view = [[UIView alloc] init];
  
  _titleLabel = [OGTheme labelWithAlignment:OGAlignmentBottomCenter andSize:CGSizeMake(600,50) andPoint:CGPointMake(512, 180)];
  _titleLabel.textAlignment = NSTextAlignmentCenter;
  _titleLabel.font = [OGTheme titleFont];
  
  _descriptionLabel = [OGTheme labelWithAlignment:OGAlignmentTopCenter andSize:CGSizeMake(600, 50) andPoint:CGPointMake(512, 180)];
  _descriptionLabel.textAlignment = NSTextAlignmentCenter;
  
  _leftSelector = [[OGSelector alloc] initWithFrame:CGRectMake(102, 250, 260, 260)];
  _centerSelector = [[OGSelector alloc] initWithFrame:CGRectMake(382, 250, 260, 260)];
  _rightSelector = [[OGSelector alloc] initWithFrame:CGRectMake(662, 250, 260, 260)];
  
  _line = [OGLine lineWithArray:@[@0,@650, @512,@650, @512,@449, @512,@650, @1024,@650] andFrame:CGRectMake(0, 0, 1024, 768)];
  _line2 = [OGLine lineWithArray:@[@232,@510, @232,@560, @792,@560, @792,@510] andFrame:CGRectMake(0, 0, 1024, 768)];
  
  [self.view addSubview:_line];
  [self.view addSubview:_line2];
  [self.view addSubview:_leftSelector];
  [self.view addSubview:_centerSelector];
  [self.view addSubview:_rightSelector];
  [self.view addSubview:_titleLabel];
  [self.view addSubview:_descriptionLabel];
  
  if(self.useTimer) {
    _countdown = [[OGDoubleCountdown alloc] initWithFrame:CGRectMake(472, 610, 80, 80)];
    
    _gameTimeProgressHandler = [[ECClient sharedClient] registerInlineHandlerBlock:^(ECEvent *event) {
      [_countdown setOuterProgress:[event.payload floatValue]];
    } forEvent:@"game_time_progress"];
    
    _gameTimeEndHandler = [[ECClient sharedClient] registerInlineHandlerBlock:^(ECEvent *event) {
      if(_timer) {
        [_timer invalidate];
      }
    } forEvent:@"game_time_end"];
    
    _seconds = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:OG_TIMER_RESOLUTION target:self selector:@selector(onTick:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    [self.view addSubview:_countdown];
  } else {
    _endButton = [OGTheme buttonWithAlignment:OGAlignmentCenterCenter andPoint:CGPointMake(512, 650) andTitle:@"AUSWAHL BESTÄTIGEN"];
    [_endButton addTarget:self action:@selector(didEnd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_endButton];
  }
  
  UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
  [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  switch (self.type) {
    case OGSelectorTypeAttack:
      _titleLabel.text = @"ANGRIFF AUSWÄHLEN";
      _descriptionLabel.text = @"Verhindere oder manipuliere die Suche deines Gegenspielers.";
      [_leftSelector setID:@"phishing" andTitle:@"PHISHING" andDescription:@"Erstelle ein Falsches Suchresultat, welches beim Klick zum sofortigen Zugende führt."];
      [_centerSelector setID:@"denial_of_service" andTitle:@"DENIAL OF SERVICE" andDescription:@"Wählen alle Spieler diesen Angriff, wird der Zug des Gegners sofort beendet."];
      [_rightSelector setID:@"man_in_the_middle" andTitle:@"MAN IN THE MIDDLE" andDescription:@"Manipuliere Informationen bevor sie der Gegner zu Gesicht bekommt."];
      break;
    case OGSelectorTypeProtection:
      _titleLabel.text = @"SCHUTZ AUSWÄHLEN";
      _descriptionLabel.text = @"Schütz dich gegen die Manipulationsversuche deiner Gegenspieler.";
      [_leftSelector setID:@"ad_blocker" andTitle:@"AD BLOCKER" andDescription:@"Verstecke platzierte Werbung in den Suchresultaten."];
      [_centerSelector setID:@"vpn_server" andTitle:@"VPN SERVER" andDescription:@"Verhindere das zensurieren von Informationen."];
      [_rightSelector setID:@"private_browsing" andTitle:@"PRIVATES SURFEN" andDescription:@"Verhindere die Kombination von Suchbegriffen durch die personalisierte Suche."];
      break;
    case OGSelectorTypeStrategy:
      _titleLabel.text = @"MANIPULATION AUSWÄHLEN";
      _descriptionLabel.text = @"Erschwere die Suche deines Gegenspielers.";
      [_leftSelector setID:@"advertisement" andTitle:@"WERBUNG" andDescription:@"Platziere Werbung in den Suchresultaten um den Gegner abzulenken."];
      [_centerSelector setID:@"censorship" andTitle:@"ZENSUR" andDescription:@"Lass Teile des Textes auschwärzen um Informationen zu verstecken."];
      [_rightSelector setID:@"personalize_search" andTitle:@"PERSONALISIERTE SUCHE" andDescription:@"Erschwere das Suchen durch Kombination mit dem letzten Begriff."];
      break;
  }
}

- (void)onTap:(UITapGestureRecognizer *)sender
{
  if (sender.state == UIGestureRecognizerStateEnded) {
    CGPoint point = [sender locationInView:self.view];
    if(CGRectContainsPoint(_leftSelector.frame, point)) {
      _leftSelector.selected = YES;
      _centerSelector.selected = NO;
      _rightSelector.selected = NO;
    } else if(CGRectContainsPoint(_centerSelector.frame, point)) {
      _leftSelector.selected = NO;
      _centerSelector.selected = YES;
      _rightSelector.selected = NO;
    } else if(CGRectContainsPoint(_rightSelector.frame, point)) {
      _leftSelector.selected = NO;
      _centerSelector.selected = NO;
      _rightSelector.selected = YES;
    }
  }
}

- (void)onTick:(NSTimer *)timer
{
  _seconds += OG_TIMER_RESOLUTION;
  [_countdown setInnerProgress:_seconds/OG_SELECTION_TIME];
  if(_seconds > OG_SELECTION_TIME) {
    [_timer invalidate];
    [self.delegate didEndSelection:self];
  }
}

- (void)didEnd
{
  [self.delegate didEndSelection:self];
}

- (NSString*)selectedSelector
{
  if(_leftSelector.selected) {
    return _leftSelector.id;
  } else if (_centerSelector.selected) {
    return _centerSelector.id;
  } else if (_rightSelector.selected) {
    return _rightSelector.id;
  }
  return @"none";
}

- (void)close
{
  [[ECClient sharedClient] removeInlineHandler:_gameTimeProgressHandler];
  [[ECClient sharedClient] removeInlineHandler:_gameTimeEndHandler];
}

@end
 