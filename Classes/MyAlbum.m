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

@synthesize albumID = _albumID;
@synthesize array = _array;
@synthesize albumEntity = _albumEntity;

-(id)init {
	[self initWithUrl:nil];
	return self;
}

-(id)initWithID:(NSString* )albumId {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	self.albumID = albumId;
	NSString* url = [appDelegate.baseURL stringByAppendingString:@"/rest/tree/"];
	url = [url stringByAppendingString:(NSString *) albumId];
	url = [url stringByAppendingString:@"?depth=1"];
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
		g3Url = [appDelegate.baseURL stringByAppendingString: @"/rest/tree/1?depth=1"];
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
	NSMutableArray* feed = [response.rootObject objectForKey:@"entity"];

	_albumEntity = [[NSDictionary alloc] initWithDictionary:[[feed objectAtIndex:0] objectForKey:@"entity"]];
	[feed removeObjectAtIndex:0];	
	
	NSMutableDictionary* elements = [[NSMutableDictionary alloc] initWithCapacity:[feed count]];

	for (NSDictionary* member in feed) {			
		//NSLog(@"member: %@", member);
		NSDictionary* entity = [member objectForKey:@"entity"];
		NSDictionary* url = [member objectForKey:@"url"];

		NSMutableDictionary* element = [NSMutableDictionary dictionaryWithObject:entity forKey:@"entity"];
		[elements setObject:element forKey:url];
	}
	_array = elements;
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
	//NSLog(@"error: %@", error);
}

+ (void)updateFinished {
	[MyAlbum updateFinishedWithItemID:nil];
}

+ (void)updateFinishedWithItemID:(NSString*)itemID {
	if (itemID == nil) {		
		[self updateFinishedWithItemURL:nil];
	} else {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		NSString* url = [[appDelegate.baseURL stringByAppendingString:@"/rest/tree/"] stringByAppendingString:itemID];
		[MyAlbum updateFinishedWithItemURL:[url stringByAppendingString:@"?depth=1"]];
	}
}

+ (void)updateFinishedWithItemURL:(NSString*)url {
	
	if (url != nil) {
		NSString* treeURL = [url stringByReplacingOccurrencesOfString:@"/rest/item/" withString:@"/rest/tree/"];		
		[[TTURLCache sharedCache] removeURL:[treeURL stringByAppendingString:@"?depth=1"] fromDisk:YES];
	} else {
		[[TTURLCache sharedCache] removeAll:YES];
	}
}


@end
