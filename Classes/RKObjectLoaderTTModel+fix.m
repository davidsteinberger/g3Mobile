/*
 * RKObjectLoaderTTModel+fix.m
 * g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 4/4/2011.
 *
 * Copyright (c) 2011 David Steinberger
 * All rights reserved.
 *
 * This file is part of g3Mobile.
 *
 * g3Mobile is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * g3Mobile is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with g3Mobile.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "RKObjectLoaderTTModel+fix.h"

// RestKit
#import "RKMTree.h"
#import "RKMEntity.h"

@implementation RKObjectLoaderTTModel (fix)

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RKModelLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)loader willMapData:(inout id *)mappableData {
	if ([(NSMutableArray *) * mappableData count] > 0) {
		if (loader.objectMapping.objectClass == [RKMTree class]) {
			NSArray *origEntities = [*mappableData valueForKeyPath:@"entity"];
			NSMutableArray *newEntity =
			        [[NSMutableArray alloc] initWithCapacity:[origEntities count]];

			int i = 0;
			for (NSDictionary *origEntity in origEntities) {
				NSMutableDictionary *oneEntity = [origEntity mutableCopy];

				NSMutableDictionary *entity =
				        ([(NSDictionary *)[oneEntity objectForKey:@"entity"]
				          mutableCopy]);

				/*
				 * Each album is at a certain position within it's parent album.
				 * If we just iterate over the album and enumerate the items the
				 *position in
				 * the parent album is lost.
				 * For that reason the position index of the album (root) must be
				 *preserved.
				 */
				if (i == 0) {
					RKManagedObjectStore *store =
					        [RKObjectManager sharedManager].objectStore;
					NSString *predicateString = [entity objectForKey:@"id"];

					NSFetchRequest *request = [RKMEntity fetchRequest];
					NSPredicate *predicate =
					        [NSPredicate predicateWithFormat:@
					         "itemID = %@", predicateString, nil];
					[request setPredicate:predicate];

					NSError *error;
					NSArray *objects =
					        [[store managedObjectContext]
					         executeFetchRequest:
					         request       error:&error];
					if ([objects count] > 0) {
						RKMEntity *object =
						        [objects objectAtIndex:0];

						NSNumber *positionInAlbum =
						        [NSNumber numberWithInt:
						         [object.positionInAlbum intValue]];

						[entity setObject:positionInAlbum forKey:
						 @"positionInAlbum"];
					}
				}
				else {
					[entity setObject:[NSString stringWithFormat:@"%i",
					                   i] forKey:@"positionInAlbum"];
				}
				[oneEntity removeObjectForKey:@"entity"];
				[oneEntity setObject:entity forKey:@"entity"];

				[newEntity addObject:oneEntity];
				[oneEntity release];
				[entity release];
				i++;
			}

			[*mappableData removeObjectForKey:@"entity"];
			[*mappableData setObject:newEntity forKey:@"entity"];
			[newEntity release];
		}
	}
}


@end