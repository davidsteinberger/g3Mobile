//
//  RKORelationShips.m
//  G3RestKitTest
//
//  Created by David Steinberger on 3/3/11.
//  Copyright 2011 -. All rights reserved.
//

#import "RKMItem.h"

@implementation RKMItem

@dynamic url;
@dynamic entity;
@dynamic tags;

- (void)dealloc {
	[super dealloc];
}

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"url", @"url",
			nil];
}

+ (NSDictionary*)elementToRelationshipMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"entity", @"entity",			
			@"relationships.tags", @"tags",
			nil];
}

+ (NSString*)primaryKeyProperty {
	return @"url";
}

@end


@implementation RKOTags

@dynamic url;
@dynamic members;

- (void)dealloc {
	[super dealloc];
}

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"url", @"url",
			@"members", @"members",			
			nil];
}

+ (NSDictionary*)elementToRelationshipMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			nil];
}

+ (NSString*)primaryKeyProperty {
	return @"url";
}

@end

@implementation RKOTagItem

@dynamic url;
@dynamic tag;

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"url", @"url",
			@"entity.tag", @"tag",
			nil];
}

+ (NSDictionary*)elementToRelationshipMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			nil];
}

+ (NSString*)primaryKeyProperty {
	return @"url";
}

@end



@implementation RKOTag

@dynamic url;
@dynamic name;
@dynamic count;

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"url", @"url",
			@"entity.name", @"name",
			@"entity.count", @"count",
			nil];
}

+ (NSString*)primaryKeyProperty {
	return @"url";
}

@end





@implementation RKOComments

@synthesize url = _url;

- (void)dealloc {
	[_url release];
	[super dealloc];
}

+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			@"url", @"url",
			nil];
}

+ (NSDictionary*)elementToRelationshipMappings {
	return [NSDictionary dictionaryWithKeysAndObjects:
			nil];
}

@end