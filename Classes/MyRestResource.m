//
//  MyRestResource.m
//  g3Mobile
//
//  Created by David Steinberger on 1/30/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyRestResource.h"
#import "Three20/Three20.h"

@implementation MyRestResource

@synthesize rootObject = _rootObject;
@synthesize url = _url;
@synthesize entity = _entity;
@synthesize members = _members;
@synthesize relationships = _relationships;

- (void)dealloc {
	TT_RELEASE_SAFELY(_rootObject);
	TT_RELEASE_SAFELY(_url);
	TT_RELEASE_SAFELY(_entity);
	TT_RELEASE_SAFELY(_members);
	TT_RELEASE_SAFELY(_relationships);
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	MyRestResource* copy = [[[self class] allocWithZone: zone] init];
	
	//copy.url = [[NSDictionary allocWithZone:zone] initWithDictionary:self.url copyItems:YES];
	copy.rootObject = self.rootObject;
	copy.url = self.url;
	copy.entity = self.entity;
	copy.members = self.members;
	copy.relationships = self.relationships;
	
	return copy;
}

#pragma mark -
#pragma mark Key-Value Coding

- (id)valueForKeyPath:(NSString *)keyPath {
	id value = [self.rootObject valueForKeyPath:keyPath];
	
	return value;
}

@end
