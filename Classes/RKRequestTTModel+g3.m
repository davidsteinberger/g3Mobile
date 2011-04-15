//
//  untitled.m
//  g3Mobile
//
//  Created by David Steinberger on 3/6/11.
//  Copyright 2011 -. All rights reserved.
//
#import "RKRequestTTModel+g3.h"

#import <RestKit/RestKit.h>
#import "RestKit/CoreData/RKManagedObjectStore.h"
#import <RestKit/CoreData/RKManagedObjectCache.h>
#import "RestKit/Three20/RKRequestTTModel.h"
#import "MySettings.h"
/*
@interface RKRequestTTModel1()

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more;
- (void)load:(BOOL)forceReload;
- (void)modelsDidLoad:(NSArray*)models;

@end
*/

@implementation RKRequestTTModel (sync)

- (id)loadSynchronous:(BOOL)forceReload {
	RKManagedObjectStore* store = [RKObjectManager sharedManager].objectStore;
	NSArray* cacheFetchRequests = nil;
	NSArray* cachedObjects = nil;
	if (store.managedObjectCache && !forceReload) {
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
		[objectLoader send];		
	}
	return nil;
}

@end
