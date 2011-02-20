//
//  MyThumbsViewModel2.m
//  g3Mobile
//
//  Created by David Steinberger on 2/5/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyThumbsViewModel2.h"
#import "MyRestTest.h"

@implementation MyThumbsViewModel2

@synthesize itemID = _itemID;
@synthesize restResource = _restResource;
@synthesize title = _title;
@synthesize description = _description;
@synthesize autor = _autor;
@synthesize timestamp = _timestamp;
@synthesize tags = _tags;

- (id)initWithItemID:(NSString*) itemID {
	self.itemID = itemID;
	return self;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_itemID);
	TT_RELEASE_SAFELY(_restResource);
	TT_RELEASE_SAFELY(_title);
	TT_RELEASE_SAFELY(_description);
	TT_RELEASE_SAFELY(_autor);
	TT_RELEASE_SAFELY(_timestamp);
	TT_RELEASE_SAFELY(_tags);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModel


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
	return _isLoaded;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
	return _isLoading; //!!_loadingRequest;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoadingMore {
	return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
	_isLoading = YES; //NO
	_isLoaded = NO; //YES
	MyRestTest* restHandler = [[MyRestTest alloc] init];
	NSArray* restResource = [restHandler getTree:self.itemID];
	
	self.restResource = restResource;
	
	_isLoading = NO;
	_isLoaded = YES;
	
	TT_RELEASE_SAFELY(restHandler);
	[self didFinishLoad];
}

- (void)modelDidStartLoad:(id<TTModel>)model {

}

- (void)modelDidFinishLoad:(id<TTModel>)model {
	
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
	
}

- (void)modelDidCancelLoad:(id<TTModel>)model {
	
}

/**
 * Informs the delegate that the model has changed in some fundamental way.
 *
 * The change is not described specifically, so the delegate must assume that the entire
 * contents of the model may have changed, and react almost as if it was given a new model.
 */
- (void)modelDidChange:(id<TTModel>)model {
	
}

- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	
}

- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	
}

- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	
}

/**
 * Informs the delegate that the model is about to begin a multi-stage update.
 *
 * Models should use this method to condense multiple updates into a single visible update.
 * This avoids having the view update multiple times for each change.  Instead, the user will
 * only see the end result of all of your changes when you call modelDidEndUpdates.
 */
- (void)modelDidBeginUpdates:(id<TTModel>)model {
	
}

/**
 * Informs the delegate that the model has completed a multi-stage update.
 *
 * The exact nature of the change is not specified, so the receiver should investigate the
 * new state of the model by examining its properties.
 */
- (void)modelDidEndUpdates:(id<TTModel>)model {
	
}

#pragma mark -
#pragma mark private

- (NSString*)title {
	return [((NSDictionary*)[self.restResource objectAtIndex:0]) valueForKeyPath:@"entity.title"];
}

- (NSString*)description {
	NSString* description = [((NSDictionary*)[self.restResource objectAtIndex:0]) valueForKeyPath:@"entity.description"];
	if ([(NSNull*)description isEqual:[NSNull null]]) {
		description = @"";
	}
	return description;
}

- (NSString*)autor {
	return @"David"; //[((NSDictionary*)[self.restResource objectAtIndex:0]) valueForKeyPath:@"entity.owner_id"];
}

- (NSString*)timestamp {
	return [((NSDictionary*)[self.restResource objectAtIndex:0]) valueForKeyPath:@"entity.created"];
}

- (NSString*)tags {
	return @"";
}

@end
