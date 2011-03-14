//
//  untitled.m
//  g3Mobile
//
//  Created by David Steinberger on 3/6/11.
//  Copyright 2011 -. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "RestKit/CoreData/RKManagedObjectStore.h"
#import <RestKit/CoreData/RKManagedObjectCache.h>
#import "RestKit/Three20/RKRequestTTModel.h"
#import "MySettings.h"

@interface RKRequestTTModel (g3)

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more;
- (void)load:(BOOL)forceReload;
- (void)modelsDidLoad:(NSArray*)models;

@end


@implementation RKRequestTTModel (g3)

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
	if (cachePolicy == TTURLRequestCachePolicyNetwork) {
		[self load:YES];
	} else {
		[self load:NO];
	}
}

- (void)modelsDidLoad:(NSArray*)models {
	[models retain];
	[_objects release];
	_objects = nil;
	
	_objects = models;
	_isLoaded = YES;
	
	[self didFinishLoad];
}

// for now a category on load to add the correct request-key!
- (void)load:(BOOL)forceReload {
	RKManagedObjectStore* store = [RKObjectManager sharedManager].objectStore;
	NSArray* cacheFetchRequests = nil;
	NSArray* cachedObjects = nil;
	if (store.managedObjectCache) {
		cacheFetchRequests = [store.managedObjectCache fetchRequestsForResourcePath:_resourcePath];
		cachedObjects = [RKManagedObject objectsWithFetchRequests:cacheFetchRequests];
	}

	if (!store.managedObjectCache || !cacheFetchRequests || _cacheLoaded ||
	 [cachedObjects count] == 0 || forceReload == YES /*[[RKObjectManager sharedManager] isOnline])*/) {
		 RKObjectLoader* objectLoader = [[RKObjectManager sharedManager] objectLoaderWithResourcePath:_resourcePath delegate:self];
		 objectLoader.method = self.method;
		 objectLoader.objectClass = _objectClass;
		 objectLoader.keyPath = _keyPath;
		 objectLoader.params = self.params;
		 
		 _isLoading = YES;
		 [self didStartLoad];

		 [objectLoader send];

	 } else if (cacheFetchRequests && !_cacheLoaded) {
		 _cacheLoaded = YES;
		 [self modelsDidLoad:cachedObjects];
	 }
}

- (id)loadSynchronous:(BOOL)forceReload {
	RKManagedObjectStore* store = [RKObjectManager sharedManager].objectStore;
	NSArray* cacheFetchRequests = nil;
	NSArray* cachedObjects = nil;
	if (store.managedObjectCache) {
		cacheFetchRequests = [store.managedObjectCache fetchRequestsForResourcePath:_resourcePath];
		cachedObjects = [RKManagedObject objectsWithFetchRequests:cacheFetchRequests];
		return cachedObjects;
	}
	
	if (!store.managedObjectCache || !cacheFetchRequests || _cacheLoaded ||
		[cachedObjects count] == 0 || forceReload == YES /*[[RKObjectManager sharedManager] isOnline])*/) {
		RKObjectLoader* objectLoader = [[RKObjectManager sharedManager] objectLoaderWithResourcePath:_resourcePath delegate:self];
		objectLoader.method = self.method;
		objectLoader.objectClass = _objectClass;
		objectLoader.keyPath = _keyPath;
		objectLoader.params = self.params;
		
		_isLoading = YES;
		[self didStartLoad];
		
		return [objectLoader sendSynchronously];		
	}
	return nil;
}


@end
