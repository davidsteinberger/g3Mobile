//
//  AddAlbumViewController.h
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import "Three20/Three20.h"
#import "MyViewController.h"
#import "RKMItem.h"

@class MyThumbsViewController;

@interface UpdateAlbumViewController : TTTableViewController <TTPostControllerDelegate, UITextFieldDelegate> {
	NSString* _albumID;
    id<MyViewController> _delegate;
    
	UITextField* _albumTitle;
	UITextField* _description;
	UITextField* _slug;
}

@property(nonatomic, retain) NSString* albumID;
@property (nonatomic, assign) id<MyViewController> delegate;

- (id)initWithAlbumID: (NSString* )albumID andDelegate:(id<MyViewController>) delegate;

@end
