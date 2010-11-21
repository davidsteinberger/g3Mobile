//
//  MyController.m
//  TTCatalog
//
//  Created by David Steinberger on 11/2/10.
//  Copyright 2010 -. All rights reserved.
//

#import "TTThumbsViewController+g3.h"
#import "MyPhotoViewController.h"
#import "MockPhotoSource.h"

@implementation TTThumbsViewController(album)

- (TTPhotoViewController*)createPhotoViewController {
	return [[[MyPhotoViewController alloc] init] autorelease];
}
	
- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo {
	MockPhoto* p = (MockPhoto *) photo;
	BOOL isAlbum = p.isAlbum;
	NSString* albumID = p.albumID;
//		NSLog(@"photo selected; isAlbum: %@", isAlbum);
//		NSLog(@"photo selected; albumID: %@", p.albumID);
	
	[_delegate thumbsViewController:self didSelectPhoto:photo];

	BOOL shouldNavigate = YES;
	if ([_delegate respondsToSelector:@selector(thumbsViewController:shouldNavigateToPhoto:)]) {
		shouldNavigate = [_delegate thumbsViewController:self shouldNavigateToPhoto:photo];
	}
	
	if (shouldNavigate) {
		if (isAlbum) {
			TTNavigator* navigator = [TTNavigator navigator];
			[navigator openURLAction:[[TTURLAction actionWithURLPath:[@"tt://photoTest2/" stringByAppendingString:albumID]] applyAnimated:YES]];
		} else {
			NSString* URL = [self URLForPhoto:photo];
			if (URL) {
				TTOpenURL(URL);
			} else {
				TTPhotoViewController* controller = [self createPhotoViewController];
				controller.centerPhoto = photo;
				[self.navigationController pushViewController:controller animated:YES];
			}
		}

	}
}

@end
