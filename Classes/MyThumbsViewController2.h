//
//  MyThumbsViewController2.h
//  g3Mobile
//
//  Created by David Steinberger on 2/5/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Three20/Three20.h"
#import "MyAlbumItem.h"

@interface MyThumbsViewController2 : TTTableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	NSString* _itemID;
	id<MyAlbumItem> _selectedAlbumItem;
	BOOL _showDetails;
	
	UIImagePickerController* _pickerController;
}

@property (nonatomic, retain) NSString* itemID;
@property (nonatomic, retain) id<MyAlbumItem> selectedAlbumItem;
@property (nonatomic, assign) BOOL showDetails;

@property (nonatomic, retain) UIView* backViewOld;
@property (nonatomic, retain) UIView* selectedCell;

- (TTView*)buildOverlayMenuWithFrame:(CGRect)frame type:(BOOL)type;
- (NSString*)getItemID;

@end
