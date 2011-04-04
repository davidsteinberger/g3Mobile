/*
 * MyTagHelper.m
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

#import "MyTagHelper.h"

// RestKit
#import "RKMItem.h"
#import "MySettings.h"
#import "Three20/Three20.h"

static int cntTags = 0;

@interface MyTagHelper ()

// If possible loads from rest resource from cache, otherwise touches the net
- (void)load:(NSString *)resourcePath class:(Class)class;

@end

@implementation MyTagHelper

@synthesize delegate = _delegate;
@synthesize resourcePath = _resourcePath;
@synthesize objects = _objects;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

- (void)dealloc {
	[[RKRequestQueue sharedQueue] cancelAllRequests];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	TT_RELEASE_SAFELY(_resourcePath);
	TT_RELEASE_SAFELY(_objects);
	[super dealloc];
}


- (id)initWithResourcePath:(NSString *)resourcePath delegate:(id <MyTagHelperDelegate>)delegate {
	self.resourcePath = resourcePath;
	self.delegate = delegate;
	self.objects = [NSMutableArray array];
	cntTags = 0;
	[self load:resourcePath class:[RKMItem class]];
	return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
	if ([[objects objectAtIndex:0] class] == [RKMItem class]) {
		RKMItem *item = (RKMItem *)[objects objectAtIndex:0];

		int i = [GlobalSettings.baseURL length];
		cntTags = [item.tags.members count];

		if (cntTags == 0) {
			[self.delegate tagsDidLoad:[NSArray arrayWithArray:nil]];
			return;
		}

		for (NSString *resourcePath in item.tags.members) {
			resourcePath = [resourcePath substringFromIndex:i];
			[self load:resourcePath class:[RKOTagItem class]];
		}
	}

	if ([[objects objectAtIndex:0] class] == [RKOTagItem class]) {
		RKOTagItem *tagItem = (RKOTagItem *)[objects objectAtIndex:0];

		int i = [GlobalSettings.baseURL length];

		NSString *resourcePath = [tagItem.tag substringFromIndex:i];
		[self load:resourcePath class:[RKOTag class]];
	}

	if ([[objects objectAtIndex:0] class] == [RKOTag class]) {
		RKOTag *tagItem = (RKOTag *)[objects objectAtIndex:0];

		cntTags--;

		if (cntTags == 0) {
			[self.objects addObject:tagItem];
			[self.delegate tagsDidLoad:[NSArray arrayWithArray:self.objects]];
			return;
		}
		else {
			[self.objects addObject:tagItem];
			return;
		}
	}
}


- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	[self.delegate tagsDidLoad:[NSArray arrayWithArray:nil]];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark private

// If possible loads from rest resource from cache, otherwise touches the net
- (void)load:(NSString *)resourcePath class:(Class)class {
	RKObjectManager *objectManager = [RKObjectManager sharedManager];
	RKManagedObjectStore *store = objectManager.objectStore;

	NSArray *cacheFetchRequests = nil;
	NSArray *cachedObjects = nil;

	if (store.managedObjectCache) {
		cacheFetchRequests =
		        [store.managedObjectCache fetchRequestsForResourcePath:resourcePath];
		cachedObjects = [RKManagedObject objectsWithFetchRequests:cacheFetchRequests];

		if ([cachedObjects count] > 0) {
			id object = [cachedObjects objectAtIndex:0];
			[self objectLoader:nil didLoadObjects:[NSArray arrayWithObjects:object,
			                                       nil]];
		}
		else {
			RKObjectLoader *objectLoader =
			        [objectManager objectLoaderWithResourcePath:resourcePath delegate:
			         self];
			objectLoader.objectClass = class;
			[objectLoader send];
		}
	}
	else {
		RKObjectLoader *objectLoader =
		        [objectManager objectLoaderWithResourcePath:resourcePath delegate:self];
		objectLoader.objectClass = class;
		[objectLoader send];
	}
}


@end