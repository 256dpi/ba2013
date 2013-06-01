//
//  ECEventHandler.m
//  Ogment
//
//  Created by Joël Gähwiler on 15.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "ECEventHandler.h"
#import "ECEvent.h"

@implementation ECEventHandler

- (id)initWithEventHandlerBlock:(ECEventHandlerBlock)block andEventType:(NSString *)type
{
  if(self = [self init]){
    self.eventType = [type copy];
    self.handlerBlock = block;
  }
  return self;
}

- (BOOL)canHandleEvent:(ECEvent *)event
{
  return [event.type isEqualToString:self.eventType];
}

- (void)handleEvent:(ECEvent *)event
{
  self.handlerBlock(event);
}

@end
