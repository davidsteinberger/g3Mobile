//
//  RKManagedObjectSeeder+persist.m
//  g3Mobile
//
//  Created by David Steinberger on 7/5/11.
//  Copyright 2011 -. All rights reserved.
//

#import "RKManagedObjectSeeder+persist.h"

@interface RKManagedObjectSeeder ()

- (id)initByKeepingPersistantStoreWithObjectManager:(RKObjectManager*)manager;

@end


@implementation RKManagedObjectSeeder (persist)

+ (RKManagedObjectSeeder*)ObjectSeederByKeepingPersistantStoreWithObjectManager:(RKObjectManager*)objectManager {
    return [[[RKManagedObjectSeeder alloc] initByKeepingPersistantStoreWithObjectManager:objectManager] autorelease];
}

- (id)initByKeepingPersistantStoreWithObjectManager:(RKObjectManager*)manager {
    self = [self init];
	if (self) {
		_manager = [manager retain];
        
        // If the user hasn't configured an object store, set one up for them
        if (nil == _manager.objectStore) {
            _manager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:RKDefaultSeedDatabaseFileName];
        }
	}
	
	return self;
}

@end
