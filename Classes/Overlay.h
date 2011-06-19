//
//  Overlay.h
//  g3Mobile
//
//  Created by David Steinberger on 6/13/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Three20/Three20.h"


@interface Overlay : NSObject {
}

/*
 * Build overlay menu within given Frame
 * Via the type parameter we can choose between a menu for an album or a photo
 */
+ (TTView *)buildOverlayMenuWithFrame:(CGRect)frame type:(BOOL)album withDelegate:(id)delegate;

// Builds the toolbar items and returns them
+ (NSArray*)buildToolbarWithDelegate:(id)delegate;

// Builds the toolbar for the thumbview controller (e.g. no sorting, ...)
+ (NSArray*)buildThumbViewToolbarWithDelegate:(id)delegate;

@end
