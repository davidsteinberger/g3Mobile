//
//  MyImageUploader.h
//  gallery3
//
//  Created by David Steinberger on 11/21/10.
//  Copyright 2010 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyThumbsViewController.h"


@interface MyImageUploader : NSObject {
	NSString* _albumID;
	MyThumbsViewController* _delegate;
	
	UIAlertView* _progressAlert;
	UIActivityIndicatorView* _activityView;
	UIProgressView* _progressView;
}

@property (nonatomic, retain) NSString* albumID;
@property (nonatomic, retain) MyThumbsViewController* delegate;

- (id)initWithAlbumID:(NSString* ) albumID delegate:(MyThumbsViewController* )delegate;
- (void)uploadImage:(UIImage* ) image;
- (void)uploadImageData:(NSData* ) data;
- (void) createProgressionAlertWithMessage:(NSString *)message withActivity:(BOOL)activity;

@end
