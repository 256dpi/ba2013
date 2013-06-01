//
//  OGCreateFakeResultViewController.m
//  Ogment
//
//  Created by Joël Gähwiler on 02.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <SSToolkit/SSTextField.h>

#import "ECClient.h"

#import "OGCreateFakeResultViewController.h"
#import "OGDoubleCountdown.h"
#import "OGTheme.h"
#import "OGLine.h"
#import "OGGeneral.h"

@implementation OGCreateFakeResultViewController {
  UILabel* _titleLabel;
  UILabel* _descriptionLabel;
  SSTextField* _inputField;
  OGDoubleCountdown* _countdown;
  OGLine* _line;
  UIButton* _endButton;
  
  NSTimer* _timer;
  double _seconds;
  
  ECEventHandler* _gameTimeProgressHandler;
  ECEventHandler* _gameTimeEndHandler;
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
  _titleLabel.text = @"PHISHING";
  _titleLabel.font = [OGTheme titleFont];
  
  _descriptionLabel = [OGTheme labelWithAlignment:OGAlignmentTopCenter andSize:CGSizeMake(600, 50) andPoint:CGPointMake(512, 180)];
  _descriptionLabel.textAlignment = NSTextAlignmentCenter;
  _descriptionLabel.text = @"Erstelle ein falsches Suchresultat als Köder.";
  
  _inputField = [OGTheme textFieldWithAlignment:OGAlignmentCenterCenter andSIze:CGSizeMake(500, 60) andPoint:CGPointMake(512, 295)];
  _inputField.placeholder = @"FALSCHES SUCHRESULTAT";
  _inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
  _inputField.delegate = self;
  _inputField.autocorrectionType = UITextAutocorrectionTypeNo;
  
  [self.view addSubview:_line];
  [self.view addSubview:_titleLabel];
  [self.view addSubview:_inputField];
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
}

- (void)onTick:(NSTimer *)timer
{
  _seconds += OG_TIMER_RESOLUTION;
  [_countdown setInnerProgress:_seconds/OG_FAKE_RESULT_TIME];
  if(_seconds > OG_FAKE_RESULT_TIME) {
    [_timer invalidate];
    [self _sendFakeResult];
  }
}

- (void)didEnd
{
  [self _sendFakeResult];
}

- (void)_sendFakeResult
{
  NSString* fr = _inputField.text ? _inputField.text : @"";
  [[ECClient sharedClient] dispatchEventWithType:@"fake_result_created" andPayload:fr];
  [self close];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)close
{
  [[ECClient sharedClient] removeInlineHandler:_gameTimeProgressHandler];
  [[ECClient sharedClient] removeInlineHandler:_gameTimeEndHandler];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
  [aTextField resignFirstResponder];
  [self didEnd];
  return YES;
}

@end
