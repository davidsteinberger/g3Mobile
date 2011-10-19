/*
 * MyMetaDataItem.h
 * #g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 16/3/2011.
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
#import <RestKit/RestKit.h>
#import <RestKit/Three20/RKObjectLoaderTTModel.h>
#import "RKMItem.h"

@interface MyMetaDataItem : TTTableLinkedItem <TTModelDelegate> {
	RKObjectLoaderTTModel *_model;
	RKMItem *_item;
	NSString *_itemID;
	NSString *_title;
	NSString *_description;
	NSString *_autor;
	NSDate *_timestamp;
	NSString *_tags;
}

@property (nonatomic, retain) RKObjectLoaderTTModel *model;
@property (nonatomic, retain) RKMItem *item;
@property (nonatomic, retain) NSString *itemID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *autor;
@property (nonatomic, retain) NSDate *timestamp;
@property (nonatomic, retain) NSString *tags;

+ (id)itemWithItemID:(NSString *)itemID delegate:(TTTableViewController *)delegate title:(NSString
                                                                                          *)title
       description:(NSString *)description autor:(NSString *)autor timestamp:(NSDate *)timestamp;

@end