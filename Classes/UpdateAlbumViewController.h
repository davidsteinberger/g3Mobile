//
//  AddAlbumViewController.h
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"

@class MyThumbsViewController;

@interface UpdateAlbumViewController : TTTableViewController <TTModel, UITextFieldDelegate> {
	NSString* _albumID;
	NSDictionary* _entity;	
	
	UITextField* _albumTitle;
	UITextField* _description;
	UITextField* _internetAddress;
}

@property(nonatomic, retain) NSString* albumID;
@property(nonatomic, retain) NSDictionary* entity;

- (id)initWithAlbumID: (NSString* )albumID;
- (void)loadAlbum;
- (void)updateAlbum;
- (NSString *)urlEncodeValue:(NSString *)str;

@end
