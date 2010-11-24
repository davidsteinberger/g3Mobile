//
//  TTButtonContent.m
//  TTCatalog
//
//  Created by David Steinberger on 11/7/10.
//  Copyright 2010 -. All rights reserved.
//

#import "TTButtonContent+g3.h"
#import "AppDelegate.h"

@implementation TTButtonContent(my)

- (void)reload {
	if (!_request && _imageURL) {
		//NSLog(@"imageUrl: %@",_imageURL);
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
			//dcab652d8b00b106e81a6f758d65e90b
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
			[request send];
		}
	}
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	TTURLImageResponse* response = request.response;
	self.image = response.image;
	[_button setNeedsDisplay];
	
	TT_RELEASE_SAFELY(_request);
	
	if ([_delegate respondsToSelector:@selector(imageView:didLoadImage:)]) {
		[_delegate imageView:nil didLoadImage:response.image];
	}
}

@end

