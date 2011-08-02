//
//  MyAlbumUpdater.h
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import "Three20/Three20.h"
#import "MyViewController.h"
#import "RestKit/RestKit.h"

@interface MyAlbumUpdater : NSObject<RKRequestDelegate> {
    id<MyViewController> _delegate;
	NSMutableDictionary* _params;
	NSString* _albumID;
}

@property (nonatomic, assign) id<MyViewController> delegate;
- (id) initWithItemID:(NSString *)itemID andDelegate:(id<MyViewController>)delegate;
- (void) setValue:(NSString* )value param:(NSString* )param;
- (void) update;

+ (MyAlbumUpdater *)sharedMyAlbumUpdater;

@end
