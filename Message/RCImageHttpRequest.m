//
//  RCImageHttpRequest.m
//  rsscoffee
//
//  Created by xuzepei on 5/9/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "RCImageHttpRequest.h"
#import "RCTool.h"


@implementation RCImageHttpRequest

+ (RCImageHttpRequest*)sharedInstance
{
	static RCImageHttpRequest* sharedInstance = nil;
	if(nil == sharedInstance)
	{
		@synchronized([RCImageHttpRequest class])
		{
			sharedInstance = [[RCImageHttpRequest alloc] init];
		}
	}
	
	return sharedInstance;
}

- (id)init
{
	if(self = [super init])
	{
		
	}
	
	return self;
}

- (void)dealloc
{
}

- (void)saveImage: (NSString*)url delegate: (id)delegate token:(id)token
{
	_saveToLocal = YES;
	self.delegate = delegate;
	self.token = token;
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString* urlString = url;
	self.requestingURL = urlString;
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[request setURL:[NSURL URLWithString: urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval: TIME_OUT];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"GET"];
	
	NSLog(@"saveImage: %@",urlString);
	
	if ([[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES])
	{
		self.isConnecting = YES;
		[self.receivedData setLength:0];
		
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.requestingURL, @"url",
							  self.token,@"token",nil];
		if([self.delegate respondsToSelector: @selector(willStartHttpRequest:)])
			[self.delegate willStartHttpRequest:dict];
	}
}

- (void)downloadImage: (NSString*)url delegate:(id)delegate token:(id)token
{
	_saveToLocal = NO;
	self.delegate = delegate;
	self.token = token;
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	NSString* urlString = url;
	self.requestingURL = urlString;
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[request setURL:[NSURL URLWithString: urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval: TIME_OUT];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"GET"];
	
	//NSLog(@"downloadImage: %@",urlString);
	
	if ([[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES])
	{
		self.isConnecting = YES;
		[self.receivedData setLength:0];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.requestingURL, @"url",
							  self.token,@"token",nil];
		if([self.delegate respondsToSelector: @selector(willStartHttpRequest:)])
			[self.delegate willStartHttpRequest:dict];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	//NSLog(@"downloadImage:connectionDidFinishLoading- statusCode:%d",_statusCode);
	
	if(200 == self.statusCode)
	{
		UIImage* image = [UIImage imageWithData: self.receivedData];
		
		if(image)
		{
			if(_saveToLocal)
			{
				[RCTool saveImage:self.receivedData path:self.requestingURL];
			}
			
			NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
								  self.requestingURL, @"url",
								  [NSNumber numberWithBool:_saveToLocal],@"isSaved",
								  self.token,@"token",nil];
			if([self.delegate respondsToSelector: @selector(didFinishHttpRequest:token:)])
				[self.delegate didFinishHttpRequest: image token: dict];
		}
	}
	else
	{
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.requestingURL, @"url",
							  self.token,@"token",nil];
		if([self.delegate respondsToSelector: @selector(didFailHttpRequest:)])
			[self.delegate didFailHttpRequest:dict];
	}
	
	self.isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	//NSLog(@"downloadImage:didFailWithError- statusCode:%d",_statusCode);
	
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  self.requestingURL, @"url",
						  self.token,@"token",nil];
	if([self.delegate respondsToSelector: @selector(didFailHttpRequest:)])
		[self.delegate didFailHttpRequest:dict];
	
	self.isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.receivedData setLength:0];
}

@end
