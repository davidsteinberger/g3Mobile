//
//  MyThumbsViewController2.h
//  g3Mobile
//
//  Created by David Steinberger on 2/5/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Three20/Three20.h"
#import "MyAlbumItem.h"
#import "MyTagHelper.h"

@class MyTagHelper;

@interface MyThumbsViewController2 : TTTableViewController<MyTagHelperDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	MyTagHelper* _tagHelper;
	NSString* _itemID;
	id<MyItem> _selectedAlbumItem;
	int _cntTags;
	NSString* _tags;
	BOOL _showDetails;
	
	UIImagePickerController* _pickerController;
}

@property (nonatomic, retain) MyTagHelper* tagHelper;
@property (nonatomic, retain) NSString* itemID;
@property (nonatomic, assign) id<MyItem> selectedAlbumItem;
@property (nonatomic, retain) NSString* tags;
@property (nonatomic, assign) BOOL showDetails;

@property (nonatomic, retain) UIView* backViewOld;
@property (nonatomic, retain) UIView* selectedCell;

- (TTView*)buildOverlayMenuWithFrame:(CGRect)frame type:(BOOL)type;
- (NSString*)getItemID;

@end
