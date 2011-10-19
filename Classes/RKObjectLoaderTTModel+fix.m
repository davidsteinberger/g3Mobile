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
#import "RKMItem.h"

@implementation RKObjectLoaderTTModel (fix)

#pragma mark RKModelLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)loader willMapData:(inout id *)mappableData {
	if ([(NSMutableArray *) * mappableData count] > 0) {
		if (loader.objectMapping.objectClass == [RKMTree class]) {
			NSArray *origEntities = [*mappableData valueForKeyPath:@"entity"];
			NSMutableArray *newEntity =
			        [[NSMutableArray alloc] initWithCapacity:[origEntities count]];

			NSDictionary *entity =
			        [( (NSDictionary *)[origEntities objectAtIndex:0] ) objectForKey:
			         @"entity"];
			int i = [[entity objectForKey:@"id"] intValue];
			for (NSDictionary *origEntity in origEntities) {
				NSMutableDictionary *oneEntity = [origEntity mutableCopy];

				// inject the position in the array
				NSMutableDictionary *entity =
				        ([(NSDictionary *)[oneEntity objectForKey:@"entity"]
				          mutableCopy]);
				[entity setObject:[NSString stringWithFormat:@"%i",
				                   i] forKey:@"positionInAlbum"];

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