//
//  MyMetaDataItem.h
//  g3Mobile
//
//  Created by David Steinberger on 2/16/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Three20/Three20.h"
#import "MyAlbumItem.h"

@interface MyMetaDataItem : TTTableItem<MyAlbumItem> {
	MyRestResource* _model;
	NSString* _title;
	NSString* _description;
	NSString* _autor;
	NSDate*   _timestamp;
	NSString*  _tags;
}

@property (nonatomic, retain) MyRestResource* model;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* autor;
@property (nonatomic, retain) NSDate*   timestamp;
@property (nonatomic, retain) NSString* tags;

+ (id)itemWithTitle:(NSString*)title model:(MyRestResource*)model description:(NSString*)description autor:(NSString*)autor timestamp:(NSDate*)timestamp tags:(NSString*)tags;

@end
