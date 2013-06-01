//
//  ECEvent.m
//  Ogment
//
//  Created by Joël Gähwiler on 15.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "ECEvent.h"

@implementation ECEvent

- (id)init
{
  if(self = [super init]) {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    self.uid = CFBridgingRelease(CFUUIDCreateString(NULL, theUUID));
    CFRelease(theUUID);
  }
  return self;
}

- (id)initWithEventType:(NSString *)type andPayload:(id)payload
{
  if(self = [self init]){
    self.type = type;
    self.payload = payload;
  }
  return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
  if(self = [self init]){
    self.uid = dictionary[@"uid"];
    self.type = dictionary[@"type"];
    self.payload = dictionary[@"payload"];
  }
  return self;
}

- (NSData*)serialize
{
  NSDictionary* data = @{ @"uid": self.uid, @"type": self.type, @"payload": self.payload };
  return [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
}

@end
