/*
 * MyThumbsViewDataSource2.h
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
/*
 * The Datasource for the MyThumbsViewController2
 *
 * In the Three20 philosophy the datasource builds the rows that
 * go into the tableview. In this implementation we leverage the
 * RKRequestRKObjectLoaderTTModel to do the async load of the collection data
 * (the tree resource).
 */

#import "Three20/Three20.h"

// RestKit
#import <RestKit/RestKit.h>

@class RKObjectLoaderTTModel;

@interface MyThumbsViewDataSource2 : TTListDataSource<RKRequestDelegate> {
    NSString* _itemID;
    RKObjectLoaderTTModel* _itemModel;
}

@property (nonatomic, retain) NSString* itemID;
@property (nonatomic, retain) RKObjectLoaderTTModel* itemModel;
- (id)initWithItemID:(NSString *)itemID;

@end