//
//  TTButtonContent.m
//  TTCatalog
//
//  Created by David Steinberger on 11/7/10.
//  Copyright 2010 -. All rights reserved.
//

#import "TTButtonContent+g3.h"
#import "AppDelegate.h"

@implementation TTButtonContent(g3)
- (void)reload {
	if (!_request && _imageURL) {
		UIImage* image = [[TTURLCache sharedCache] imageForURL:_imageURL];
		if (image) {
			self.image = image;
			[_button setNeedsDisplay];
			
			if ([_delegate respondsToSelector:@selector(imageView:didLoadImage:)]) {
				[_delegate imageView:nil didLoadImage:image];
			}
		} else {
			TTURLRequest* request = [TTURLRequest requestWithURL:_imageURL delegate:self];
			request.response = [[[TTURLImageResponse alloc] init] autorelease];
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
			
			
			[request send];
		}
	}
}


@end

