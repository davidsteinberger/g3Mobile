//
//  AddAlbumViewController.h
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"

@interface UpdateAlbumViewController : TTTableViewController <UITextFieldDelegate> {
	MyThumbsViewController* _delegate;
	NSString* _albumID;
	NSDictionary* _entity;
	UITextField* _albumName;
	UITextField* _albumTitle;
}

@property(nonatomic, retain) NSString* albumID;
@property(nonatomic, retain) NSDictionary* entity;
@property(nonatomic, retain) MyThumbsViewController* delegate;

- (id)initWithAlbumID: (NSString* )albumID delegate: (MyThumbsViewController *)delegate;
- (void)loadAlbum;
- (void)updateAlbum;
- (NSString *)urlEncodeValue:(NSString *)str;

@end
