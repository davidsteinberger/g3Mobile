//
//  MyPhotoViewController.h
//  gallery3
//
//  Created by David Steinberger on 11/15/10.
//  Copyright 2010 -. All rights reserved.
//

#import <Three20/Three20.h>

#import "MyThumbsViewController.h"
#import "PhotoSource.h"

@interface MyPhotoViewController : TTPhotoViewController <UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate> {
}

- (void)moveToPhotoAtIndex:(NSInteger)photoIndex withDelay:(BOOL)withDelay;

@end
