/*
 * DBManagedObjectCache.m
 * g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 2/4/2011.
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

#import "DBManagedObjectCache.h"

// RestKit
#import "RKMTree.h"
#import "RKOEntity.h"
#import "MySettings.h"
#import "RKMItem.h"

@implementation DBManagedObjectCache

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark RKObjectMappable

- (NSArray *)fetchRequestsForResourcePath:(NSString *)resourcePath {
	NSString *predicateString = [GlobalSettings.baseURL stringByAppendingString:resourcePath];

	/*
	 * The Gallery3 rest resources used in this app can be differentiated by the last url
	 * segment
	 */
	NSArray *components = [resourcePath componentsSeparatedByString:@ "/"];
	NSString *restResource = [components objectAtIndex:2];

	// If tree-resource requested ...
	if ([restResource isEqual : @ "tree"]) {
		NSFetchRequest *request = [RKMTree fetchRequest];
		NSPredicate *predicate =
		[NSPredicate predicateWithFormat:@ "url = %@", predicateString, nil];
		[request setPredicate : predicate];
		NSSortDescriptor *sortDescriptor =
		[NSSortDescriptor sortDescriptorWithKey:@ "url" ascending:YES];
		[request setSortDescriptors :[NSArray arrayWithObject : sortDescriptor]];
		return [NSArray arrayWithObject : request];
	}

	// If tree-resource requested ...
	if ([restResource isEqual : @ "item"]) {
		NSFetchRequest *request = [RKMItem fetchRequest];
		NSPredicate *predicate =
		[NSPredicate predicateWithFormat:@ "url = %@", predicateString, nil];
		[request setPredicate : predicate];
		NSSortDescriptor *sortDescriptor =
		[NSSortDescriptor sortDescriptorWithKey:@ "url" ascending:YES];
		[request setSortDescriptors :[NSArray arrayWithObject : sortDescriptor]];
		return [NSArray arrayWithObject : request];
	}

	// If tree-resource requested ...
	if ([restResource isEqual : @ "tag_item"]) {
		NSFetchRequest *request = [RKOTagItem fetchRequest];
		NSPredicate *predicate =
		[NSPredicate predicateWithFormat:@ "url = %@", predicateString, nil];
		[request setPredicate : predicate];
		NSSortDescriptor *sortDescriptor =
		[NSSortDescriptor sortDescriptorWithKey:@ "url" ascending:YES];
		[request setSortDescriptors :[NSArray arrayWithObject : sortDescriptor]];
		return [NSArray arrayWithObject : request];
	}

	// If tree-resource requested ...
	if ([restResource isEqual : @ "tag"]) {
		NSFetchRequest *request = [RKOTag fetchRequest];
		NSPredicate *predicate =
		[NSPredicate predicateWithFormat:@ "url = %@", predicateString, nil];
		[request setPredicate : predicate];
		NSSortDescriptor *sortDescriptor =
		[NSSortDescriptor sortDescriptorWithKey:@ "url" ascending:YES];
		[request setSortDescriptors :[NSArray arrayWithObject : sortDescriptor]];
		return [NSArray arrayWithObject : request];
	}

	// If the resource is not managed via the cache -> return nil
	return nil;
}

@end