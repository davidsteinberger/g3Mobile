//
//  TTTableMessageItem+g3.h
//  g3Mobile
//
//  Created by David Steinberger on 2/6/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Three20/Three20.h"
#import "MyItem.h"
#import "RKOEntity.h"

//TTTableMessageItem
@interface MyAlbumItem : TTTableLinkedItem<MyItem> {
	// meta-data
	RKOEntity* _model;
	NSString* _itemID;
	NSString* _type;
	
	// ivars for content that will be set from datasource
	NSString* _title;
	NSString* _autor;
	NSString* _description;
	NSDate*   _timestamp;
	NSString* _imageURL;
	float _width;
	float _height;
}

@property (nonatomic, retain) RKOEntity* model;
@property (nonatomic, retain) NSString* itemID;
@property (nonatomic, retain) NSString* type;

@property (nonatomic, copy)   NSString* title;
@property (nonatomic, copy)   NSString* autor;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSDate*   timestamp;
@property (nonatomic, copy)   NSString* imageURL;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

+ (id)itemWithItemID:(NSString*)itemID model:(RKOEntity*)model type:(NSString*)type title:(NSString*)title caption:(NSString*)caption description:(NSString*)description text:(NSString*)text
		   timestamp:(NSDate*)timestamp imageURL:(NSString*)imageURL width:(CGFloat)width height:(CGFloat)height URL:(NSString*)URL;
@end
