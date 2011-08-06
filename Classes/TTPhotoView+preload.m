//
//  TTPhotoView+preload.m
//  g3Mobile
//
//  Created by David Steinberger on 8/6/11.
//  Copyright 2011 -. All rights reserved.
//

#import "TTPhotoView+preload.h"

#import "Three20UI/private/TTImageViewInternal.h"

@implementation TTPhotoView (preload)

/*
 * TTPhotoViewController (preload) preloads images
 * All images are scaled to fit the screen
 */
- (void)setImage:(UIImage*)image {
    if (image != _defaultImage
        || !_photo
        || self.urlPath != [_photo URLForVersion:TTPhotoVersionLarge]) {
        
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    [super setImage:image];
}

@end
