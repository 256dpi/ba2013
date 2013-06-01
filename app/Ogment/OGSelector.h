//
//  OGSelector.h
//  Ogment
//
//  Created by Joël Gähwiler on 01.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OGSelector : UIView

@property (nonatomic) BOOL selected;
@property (nonatomic, strong) NSString* id;

- (void)setID:(NSString*)id andTitle:(NSString*)title andDescription:(NSString*)description;

@end
