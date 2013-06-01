//
//  OGRequestInterceptor.h
//  Ogment
//
//  Created by Joël Gähwiler on 17.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OGRequestInterceptor : NSURLCache

- (id)initWithSubstitutes:(NSDictionary*)substitutes;

@end
