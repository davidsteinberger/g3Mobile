/*
 * MyMetaDataItem.m
 * #g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 16/3/2011.
 * Copyright (c) 2011 David Steinberger
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

#import "MyMetaDataItem.h"

@implementation MyMetaDataItem

@synthesize model = _model;
@synthesize item = _item;
@synthesize itemID = _itemID;
@synthesize title = _title;
@synthesize description = _description;
@synthesize autor = _autor;
@synthesize timestamp = _timestamp;
@synthesize tags = _tags;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

- (void)dealloc {
	[self.model.delegates removeAllObjects];
	[self.model didCancelLoad];
	TT_RELEASE_SAFELY(_model);
	TT_RELEASE_SAFELY(_item);
	TT_RELEASE_SAFELY(_itemID);
	TT_RELEASE_SAFELY(_title);
	TT_RELEASE_SAFELY(_description);
	TT_RELEASE_SAFELY(_autor);
	TT_RELEASE_SAFELY(_timestamp);
	TT_RELEASE_SAFELY(_tags);
	[super dealloc];
}


+ (id)itemWithItemID:(NSString *)itemID delegate:(TTTableViewController *)delegate title:(NSString
                                                                                          *)title
       description:(NSString *)description autor:(NSString *)autor timestamp:(NSDate *)timestamp {
	MyMetaDataItem *item = [[[self alloc] init] autorelease];
	item.itemID = itemID;
	item.title = title;
	item.description = description;
	item.autor = autor;
	item.timestamp = timestamp;
	item.tags = @"";

	item.delegate = delegate;

	NSString *itemResourcePath = [@"/rest/item/"
	                              stringByAppendingString:item.itemID];
	RKObjectLoader *objectLoader =
	        [[RKObjectManager sharedManager] objectLoaderWithResourcePath:itemResourcePath
	                                                             delegate:nil];
	objectLoader.objectMapping =
	        [[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[RKMItem
	                                                                                class]];
	item.model = [RKObjectLoaderTTModel modelWithObjectLoader:objectLoader];
	[item.model.delegates addObject:item];
	[item.model setRefreshRate:60];
	[item.model load];

	return item;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject

- (id)init {
	if ( (self = [super init]) ) {
	}
	return self;
}


#pragma mark -
#pragma mark TTModelDelegate

- (void)modelDidFinishLoad:(id <TTModel>)model {
	NSArray *objects = ( (RKObjectLoaderTTModel *)model ).objects;
	RKMItem *item = (RKMItem *)[objects objectAtIndex:0];
	RKMEntity *entity = item.rEntity;

	self.item = item;
	self.title = entity.title;
	self.description = entity.desc;

	if ([self.delegate isKindOfClass:[TTTableViewController class]]) {
		[( (TTTableViewController *)self.delegate ).tableView reloadData];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)model:(id <TTModel>)model didFailLoadWithError:(NSError *)error {
	NSLog(@"error: %@", error);
}


- (void)modelDidCancelLoad:(id <TTModel>)model {
	NSLog(@"cancel");
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
	if ( (self = [super initWithCoder:decoder]) ) {
		self.item = [decoder decodeObjectForKey:@"item"];
		self.itemID = [decoder decodeObjectForKey:@"itemID"];
		self.title = [decoder decodeObjectForKey:@"title"];
		self.description = [decoder decodeObjectForKey:@"description"];
		self.autor = [decoder decodeObjectForKey:@"autor"];
		self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
		self.tags = [decoder decodeObjectForKey:@"tags"];
	}

	return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
	[super encodeWithCoder:encoder];

	if (self.item) {
		[encoder encodeObject:self.item
		               forKey:@"item"];
	}

	if (self.itemID) {
		[encoder encodeObject:self.itemID
		               forKey:@"itemID"];
	}

	if (self.title)
		[encoder encodeObject:self.title
		               forKey:@"title"];

	if (self.description)
		[encoder encodeObject:self.description
		               forKey:@"description"];

	if (self.autor)
		[encoder encodeObject:self.autor
		               forKey:@"autor"];

	if (self.timestamp)
		[encoder encodeObject:self.timestamp
		               forKey:@"timestamp"];

	if (self.tags)
		[encoder encodeObject:self.tags
		               forKey:@"tags"];

	return;
}


@end