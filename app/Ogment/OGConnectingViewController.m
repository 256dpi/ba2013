//
//  OGConnectingViewController.m
//  Ogment
//
//  Created by Joël Gähwiler on 14.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "OGConnectingViewController.h"
#import "OGAppDelegate.h"
#import "OGTheme.h"

@implementation OGConnectingViewController {
  UILabel* _statusLabel;
  UIButton* _reconnectButton;
}

- (void)loadView
{
  self.view = [[UIView alloc] init];
  
  _statusLabel = [OGTheme labelWithAlignment:OGAlignmentBottomCenter andSize:CGSizeMake(400, 50) andPoint:CGPointMake(512, 384)];
  _statusLabel.text = @"Verbinde mit Server...";
  _statusLabel.textAlignment = NSTextAlignmentCenter;
  
  _reconnectButton = [OGTheme buttonWithAlignment:OGAlignmentTopCenter andPoint:CGPointMake(512, 384) andTitle:@"WIEDERHOLEN"];
  [_reconnectButton addTarget:self action:@selector(reconnect) forControlEvents:UIControlEventTouchUpInside];
  _reconnectButton.hidden = YES;
  
  [self.view addSubview:_statusLabel];
  [self.view addSubview:_reconnectButton];
}

- (void)presentConnectionFailedState
{
  _statusLabel.text = @"Verbindung fehlgeschlagen";
  _reconnectButton.hidden = NO;
}

- (void)presentReconnectingState
{
  _statusLabel.text = @"Neu verbinden...";
  _reconnectButton.hidden = YES;
}

- (void)reconnect
{
  [self.delegate reconnect];
}

@end
