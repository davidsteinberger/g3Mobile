//
//  MyUploadViewController.h
//  g3Mobile
//
//  Created by David Steinberger on 1/3/11.
//  Copyright 2011 -. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"

#import "TTPostControllerDelegate.h"


@interface MyUploadViewController : TTBaseViewController {
	id delegate;
	NSDictionary *params;

	UIImageView *imageView;
	UILabel *caption;
	
	UIImage *screenShot;
	UIImage *image;
	NSString *albumID;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *caption;

@property (nonatomic, retain) id params;

@property (nonatomic, retain) UIImage *screenShot;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *albumID;
@property (assign) id delegate;

// toolbar buttons
- (IBAction)Cancel:(id)sender;
- (IBAction)Upload:(id)sender;
-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;

- (void)uploaderDidUpload:(id)sender;

@end