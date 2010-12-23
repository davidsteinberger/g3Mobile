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
	NSString* _albumID;
	UITextField* _albumName;
	UITextField* _albumTitle;
}

@property(nonatomic, copy) NSString* albumID;
@property(nonatomic, retain) MyThumbsViewController* delegate;

- (id)initWithAlbumID: (NSString* )albumID delegate: (MyThumbsViewController *)delegate;
	
@end
