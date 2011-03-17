/*
 * MyAlbumItem.m
 * #g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 15/3/2011.
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

#import "MyAlbumItem.h"

@implementation MyAlbumItem

@synthesize model = _model;
@synthesize itemID = _itemID;
@synthesize type = _type;
@synthesize title = _title;
@synthesize autor = _autor;
@synthesize description = _description;
@synthesize timestamp = _timestamp;
@synthesize imageURL = _imageURL;
@synthesize width = _width;
@synthesize height = _height;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

- (void)dealloc {
	TT_RELEASE_SAFELY(_model);
	TT_RELEASE_SAFELY(_itemID);
	TT_RELEASE_SAFELY(_type);
	TT_RELEASE_SAFELY(_title);
	TT_RELEASE_SAFELY(_autor);
	TT_RELEASE_SAFELY(_description);
	TT_RELEASE_SAFELY(_timestamp);
	TT_RELEASE_SAFELY(_imageURL);
	[super dealloc];
}


// Creates the item and returns it
+ (id)itemWithItemID:(NSString *)itemID model:(RKOEntity *)model type:(NSString *)type
       title:(NSString *)title caption:(NSString *)caption description:(NSString *)description
       text:(NSString *)text
       timestamp:(NSDate *)timestamp imageURL:(NSString *)imageURL width:(CGFloat)width
       height:(CGFloat)height URL:(NSString *)URL {
	MyAlbumItem *item = [[[self alloc] init] autorelease];
	item.model = model;
	item.itemID = itemID;
	item.type = type;
	item.title = title;
	item.description = description;
	item.timestamp = timestamp;
	item.imageURL = imageURL;
	item.width = width;
	item.height = height;
	item.URL = URL;
	return item;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject

- (id)init {
	if (self = [super init]) {
		_width = 34;
		_height = 34;
		_description = @"";
	}

	return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		self.width = [decoder decodeFloatForKey:@"width"];
		self.height = [decoder decodeFloatForKey:@"height"];
		self.description = [decoder decodeObjectForKey:@"description"];
	}

	return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
	[super encodeWithCoder:encoder];

	if (self.width) {
		[encoder encodeFloat:self.width
		              forKey:@"width"];
	}
	if (self.height) {
		[encoder encodeFloat:self.height
		              forKey:@"height"];
	}
	if (self.description) {
		[encoder encodeObject:self.description
		               forKey:@"description"];
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MyAlbumItem Protocol

- (RKOEntity *)model {
	return self->_model;
}


@end