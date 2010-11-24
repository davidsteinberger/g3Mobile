//
//  MyItemDeleter.m
//  Gallery3
//
//  Created by David Steinberger on 11/23/10.
//  Copyright 2010 -. All rights reserved.
//

#import "AppDelegate.h"

#import "MyItemDeleter.h"


@implementation MyItemDeleter

+ (id) initWithItemID:(NSString *)itemID {

	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	//---bring everything together
	
	//create http-request
	NSString* url = [appDelegate.baseURL stringByAppendingString:@"/rest/item/"];
	url = [url stringByAppendingString:itemID];
	TTURLRequest *request = [TTURLRequest
									requestWithURL: url
									delegate: self];
	
	//set http-headers
	[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"delete" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];	
	
	//set 'post'-method
	request.httpMethod = @"POST";
	request.cachePolicy	= TTURLRequestCachePolicyNone;

	[request sendSynchronously];

	return self;
}
@end
