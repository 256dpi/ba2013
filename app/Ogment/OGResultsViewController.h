//
//  OGResultsViewController.h
//  Ogment
//
//  Created by Joël Gähwiler on 02.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OGResultsViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray* results;
@property (nonatomic) BOOL useTimer;

@end
