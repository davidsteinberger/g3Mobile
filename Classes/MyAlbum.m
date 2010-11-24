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
@synthesize members = _members;

-(id)init {
	[self initWithUrl:nil];
	return self;
}

-(id)initWithID:(NSString* )albumId {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString* url = [appDelegate.baseURL stringByAppendingString:@"/rest/item/"];
	url = [url stringByAppendingString:(NSString *) albumId];
	[self initWithUrl:url];
	return self;
}

-(id)initWithUrl:(NSString* )url {
	self.array = [[NSMutableDictionary alloc] init];
	self.members = [[NSMutableArray alloc] init];
	
	[self getAlbum:url:YES];
	return self;
}

-(void) dealloc {
	[self.array release];
	[self.members release];
	[self.root release];
}

-(void)reload {
	
}

+ (BOOL)isAlbum:(NSString *)url {
	
}

-(void)getAlbum:(NSString* )url:(BOOL)recursive {
	NSString* g3Url = url;
	//NSLog(@"url: %@", url);
	if (url == nil) {
		g3Url = @"http://localhost/~David/gallery3/rest/item/1";
	}
	TTURLRequest* request = [TTURLRequest
                             requestWithURL: g3Url
                             delegate: self];
	
//    request.cachePolicy = cachePolicy | TTURLRequestCachePolicyEtag;
//    request.cacheExpirationAge = TT_CACHE_EXPIRATION_AGE_NEVER;
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.challenge != nil) {
		[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	}
    request.response = [[[TTURLJSONResponse alloc] init] autorelease];

    [request sendSynchronously];
}
/*
- (void)requestDidFinishLoad:(TTURLRequest*)request {
	TTURLJSONResponse* response = request.response;
	TTDASSERT([response.rootObject isKindOfClass:[NSDictionary class]]);
	
	NSDictionary* feed = response.rootObject;
	//TTDASSERT([[feed objectForKey:@"data"] isKindOfClass:[NSArray class]]);
	
	NSMutableArray* entity = [[feed objectForKey:@"entity"] retain];
	NSMutableArray* members = [[feed objectForKey:@"members"] retain];
	
	NSMutableDictionary* element = [[NSMutableDictionary alloc] init];

	//NSLog(@"self.array: %@",self.array);
	//self.members = tmp;
	
	if (!self->_parentLoaded) {
		self->_parentLoaded = YES;
		for (NSString *member in members) {
			[self getAlbum:member:NO];
		}
	} else {
		[element setObject:entity forKey:@"entity"];
		[self.array setObject:element forKey:request.urlPath];
	}

}
*/

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	TTURLJSONResponse* response = request.response;	
	NSDictionary* feed = response.rootObject;
	
	if (!self->_parentLoaded) {
		self->_parentLoaded = YES;
		self.albumEntity = [feed objectForKey:@"entity"];
		
		NSMutableArray* members = [[feed objectForKey:@"members"] retain];		
		
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		NSString* itemsURL = nil;
		itemsURL = [appDelegate.baseURL stringByAppendingString:@"/rest/items?urls=["];
		for (NSString *member in members) {
			NSString* tmp = [[@"\"" stringByAppendingString:member] stringByAppendingString:@"\","];
			itemsURL = [itemsURL stringByAppendingString:tmp];
		}
		itemsURL = [itemsURL substringToIndex:[itemsURL length] - 1];
		itemsURL = [itemsURL stringByAppendingString:@"]"];
		itemsURL = [itemsURL stringByAddingPercentEscapesUsingEncoding:
					NSASCIIStringEncoding];
		//NSLog(@"itemsURL: %@", itemsURL);
		
		[self getAlbum:itemsURL:NO];
	} else {
		for (NSDictionary* member in feed) {
			//NSLog(@"member: %@", member);
			NSMutableArray* entity = [[member objectForKey:@"entity"] retain];
			NSDictionary* url = [[member objectForKey:@"url"] retain];
			NSMutableDictionary* element = [[NSMutableDictionary alloc] init];
			[element setObject:entity forKey:@"entity"];
			[self.array setObject:element forKey:url];
			//NSLog(@"self.array: %@", self.array);
		}
	}
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
	//NSLog(@"error: %@", error);
}

@end
