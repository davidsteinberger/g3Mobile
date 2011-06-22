//
//  MyController.m
//  TTCatalog
//
//  Created by David Steinberger on 11/2/10.
//  Copyright 2010 -. All rights reserved.
//

#import "TTThumbsViewController+g3.h"
#import "MyPhotoViewController.h"
#import "PhotoSource.h"

@implementation TTThumbsViewController(album)

- (TTPhotoViewController*)createPhotoViewController {
	return [[MyPhotoViewController alloc] init];
}
	
- (void)thumbsTableViewCell:(TTThumbsTableViewCell*)cell didSelectPhoto:(id<TTPhoto>)photo {
	Photo* p = (Photo *) photo;
	BOOL isAlbum = p.isAlbum;
	NSString* itemID = p.photoID;

	[_delegate thumbsViewController:self didSelectPhoto:photo];

	BOOL shouldNavigate = YES;
	if ([_delegate respondsToSelector:@selector(thumbsViewController:shouldNavigateToPhoto:)]) {
		shouldNavigate = [_delegate thumbsViewController:self shouldNavigateToPhoto:photo];
	}
	
	if (shouldNavigate) {
		if (isAlbum) {
			TTNavigator* navigator = [TTNavigator navigator];
			[navigator openURLAction:[[TTURLAction actionWithURLPath:[@"tt://thumbs/" stringByAppendingString:itemID]] applyAnimated:YES]];
		} else {
			TTPhotoViewController* controller = [self createPhotoViewController];
			controller.centerPhoto = photo;
			[self.navigationController pushViewController:controller animated:YES];
		}
	}
}

- (CGRect)rectForOverlayView {
    return [_tableView frameWithKeyboardSubtracted:0];
}

@end
