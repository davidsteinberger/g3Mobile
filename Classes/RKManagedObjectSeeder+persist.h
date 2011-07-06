//
//  RKManagedObjectSeeder+persist.h
//  g3Mobile
//
//  Created by David Steinberger on 7/5/11.
//  Copyright 2011 -. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@interface RKManagedObjectSeeder (persist)

+ (RKManagedObjectSeeder*)ObjectSeederByKeepingPersistantStoreWithObjectManager:(RKObjectManager*)objectManager;

@end
