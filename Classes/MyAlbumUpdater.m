//
//  MyAlbumUpdater.m
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import "extThree20JSON/NSObject+YAJL.h"

#import "MyAlbumUpdater.h"

#import "AppDelegate.h"

@implementation MyAlbumUpdater

- (id) initWithItemID:(NSString *)itemID {
	_params = [[NSMutableDictionary alloc] init];
	_albumID = [NSString stringWithString: itemID];
	return self;
}

- (void) dealloc {
	TT_RELEASE_SAFELY(_params);
	[super dealloc];
}

- (void) setValue:(NSString* )value param:(NSString* )param {
	//NSLog(@"value: %@, key: %@", value, param);
	[_params setObject:[NSString stringWithString:value] forKey:[NSString stringWithString:param]];
}

- (void) update {
	//NSLog(@"Update Album for albumID: %@", self->_albumID);

	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	//prepare http post parameter: item, text
	NSDictionary *params = [NSDictionary dictionaryWithDictionary: _params];  

	//NSLog(@"value: %@", params);
	
	//json-encode & urlencode parameters
	NSString* requestString = [params yajl_JSONString];
	requestString = [@"entity=" stringByAppendingString:[self urlEncodeValue:requestString]];
	
	//create data for http-request body
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	
	//---bring everything together
	
	//create http-request
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[[appDelegate.baseURL stringByAppendingString:@"/rest/item/"] stringByAppendingString:self->_albumID]]];
	
	//set http-headers
	[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"put" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];	
	
	//set 'post'-method
	[request setHTTPMethod: @"POST"];
	
	//set request body into HTTPBody.
	[request setHTTPBody: requestData];
	
	[NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil ];
	
	[request release];
}

- (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}

@end
