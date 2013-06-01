//
//  OGCommunicationCenter.m
//  Ogment
//
//  Created by Joël Gähwiler on 15.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import "ECClient.h"

@implementation ECClient

+ (ECClient *)sharedClient
{
  static dispatch_once_t p = 0;
  __strong static ECClient* _sharedObject = nil;
  dispatch_once(&p, ^{
    _sharedObject = [[self alloc] init];
  });
  return _sharedObject;
}

- (id)init
{
  self = [super init];
  if (self) {
    self.handlerRegistry = [[NSMutableArray alloc] init];
    self.inlineHandlerRegistry = [[NSMutableArray alloc] init];
    self.debugMode = NO;
  }
  return self;
}

- (void)connectToServerWithURL:(NSURL *)serverURL
{
  self.serverAddress = serverURL;
  [self _connect];
}

- (void)connectToServerWithAddress:(NSString *)serverAddress
{
  NSURL* serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:8080",serverAddress]];
  [self connectToServerWithURL:serverURL];
}

- (void)reconnect
{
  [self _connect];
}

- (void)registerHandler:(ECEventHandler *)handler
{
  @synchronized(self.handlerRegistry) {
    [self.handlerRegistry addObject:handler];
  }
  [self _log];
}

- (ECEventHandler*)registerHandlerBlock:(ECEventHandlerBlock)handlerBlock forEvent:(NSString *)eventType
{
  ECEventHandler* handler = [[ECEventHandler alloc] initWithEventHandlerBlock:handlerBlock andEventType:eventType];
  [self registerHandler:handler];
  return handler;
}

- (void)removeHandler:(ECEventHandler *)handler
{
  @synchronized(self.handlerRegistry) {
    [self.handlerRegistry removeObject:handler];
  }
  [self _log];
}

- (void)dispatchEvent:(ECEvent *)event
{
  [self.webSocket send:[event serialize]];
}

- (void)dispatchEventWithType:(NSString *)type andPayload:(id)payload
{
  ECEvent* event = [[ECEvent alloc] initWithEventType:type andPayload:payload];
  [self dispatchEvent:event];
}

- (void)removeAllHandlers
{
  @synchronized(self.handlerRegistry) {
    [self.handlerRegistry removeAllObjects];
  }
}

- (void)registerInlineHandler:(ECEventHandler *)handler
{
  @synchronized(self.inlineHandlerRegistry) {
    [self.inlineHandlerRegistry addObject:handler];
  }
  [self _log];
}

- (ECEventHandler*)registerInlineHandlerBlock:(ECEventHandlerBlock)handlerBlock forEvent:(NSString *)eventType
{
  ECEventHandler* handler = [[ECEventHandler alloc] initWithEventHandlerBlock:handlerBlock andEventType:eventType];
  [self registerInlineHandler:handler];
  return handler;
}

- (void)removeInlineHandler:(ECEventHandler *)handler
{
  @synchronized(self.inlineHandlerRegistry) {
    [self.inlineHandlerRegistry removeObject:handler];
  }
  [self _log];
}

- (void)dispatchInlineEvent:(ECEvent *)event
{
  @synchronized(self.inlineHandlerRegistry) {
    int i=0;
    for(ECEventHandler* eventHandler in self.inlineHandlerRegistry) {
      if([eventHandler canHandleEvent:event]) {
        [eventHandler handleEvent:event];
        i++;
      }
    }
    if(i == 0 && self.debugMode) {
      NSLog(@"ECClient: missing inline handler for event with type: %@",event.type);
    }
  }
}

- (void)dispatchInlineEventWithType:(NSString *)type andPayload:(id)payload
{
  ECEvent* event = [[ECEvent alloc] initWithEventType:type andPayload:payload];
  [self dispatchInlineEvent:event];
}

- (void)removeAllInlineHandlers
{
  @synchronized(self.inlineHandlerRegistry) {
    [self.inlineHandlerRegistry removeAllObjects];
  }
}

#pragma mark - Private Functions

- (void)_connect
{
  self.webSocket = [[SRWebSocket alloc] initWithURL:self.serverAddress];
  self.webSocket.delegate = self;
  [self.webSocket open];
}

- (void)_log
{
  if(self.debugMode) {
    NSLog(@"ECClient: Handler registry size: %d %d", self.handlerRegistry.count, self.inlineHandlerRegistry.count);
  }
}

#pragma mark - SRWebsocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
  if([self.delegate respondsToSelector:@selector(clientDidConnectToServer:)]) {
    [self.delegate clientDidConnectToServer:self];
  }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString*)message
{
  @synchronized(self.handlerRegistry) {
    NSDictionary* data = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    ECEvent* event = [[ECEvent alloc] initWithDictionary:data];
    int i=0;
    NSMutableArray* copy = [self.handlerRegistry copy];
    for(ECEventHandler* eventHandler in copy) {
      if([eventHandler canHandleEvent:event]) {
        [eventHandler handleEvent:event];
        i++;
      }
    }
    if(i == 0 && self.debugMode) {
      NSLog(@"ECClient: missing handler for event with type: %@",event.type);
    }
  }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
  if([self.delegate respondsToSelector:@selector(clientDidLooseConnectionToServer:withError:)]) {
    [self.delegate clientDidLooseConnectionToServer:self withError:[error localizedDescription]];
  }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
  if([self.delegate respondsToSelector:@selector(clientDidLooseConnectionToServer:withError:)]) {
    [self.delegate clientDidLooseConnectionToServer:self withError:reason];
  }
}

@end
