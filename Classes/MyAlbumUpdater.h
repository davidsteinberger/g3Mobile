//
//  MyAlbumUpdater.h
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Three20/Three20.h"

@interface MyAlbumUpdater : NSObject {
	NSMutableDictionary* _params;
	NSString* _albumID;
}

- (id) initWithItemID:(NSString *)itemID;
- (void) setValue:(NSString* )value param:(NSString* )param;
- (void) update;
- (NSString *)urlEncodeValue:(NSString *)str;

@end
