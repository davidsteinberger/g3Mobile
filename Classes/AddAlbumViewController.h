//
//  AddAlbumViewController.h
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"

@interface AddAlbumViewController : TTTableViewController <UITextFieldDelegate> {
	MyThumbsViewController* _delegate;
	NSString* _parentAlbumID;
	UITextField* _albumName;
	UITextField* _albumTitle;
}

@property(nonatomic, retain) NSString* parentAlbumID;
@property(nonatomic, retain) MyThumbsViewController* delegate;

- (id)initWithParentAlbumID: (NSString* )albumID delegate: (MyThumbsViewController *)delegate;
- (void)addAlbum;
- (NSString *)urlEncodeValue:(NSString *)str;

@end
