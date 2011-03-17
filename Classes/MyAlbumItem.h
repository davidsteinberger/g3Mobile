/*
 * MyAlbumItem.h
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

// Three20
#import "Three20/Three20.h"

// RestKit
#import "RKOEntity.h"

// Others
#import "MyItem.h"

//TTTableMessageItem
@interface MyAlbumItem : TTTableLinkedItem <MyItem> {
	// meta-data
	RKOEntity *_model;
	NSString *_itemID;
	NSString *_type;

	// ivars for content that will be set from datasource
	NSString *_title;
	NSString *_autor;
	NSString *_description;
	NSDate *_timestamp;
	NSString *_imageURL;
	float _width;
	float _height;
}

@property (nonatomic, retain) RKOEntity *model;
@property (nonatomic, retain) NSString *itemID;
@property (nonatomic, retain) NSString *type;

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *autor;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSDate *timestamp;
@property (nonatomic, copy)   NSString *imageURL;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

+ (id)itemWithItemID:(NSString *)itemID model:(RKOEntity *)model type:(NSString *)type
       title:(NSString *)title caption:(NSString *)caption description:(NSString *)description
       text:(NSString *)text timestamp:(NSDate *)timestamp imageURL:(NSString *)imageURL
       width:(CGFloat)width height:(CGFloat)height URL:(NSString *)URL;
@end