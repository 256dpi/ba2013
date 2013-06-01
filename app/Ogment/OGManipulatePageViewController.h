//
//  OGManipulatePageViewController.h
//  Ogment
//
//  Created by Joël Gähwiler on 02.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OGManipulatePageViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic,strong) NSString* content;
@property (nonatomic,strong) NSString* url;
@property (nonatomic) BOOL useTimer;

@end
