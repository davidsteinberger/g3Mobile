//
//  MyAlbum.m
//  TTCatalog
//
//  Created by David Steinberger on 11/11/10.
//  Copyright 2010 -. All rights reserved.
//

#import "MyAlbum.h"
#import "AppDelegate.h"
#import "extThree20JSON/extThree20JSON.h"

#import "Three20Network/TTURLRequest.h"

@implementation MyAlbum

@synthesize root = _root;
@synthesize array = _array;
@synthesize albumEntity = _albumEntity;

-(id)init {
	[self initWithUrl:nil];
	return self;
}

-(id)initWithID:(NSString* )albumId {
	//NSLog(@"albumId: %@", albumId);
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString* url = [appDelegate.baseURL stringByAppendingString:@"/rest/item/"];
	url = [url stringByAppendingString:(NSString *) albumId];
	return [self initWithUrl:url];
}

-(id)initWithUrl:(NSString* )url {
	[self getAlbum:url];
	return self;
}

-(void) dealloc {
	TT_RELEASE_SAFELY(_array);	
	TT_RELEASE_SAFELY(_albumEntity);
	
	[super dealloc];
}

-(void)getAlbum:(NSString* )url {
	NSString* g3Url = url;

	//NSLog(@"url: %@", url);
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

	if (url == nil) {
		g3Url = [appDelegate.baseURL stringByAppendingString: @"/rest/item/1"];
	}
	
	TTURLRequest* request = [TTURLRequest
                             requestWithURL: g3Url
                             delegate: self];
	
    //request.cachePolicy = TTURLRequestCachePolicyEtag;
	// cache for 1 week
    request.cacheExpirationAge = TT_DEFAULT_CACHE_EXPIRATION_AGE;
	
	if (appDelegate.challenge != nil) {
		[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	}
	
	TTURLJSONResponse* response = [[TTURLJSONResponse alloc] init];
    request.response = response;
	TT_RELEASE_SAFELY(response);
	[request sendSynchronously];
	
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	TTURLJSONResponse* response = request.response;
	NSDictionary* feed = response.rootObject;
	
	if (!self->_parentLoaded) {
		self->_parentLoaded = YES;
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

		NSDictionary* tmpEntity = [feed objectForKey:@"entity"];
		
		TT_RELEASE_SAFELY(_albumEntity);
		_albumEntity = [[NSDictionary alloc] initWithDictionary:tmpEntity];;
		
		NSMutableArray* tmpMembers = [feed objectForKey:@"members"];
		
		NSString* itemsURL = [[[NSString alloc] initWithString:[appDelegate.baseURL stringByAppendingString:@"/rest/items?urls=["]] autorelease];

		for (NSString *member in tmpMembers) {
			NSString* tmp = [[@"\"" stringByAppendingString:member] stringByAppendingString:@"\","];
			itemsURL = [itemsURL stringByAppendingString:tmp];
		}

		itemsURL = [itemsURL substringToIndex:[itemsURL length] - 1];
		itemsURL = [itemsURL stringByAppendingString:@"]"];
		itemsURL = [itemsURL stringByAddingPercentEscapesUsingEncoding:
					NSASCIIStringEncoding];
		//NSLog(@"itemsURL: %@", itemsURL);
				
		[self getAlbum:itemsURL];
	} else {
		NSMutableDictionary* elements = [[NSMutableDictionary alloc] initWithCapacity:[feed count]];
		for (NSDictionary* member in feed) {
			//NSLog(@"member: %@", member);
			NSDictionary* entity = [member objectForKey:@"entity"];
			NSDictionary* url = [member objectForKey:@"url"];

			NSMutableDictionary* element = [NSMutableDictionary dictionaryWithObject:entity forKey:@"entity"];
			[elements setObject:element forKey:url];
		}
		TT_RELEASE_SAFELY(_array);
		_array = elements;
	}
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
	//NSLog(@"error: %@", error);
}

@end
