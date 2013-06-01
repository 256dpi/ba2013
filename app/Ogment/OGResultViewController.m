//
//  OGResultViewController.m
//  Ogment
//
//  Created by Joël Gähwiler on 02.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "ECClient.h"

#import "OGResultViewController.h"
#import "OGSingleCountdown.h"
#import "OGLine.h"
#import "OGTheme.h"
#import "OGAlertView.h"

@implementation OGResultViewController {
  UIButton* _closeButton;
  UIWebView* _webView;
  OGSingleCountdown* _countdown;
  OGLine* _line;
  
  ECEventHandler* _gameTimeProgressHandler;
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
  
  _closeButton = [OGTheme buttonWithAlignment:OGAlignmentCenterCenter andPoint:CGPointMake(256, 650) andTitle:@"ZURÜCK"];
  [_closeButton addTarget:self action:@selector(showResults) forControlEvents:UIControlEventTouchUpInside];
  
  _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 649)];
  _webView.delegate = self;
  _webView.scalesPageToFit = YES;
  
  [self.view addSubview:_line];
  [self.view addSubview:_webView];
  [self.view addSubview:_closeButton];
  
  if(self.useTimer) {
    _countdown = [[OGSingleCountdown alloc] initWithFrame:CGRectMake(472, 610, 80, 80)];
    
    _gameTimeProgressHandler = [[ECClient sharedClient] registerInlineHandlerBlock:^(ECEvent *event) {
      [_countdown setProgress:[event.payload floatValue]];
    } forEvent:@"game_time_progress"];
    
    [self.view addSubview:_countdown];
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  NSString *html;
  if(self.censored) {
    html = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"http://ogmentapp.com/page.css\"><link rel=\"stylesheet\" type=\"text/css\" href=\"http://ogmentapp.com/override.css\"><link rel=\"stylesheet\" type=\"text/css\" href=\"http://ogmentapp.com/censored.css\"><script type=\"text/javascript\"src=\"http://ogmentapp.com/jquery.js\"></script><script type=\"text/javascript\"src=\"http://ogmentapp.com/censored.js\"></script></head><body>%@</body></html>", self.content];
  } else {
    html = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"http://ogmentapp.com/page.css\"><link rel=\"stylesheet\" type=\"text/css\" href=\"http://ogmentapp.com/override.css\"><script type=\"text/javascript\"src=\"http://ogmentapp.com/jquery.js\"></script></head><body>%@</body></html>", self.content];
  }
  [_webView loadHTMLString:html baseURL:[NSURL URLWithString:self.url]];
}

- (void)close
{
  [[ECClient sharedClient] removeInlineHandler:_gameTimeProgressHandler];
}

- (void)showResults
{
  [self close];
  [[ECClient sharedClient] dispatchInlineEventWithType:@"release_results" andPayload:nil];
  [self.navigationController popViewControllerAnimated:YES];
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
