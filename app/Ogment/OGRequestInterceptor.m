//
//  OGRequestInterceptor.m
//  Ogment
//
//  Created by Joël Gähwiler on 17.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "OGRequestInterceptor.h"

@implementation OGRequestInterceptor {
  NSMutableDictionary* _cachedResponses;
  NSDictionary* _substitutes;
}

- (id)init
{
  if(self = [super init]){
    _cachedResponses = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (id)initWithSubstitutes:(NSDictionary *)substitutes
{
  if(self = [self init]) {
    _substitutes = [substitutes copy];
  }
  return self;
}

- (NSString *)mimeTypeForPath:(NSString *)originalPath
{
  CFStringRef ext = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[originalPath pathExtension], NULL);
  CFStringRef mime = UTTypeCopyPreferredTagWithClass(ext, kUTTagClassMIMEType);
  CFRelease(ext);
  return (__bridge NSString *)mime;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
  NSString *pathString = [[request URL] absoluteString];
  
  NSString *substitutionFileName = [_substitutes objectForKey:pathString];
  if (!substitutionFileName) {
    return [super cachedResponseForRequest:request];
  }
  
  NSCachedURLResponse *cachedResponse = [_cachedResponses objectForKey:pathString];
  if (cachedResponse) {
    return cachedResponse;
  }
  
  NSString *substitutionFilePath = [[NSBundle mainBundle] pathForResource:[substitutionFileName stringByDeletingPathExtension] ofType:[substitutionFileName pathExtension]];
  NSAssert(substitutionFilePath, @"File %@ in substitutionPaths didn't exist", substitutionFileName);
  
  NSData *data = [NSData dataWithContentsOfFile:substitutionFilePath];
  
  NSURLResponse *response =
  [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:[self mimeTypeForPath:pathString] expectedContentLength:[data length] textEncodingName:nil];
  cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
  
  [_cachedResponses setObject:cachedResponse forKey:pathString];
  
  return cachedResponse;
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request
{
	NSString *pathString = [[request URL] path];
	if ([_cachedResponses objectForKey:pathString]) {
		[_cachedResponses removeObjectForKey:pathString];
	} else {
		[super removeCachedResponseForRequest:request];
	}
}

@end
