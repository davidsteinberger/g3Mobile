//
//  MyThumbsViewModel2.h
//  g3Mobile
//
//  Created by David Steinberger on 2/5/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Three20/Three20.h"
@class MyRestResource;

@interface MyThumbsViewModel2 : TTModel {
	NSString* _itemID;
	NSArray* _restResource;
	
	NSString* _title;
	NSString* _description;
	NSString* _autor;
	NSString* _timestamp;
	NSString* _tags;
	
	BOOL _isLoading;
	BOOL _isLoaded;
}

@property (nonatomic, retain) NSString* itemID;
@property (nonatomic, retain) NSArray* restResource;

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* autor;
@property (nonatomic, retain) NSString* timestamp;
@property (nonatomic, retain) NSString* tags;

@end
