//
//  OGAppDelegate.m
//  Ogment
//
//  Created by Joël Gähwiler on 14.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "OGAppDelegate.h"
#import "OGGeneral.h"
#import "OGTheme.h"
#import "OGConnectingViewController.h"
#import "OGRequestInterceptor.h"
#import "OGAlertView.h"
#import "OGStartViewController.h"

@implementation OGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [UIApplication sharedApplication].idleTimerDisabled = YES;
  
  OGRequestInterceptor *cache = [[OGRequestInterceptor alloc] initWithSubstitutes:@{
    @"http://ogmentapp.com/page.css": @"page.css",
    @"http://ogmentapp.com/override.css": @"override.css",
    @"http://ogmentapp.com/censored.css": @"censored.css",
    @"http://ogmentapp.com/jquery.js": @"jquery.js",
    @"http://ogmentapp.com/editable.js": @"editable.js",
    @"http://ogmentapp.com/censored.js": @"censored.js",
    @"http://ogmentapp.com/black.png": @"black.png",
    @"http://ogmentapp.com/blokk.otf": @"blokk.otf"
  }];
	[NSURLCache setSharedURLCache:cache];
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  
  self.connectingViewController = [[OGConnectingViewController alloc] initWithNibName:@"OGConnectingView" bundle:nil];
  self.connectingViewController.delegate = self;
  
  self.navigationController = [[UINavigationController alloc]initWithRootViewController:self.connectingViewController];
  [self.navigationController setNavigationBarHidden:YES];
  self.window.rootViewController = self.navigationController;
  
  ECClient* client = [ECClient sharedClient];
  client.delegate = self;
  [client connectToServerWithAddress:[[NSUserDefaults standardUserDefaults] stringForKey:@"server_address"]];
  
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)reconnect
{
  [self.connectingViewController presentReconnectingState];
  [[ECClient sharedClient] reconnect];
}

#pragma mark - ECClientDelegate

- (void)clientDidConnectToServer:(ECClient *)client
{
  [client registerHandlerBlock:^(ECEvent *event) {
    OGStartViewController* startViewController = [[OGStartViewController alloc] init];
    [self.navigationController pushViewController:startViewController animated:NO];
  } forEvent: @"client_identified"];
  
  [client dispatchEventWithType:@"client_identification" andPayload:@{ @"device_id": [[NSUserDefaults standardUserDefaults] stringForKey:@"device_id"] }];
}

- (void)clientDidLooseConnectionToServer:(ECClient *)client withError:(NSString *)error
{
  exit(0);
  
//  [[ECClient sharedClient] dispatchInlineEventWithType:@"shutdown" andPayload:nil];
//  
//  [self.navigationController popToRootViewControllerAnimated:NO];
//  
//  OGAlertView* alert = [[OGAlertView alloc] initWithTitle:@"CONNECTION ERROR" message:error cancelButtonTitle:@"OK"];
//  [alert show];
//  
//  [[ECClient sharedClient] removeAllHandlers];
//  [[ECClient sharedClient] removeAllInlineHandlers];
//  [self.connectingViewController presentConnectionFailedState];
}

@end
