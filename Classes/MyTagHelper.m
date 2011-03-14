//
//  RKTagHelper.m
//  g3Mobile
//
//  Created by David Steinberger on 3/3/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyTagHelper.h"
#import "RKMItem.h"
#import "MySettings.h"
#import "Three20/Three20.h"

static int cntTags = 0;

@interface MyTagHelper()

- (void)load:(NSString*)resourcePath class:(Class)class;

@end

@implementation MyTagHelper

@synthesize delegate = _delegate;
@synthesize resourcePath = _resourcePath;
@synthesize objects = _objects;

- (void)dealloc {
	TT_RELEASE_SAFELY(_resourcePath);
	TT_RELEASE_SAFELY(_objects);
	[super dealloc];
}

- (id)initWithResourcePath:(NSString*)resourcePath delegate:(id<MyTagHelperDelegate>)delegate {
	self.resourcePath = resourcePath;
	self.delegate = delegate;
	self.objects = [NSMutableArray array];
	cntTags = 0;
	[self load:resourcePath class:[RKMItem class]];
	return self;
}

- (void)load:(NSString*)resourcePath class:(Class)class {
	RKObjectManager *objectManager = [RKObjectManager sharedManager];
	RKManagedObjectStore *store = objectManager.objectStore;
	
	NSArray *cacheFetchRequests = nil;
	NSArray *cachedObjects = nil;
	
	if (store.managedObjectCache) {
		cacheFetchRequests = [store.managedObjectCache fetchRequestsForResourcePath:resourcePath];
		cachedObjects = [RKManagedObject objectsWithFetchRequests:cacheFetchRequests];
		
		if ([cachedObjects count] > 0) {
			id object = [cachedObjects objectAtIndex:0];
			[self objectLoader:nil didLoadObjects:[NSArray arrayWithObjects:object,nil]];
		} else {
			[objectManager loadObjectsAtResourcePath:resourcePath objectClass:class delegate:self];
		}

	} else {
		[objectManager loadObjectsAtResourcePath:resourcePath objectClass:[RKMItem class] delegate:self];
	}	
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {	
	if ([[objects objectAtIndex:0] class] == [RKMItem class]) {
		RKMItem* item = (RKMItem*)[objects objectAtIndex:0];
		
		int i = [GlobalSettings.baseURL length];
		cntTags = [item.tags.members count];
		
		if (cntTags == 0) {
			[self->_delegate tagsDidLoad: [NSArray arrayWithArray:nil]];
			return;
		}
		
		for (NSString* resourcePath in item.tags.members) {
			resourcePath = [resourcePath substringFromIndex:i];
			[self load:resourcePath class:[RKOTagItem class]];			
		}
	}
	
	if ([[objects objectAtIndex:0] class] == [RKOTagItem class]) {
		RKOTagItem* tagItem = (RKOTagItem*)[objects objectAtIndex:0];
		
		int i = [GlobalSettings.baseURL length];
		
		NSString* resourcePath = [tagItem.tag substringFromIndex:i];
		[self load:resourcePath class:[RKOTag class]];
	}
	
	if ([[objects objectAtIndex:0] class] == [RKOTag class]) {
		RKOTag* tagItem = (RKOTag*)[objects objectAtIndex:0];		
		
		cntTags--;
		
		if (cntTags == 0) {
			[self.objects addObject:tagItem];
			[self->_delegate tagsDidLoad:[NSArray arrayWithArray:self.objects]];
			return;
		} else {
			[self.objects addObject:tagItem];
			return;
		}
	} 
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
	[self->_delegate tagsDidLoad: [NSArray arrayWithArray:nil]];
}

@end
