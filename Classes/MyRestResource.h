//
//  MyRestResource.h
//  g3Mobile
//
//  Created by David Steinberger on 1/30/11.
//  Copyright 2011 -. All rights reserved.
//

@interface MyRestResource : NSObject <NSCopying> {
	NSDictionary* _rootObject;
	NSString* _url;
	NSDictionary* _entity;
	NSDictionary* _members;
	NSDictionary* _relationships;
}

@property (nonatomic, retain) NSDictionary* rootObject;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSDictionary* entity;
@property (nonatomic, retain) NSDictionary* members;
@property (nonatomic, retain) NSDictionary* relationships;

// kvc implementation
- (id)valueForKeyPath:(NSString *)keyPath;

@end
