//
//  TTPhotoViewController+preload.m
//  g3Mobile
//
//  Created by David Steinberger on 8/6/11.
//  Copyright 2011 -. All rights reserved.
//

#import "TTPhotoViewController+preload.h"
#import "MySettings.h"

@interface TTPhotoViewController()

- (void)showPhoto:(id<TTPhoto>)photo inView:(TTPhotoView*)photoView;

@end

@implementation TTPhotoViewController (preload)

/*
 * To enhance the user experience a thumbnail image is shown while loading
 * This tries mimic the behavior of the Facebook app
 */
- (UIView*)scrollView:(TTScrollView*)scrollView pageAtIndex:(NSInteger)pageIndex {
    TTPhotoView* photoView = (TTPhotoView*)[_scrollView dequeueReusablePage];
    id<TTPhoto> photo = [_photoSource photoAtIndex:pageIndex];
    
    if (!photoView) {
        photoView = [self createPhotoView];
        photoView.captionStyle = _captionStyle;
        photoView.defaultImage = _defaultImage;
        photoView.hidesCaption = _toolbar.alpha == 0;
    }
    
    NSString* url = [photo URLForVersion:TTPhotoVersionThumbnail];
    
    UIImage  *img = [[TTURLCache sharedCache] imageForURL:url];
    
    if (!img) {
        TTURLRequest* request = [TTURLRequest requestWithURL:url delegate:self];
        request.response = [[[TTURLImageResponse alloc] init] autorelease];
        [request setValue:GlobalSettings.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
        
        [request sendSynchronously];        
        
        img = ((TTURLImageResponse*)request.response).image;
    }
    
    photoView.defaultImage = img;
    
    [self showPhoto:photo inView:photoView];
    
    return photoView;
}

- (void)showPhoto:(id<TTPhoto>)photo inView:(TTPhotoView*)photoView {
    photoView.photo = photo;
    if (!photoView.photo && _statusText) {
        [photoView showStatus:_statusText];
    }
}

@end
