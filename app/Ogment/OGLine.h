//
//  OGLine.h
//  Ogment
//
//  Created by Joël Gähwiler on 01.05.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OGLine : UIView

@property (nonatomic, strong) NSArray* pointArray;

+ (OGLine*)lineWithArray:(NSArray*)array andFrame:(CGRect)frame;

@end
