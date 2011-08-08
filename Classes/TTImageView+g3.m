//
//  MyPhotoView+g3.m
//  TTCatalog
//
//  Created by David Steinberger on 11/8/10.
//  Copyright 2010 -. All rights reserved.
//

#import "TTImageView+g3.h"
#import "MySettings.h"
#import "NSData+base64.h"

@implementation TTImageView(g3)

- (void)reload {
	if (nil == _request && nil != _urlPath) {
		UIImage* image = nil;
		
		if (nil != image) {
			_image = [image retain];
		} else {
			TTURLRequest* request = [TTURLRequest requestWithURL:_urlPath delegate:self];
			TTURLImageResponse* response = [[TTURLImageResponse alloc] init];
			request.response = response;
			TT_RELEASE_SAFELY(response);
			
			[request setValue:GlobalSettings.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
			
			if (![request send]) {
				// Put the default image in place while waiting for the request to load
				if (_defaultImage && _image != _defaultImage) {
					_image = [_defaultImage retain];
				}
			}
		}
	}
}

@end
