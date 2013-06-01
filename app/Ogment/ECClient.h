//
//  OGCommunicationCenter.h
//  Ogment
//
//  Created by Joël Gähwiler on 15.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>

#import "ECEventHandler.h"
#import "ECEvent.h"

@protocol ECClientDelegate <NSObject>
@optional
- (void)clientDidConnectToServer:(ECClient*)client;
- (void)clientDidLooseConnectionToServer:(ECClient*)client withError:(NSString*)error;
@end

@interface ECClient : NSObject <SRWebSocketDelegate>

@property (weak,nonatomic) id<ECClientDelegate> delegate;
@property (strong,nonatomic) NSURL* serverAddress;
@property (strong,atomic) SRWebSocket* webSocket;
@property (strong,atomic) NSMutableArray* handlerRegistry;
@property (strong,atomic) NSMutableArray* inlineHandlerRegistry;
@property (nonatomic) BOOL debugMode;

+ (ECClient*)sharedClient;

- (void)connectToServerWithURL:(NSURL*)serverURL;
- (void)connectToServerWithAddress:(NSString*)serverAddress;
- (void)reconnect;

- (void)registerHandler:(ECEventHandler*)handler;
- (ECEventHandler*)registerHandlerBlock:(ECEventHandlerBlock)handlerBlock forEvent:(NSString*)eventType;
- (void)removeHandler:(ECEventHandler*)handler;
- (void)dispatchEvent:(ECEvent*)event;
- (void)dispatchEventWithType:(NSString*)type andPayload:(id)payload;
- (void)removeAllHandlers;

- (void)registerInlineHandler:(ECEventHandler *)handler;
- (ECEventHandler*)registerInlineHandlerBlock:(ECEventHandlerBlock)handlerBlock forEvent:(NSString*)eventType;
- (void)removeInlineHandler:(ECEventHandler*)handler;
- (void)dispatchInlineEvent:(ECEvent*)event;
- (void)dispatchInlineEventWithType:(NSString*)type andPayload:(id)payload;
- (void)removeAllInlineHandlers;

@end
