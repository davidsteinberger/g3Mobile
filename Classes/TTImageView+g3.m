//
//  MyPhotoView+g3.m
//  TTCatalog
//
//  Created by David Steinberger on 11/8/10.
//  Copyright 2010 -. All rights reserved.
//

#import "TTImageView+g3.h"
#import "AppDelegate.h"
#import "NSDataAdditions.h"

@implementation TTImageView(g3)

- (void)reload {
	if (nil == _request && nil != _urlPath) {
		UIImage* image = nil;
		
		//image = [[TTURLCache sharedCache] imageForURL:_urlPath];
		
		//NSLog(@"retrieve for urlPath: %@", _urlPath);
		if (nil != image) {
			_image = [image retain];
		} else {
			
			//TTURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_urlPath]];
			//[request setValue:@"MyValue" forHTTPHeaderField:@"MyField"];
			//NSLog(@"result: %@", [request allHTTPHeaderFields]);
			
			TTURLRequest* request = [TTURLRequest requestWithURL:_urlPath delegate:self];
			TTURLImageResponse* response = [[TTURLImageResponse alloc] init];
			request.response = response;
			TT_RELEASE_SAFELY(response);
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			
			[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
			
			//NSLog(@"appDelegate.challenge: %@", appDelegate.challenge);

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
