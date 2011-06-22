//
//  AddAlbumViewController.h
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import "Three20/Three20.h"
#import "MyViewController.h"

@class MyThumbsViewController;

@interface AddAlbumViewController : TTTableViewController <UITextFieldDelegate> {
	id <MyViewController> _delegate;
    NSString* _parentAlbumID;
	
	UITextField* _albumTitle;
	UITextField* _description;
	UITextField* _internetAddress;
}

@property(nonatomic, retain) NSString* parentAlbumID;
@property(nonatomic, assign) id<MyViewController> delegate;

- (id)initWithParentAlbumID: (NSString* )albumID andDelegate:(id<MyViewController>) delegate;

@end
