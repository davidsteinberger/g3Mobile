/*
 * MyThumbsViewController2.h
 * #g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 14/3/2011.
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
 * A root controller that handles display of items (albums & photos)
 *
 * This controller is based on TTTableViewController of the Three20 library
 * This makes it fairly easy to asynchronously display results from a remote server.
 * The actual fetching of remote data is handled by RKRequestTTModel (a TTModel),
 * and the results are presented for display in a table view by MyThumbsViewDataSource2
 * (a TTTableViewDataSource).
 *
 * This controller has 2 functionalities that require extra explanation:
 * 1. It supports long tabs on the rows (UILongPressGestureRecognizer).
 *    It will then show a context menu based on the type of item (album or photo).
 * 2. It allows to drill into the data-objects behind the rows (the items).
 *    This is possible because the controller assumes that the table-items implement
 *    protocol MyItem.
 *    See http://three20.pypt.lt/custom-cells-in-tttableviewcontroller and
 *    checkout MyMetaDataItem/MyMetaDataItemCell or MyAlbumItem/MyAlbumItemCell
 */

#import "Three20/Three20.h"
#import "MyItem.h"
#import "MyLongPressGestureDelegate.h"
#import "MyTagHelper.h"

@class MyTagHelper;

@interface MyThumbsViewController2 : TTTableViewController <MyLongPressGestureDelegate,
	                                                    MyTagHelperDelegate,
	                                                    UINavigationControllerDelegate,
	                                                    UIImagePickerControllerDelegate> {
	NSString *_itemID;
	id <MyItem> _selectedAlbumItem;
	UIView *_backViewOld;
	UIView *_selectedCell;
	BOOL _showDetails;
	MyTagHelper *_tagHelper;
	int _cntTags;
	NSString *_tags;
	UIImagePickerController *_pickerController;
}

@property (nonatomic, retain) NSString *itemID;
@property (nonatomic, assign) id <MyItem> selectedAlbumItem;
@property (nonatomic, retain) UIView *backViewOld;
@property (nonatomic, retain) UIView *selectedCell;
@property (nonatomic, retain) MyTagHelper *tagHelper;
@property (nonatomic, retain) NSString *tags;
@property (nonatomic, assign) BOOL showDetails;

// Initializes view for given itemID (must be an album id)
- (id)initWithItemID:(NSString *)itemID;

@end