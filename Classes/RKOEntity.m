//
//  RKTEntity.m
//  RKTwitter
//
//  Created by David Steinberger on 2/20/11.
//  Copyright 2011 -. All rights reserved.
//

#import "RKOEntity.h"
#import "Three20/Three20.h"

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

#pragma mark RKObjectMappable methods

+ (NSDictionary*)elementToPropertyMappings {
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
    //self = [[RKOEntity alloc] init];
    //if (self != nil)
	if (self = [super init])
    {
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