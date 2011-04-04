/*
 * RKOEntity.m
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

#import "RKOEntity.h"

@implementation RKOEntity

@synthesize id = _id;
@synthesize parent = _parent;
@synthesize type = _type;
@synthesize title = _title;
@synthesize description = _description;
@synthesize thumb_url_public = _thumb_url_public;
@synthesize thumb_url = _thumb_url;
@synthesize resize_url_public = _resize_url_public;
@synthesize resize_url = _resize_url;
@synthesize thumb_width = _thumb_width;
@synthesize thumb_height = _thumb_height;
@synthesize created = _created;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

- (void)dealloc {
	[_id release];
	[_parent release];
	[_type release];
	[_title release];
	[_description release];
	[_thumb_url_public release];
	[_thumb_url release];
	[_resize_url_public release];
	[_resize_url release];
	[_thumb_width release];
	[_thumb_height release];
	[_created release];

	[super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RKObjectMappable methods

+ (NSDictionary *)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
	        @"id", @"id",
	        @"parent", @"parent",
	        @"type", @"type",
	        @"title", @"title",
	        @"description", @"description",
	        @"thumb_url_public", @"thumb_url_public",
	        @"thumb_url", @"thumb_url",
	        @"resize_url_public", @"resize_url_public",
	        @"resize_url", @"resize_url",
	        @"thumb_width", @"thumb_width",
	        @"thumb_height", @"thumb_height",
	        @"created", @"created",
	        nil];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder;
{
	[coder encodeObject:self.id forKey:@"id"];
	[coder encodeObject:self.parent forKey:@"parent"];
	[coder encodeObject:self.type forKey:@"type"];
	[coder encodeObject:self.title forKey:@"title"];
	[coder encodeObject:self.description forKey:@"description"];
	[coder encodeObject:self.thumb_url_public forKey:@"thumb_url_public"];
	[coder encodeObject:self.thumb_url forKey:@"thumb_url"];
	[coder encodeObject:self.resize_url_public forKey:@"resize_url_public"];
	[coder encodeObject:self.resize_url forKey:@"resize_url"];
	[coder encodeObject:self.thumb_width forKey:@"thumb_width"];
	[coder encodeObject:self.thumb_height forKey:@"thumb_height"];
	[coder encodeObject:self.created forKey:@"created"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
	if ( (self = [super init]) ) {
		self.id = [coder decodeObjectForKey:@"id"];
		self.parent = [coder decodeObjectForKey:@"parent"];
		self.type = [coder decodeObjectForKey:@"type"];
		self.title = [coder decodeObjectForKey:@"title"];
		self.description = [coder decodeObjectForKey:@"description"];
		self.thumb_url_public = [coder decodeObjectForKey:@"thumb_url_public"];
		self.thumb_url = [coder decodeObjectForKey:@"thumb_url"];
		self.resize_url_public = [coder decodeObjectForKey:@"resize_url_public"];
		self.resize_url = [coder decodeObjectForKey:@"resize_url"];
		self.thumb_width = [coder decodeObjectForKey:@"thumb_width"];
		self.thumb_height = [coder decodeObjectForKey:@"thumb_height"];
		self.created = [coder decodeObjectForKey:@"created"];
	}
	return self;
}

@end