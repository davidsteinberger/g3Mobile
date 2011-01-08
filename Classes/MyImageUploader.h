//
//  MyImageUploader.h
//  gallery3
//
//  Created by David Steinberger on 11/21/10.
//  Copyright 2010 -. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MyUploadViewController;


@interface MyImageUploader : NSObject {
	NSString* _albumID;
	MyUploadViewController* _delegate;
	
	UIAlertView* _progressAlert;
	UIActivityIndicatorView* _activityView;
	UIProgressView* _progressView;
}

@property (nonatomic, retain) NSString* albumID;
@property (nonatomic, retain) MyUploadViewController* delegate;

- (id)initWithAlbumID:(NSString* ) albumID delegate:(MyUploadViewController*)delegate;
- (void)uploadImage;
- (void)uploadImage:(UIImage* )image withDescription:(NSString*)description;
- (void)uploadImageData:(NSData* )data withDescription:(NSString*)description;
- (void) createProgressionAlertWithMessage:(NSString *)message withActivity:(BOOL)activity;

@end
