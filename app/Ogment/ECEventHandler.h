//
//  ECEventHandler.h
//  Ogment
//
//  Created by Joël Gähwiler on 15.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ECEvent;

typedef void (^ECEventHandlerBlock)(ECEvent* event);

@interface ECEventHandler : NSObject

@property (strong,nonatomic) NSString* eventType;
@property (strong,nonatomic) ECEventHandlerBlock handlerBlock;

- (id)initWithEventHandlerBlock:(ECEventHandlerBlock)block andEventType:(NSString*)type;
- (BOOL)canHandleEvent:(ECEvent*)event;
- (void)handleEvent:(ECEvent*)event;

@end
