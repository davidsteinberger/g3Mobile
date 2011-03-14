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

@interface AddAlbumViewController : TTTableViewController <UITextFieldDelegate> {
	NSString* _parentAlbumID;
	
	UITextField* _albumTitle;
	UITextField* _description;
	UITextField* _internetAddress;
}

@property(nonatomic, retain) NSString* parentAlbumID;

- (id)initWithParentAlbumID: (NSString* )albumID;
- (void)addAlbum;
- (NSString *)urlEncodeValue:(NSString *)str;

// required by TTModel protocol
- (NSMutableArray*)delegates;
- (BOOL)isLoaded;
- (BOOL)isLoading;
- (BOOL)isLoadingMore;
- (BOOL)isOutdated;
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more;
- (void)cancel;
- (void)invalidate:(BOOL)erase;

@end
