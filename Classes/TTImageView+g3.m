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
		
		NSLog(@"retrieve for urlPath: %@", _urlPath);
		if (nil != image) {
			_image = [image retain];
		} else {
			
			//TTURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_urlPath]];
			//[request setValue:@"MyValue" forHTTPHeaderField:@"MyField"];
			//NSLog(@"result: %@", [request allHTTPHeaderFields]);
			
			TTURLRequest* request = [TTURLRequest requestWithURL:_urlPath delegate:self];
			request.response = [[[TTURLImageResponse alloc] init] autorelease];
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			//NSString *tmp = [NSString stringWithFormat:@"%@\r\n",[appDelegate.challenge stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			//stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]
			//NSLog(@"result: %@", tmp);
			//NSString* object = [NSString stringWithString:appDelegate.challenge];
			//NSString* key = [NSString stringWithString:@"X-Gallery-Request-Key"];
			//[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
			//[appDelegate.challenge stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
			//@"82808119e8f7a55e35ab0817b46f5c09"
			/*[TTURLRequest setDefaultHTTPHeaders:[NSDictionary dictionaryWithObjectsAndKeys:
											 object,
											key, nil]];*/
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
