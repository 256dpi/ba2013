//
//  ECEvent.h
//  Ogment
//
//  Created by Joël Gähwiler on 15.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ECClient;

@interface ECEvent : NSObject

@property (strong,nonatomic) NSString* uid;
@property (strong,nonatomic) NSString* type;
@property (strong,nonatomic) id payload;

- (id)initWithEventType:(NSString*)type andPayload:(id)payload;
- (id)initWithDictionary:(NSDictionary*)dictionary;
- (NSData*)serialize;

@end
