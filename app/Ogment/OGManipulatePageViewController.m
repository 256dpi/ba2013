//
//  OGManipulatePageViewController.m
//  Ogment
//
//  Created by Joël Gähwiler on 02.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "ECClient.h"

#import "OGManipulatePageViewController.h"
#import "OGLine.h"
#import "OGTheme.h"
#import "OGDoubleCountdown.h"
#import "OGGeneral.h"
#import "OGAlertView.h"

@implementation OGManipulatePageViewController {
  UIWebView* _webView;
  OGDoubleCountdown* _countdown;
  OGLine* _line;
  UILabel* _descriptionLabel;
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
  
  _line = [OGLine lineWithArray:@[@0,@650, @1024,@650] andFrame:CGRectMake(0, 0, 1024, 768)];
  
  _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 649)];
  _webView.delegate = self;
  _webView.keyboardDisplayRequiresUserAction = NO;
  
  _countdown = [[OGDoubleCountdown alloc] initWithFrame:CGRectMake(472, 610, 80, 80)];
  
  _descriptionLabel = [OGTheme labelWithAlignment:OGAlignmentTopCenter andSize:CGSizeMake(600, 50) andPoint:CGPointMake(512, 700)];
  _descriptionLabel.textAlignment = NSTextAlignmentCenter;
  _descriptionLabel.text = @"Manipuliere den Artikel";
  
  [self.view addSubview:_line];
  [self.view addSubview:_webView];
  [self.view addSubview:_descriptionLabel];
  
  if(self.useTimer) {
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

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  NSString *html = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"http://ogmentapp.com/page.css\"><link rel=\"stylesheet\" type=\"text/css\" href=\"http://ogmentapp.com/override.css\"><script type=\"text/javascript\"src=\"http://ogmentapp.com/jquery.js\"></script><script type=\"text/javascript\" src=\"http://ogmentapp.com/editable.js\"></script></head><body>%@</body></html>", self.content];
  [_webView loadHTMLString:html baseURL:[NSURL URLWithString:self.url]];
}

- (void)onTick:(NSTimer *)timer
{
  _seconds += OG_TIMER_RESOLUTION;
  [_countdown setInnerProgress:_seconds/OG_PAGE_MANIPULATION_TIME];
  if(_seconds > OG_PAGE_MANIPULATION_TIME) {
    [_timer invalidate];
    [self _sendManipulatedPage];
  }
}

- (void)didEnd
{
  [self _sendManipulatedPage];
}

- (void)_sendManipulatedPage
{
  [self close];
  [[ECClient sharedClient] dispatchEventWithType:@"page_manipulated" andPayload:@{ @"page":[_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"], @"url":self.url}];
  [self.navigationController popViewControllerAnimated:NO];
}

- (void)close
{
  [[ECClient sharedClient] removeInlineHandler:_gameTimeProgressHandler];
  [[ECClient sharedClient] removeInlineHandler:_gameTimeEndHandler];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  switch(navigationType) {
    case UIWebViewNavigationTypeLinkClicked:
    case UIWebViewNavigationTypeFormSubmitted:
    case UIWebViewNavigationTypeBackForward:
    case UIWebViewNavigationTypeFormResubmitted:
    case UIWebViewNavigationTypeReload:
      return NO;
    default:
      return YES;
  }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  exit(0);
//  [self.navigationController popViewControllerAnimated:NO];
//  OGAlertView* alert = [[OGAlertView alloc] initWithTitle:@"CONNECTION ERROR" message:[error localizedDescription] cancelButtonTitle:@"OK"];
//  [alert show];
}

@end
