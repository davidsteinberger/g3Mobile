/*
 * MyUploadViewController.m
 * #g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 14/3/2011.
 * Copyright (c) 2011 David Steinberger
 *
 * This file is part of g3Mobile.
 *
 * g3Mobile is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * g3Mobile is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with g3Mobile.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "MyUploadViewController.h"

// Settings
#import "MySettings.h"

// RestKit
#import "RestKit/RestKit.h"

// Others
#import "UIImage+resizing.h"

static NSString *defaultCaption = @"Write a Caption ...";

@interface MyUploadViewController ()

@property (assign) id delegate;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *caption;
@property (nonatomic, retain) UIImage *screenShot;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *albumID;

- (IBAction)cancel:(id)sender;
- (IBAction)upload:(id)sender;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@implementation MyUploadViewController

@synthesize imageView = _imageView;
@synthesize caption = _caption;
@synthesize screenShot = _screenShot;
@synthesize image = _image;
@synthesize albumID = _albumID;
@synthesize delegate = _delegate;
@synthesize params = _params;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

- (void)dealloc {
	self.delegate = nil;
	TT_RELEASE_SAFELY(_params);
	TT_RELEASE_SAFELY(_imageView);
	TT_RELEASE_SAFELY(_caption);
	TT_RELEASE_SAFELY(_screenShot);
	TT_RELEASE_SAFELY(_image);
	TT_RELEASE_SAFELY(_albumID);
	TT_RELEASE_SAFELY(_progressView);
	TT_RELEASE_SAFELY(_progressAlert);
	[super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ( (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) ) {
		_progressAlert = [[UIAlertView alloc] initWithTitle:@"Image upload"
		                                            message:@"Please wait..."
		                                           delegate:self
		                                  cancelButtonTitle:nil
		                                  otherButtonTitles:nil];
		_progressView =
		        [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 225.0f,
		                                                         90.0f)];
		[_progressAlert addSubview:_progressView];
		[_progressView setProgressViewStyle:UIProgressViewStyleBar];
	}
	return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];

	[self.navigationController setNavigationBarHidden:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:YES];

	self.delegate = [self.params objectForKey:@"delegate"];
	self.image = [self.params objectForKey:@"image"];
	self.screenShot = [self.params objectForKey:@"screenShot"];
	self.albumID = [self.params objectForKey:@"albumID"];

	self.imageView.image = self.screenShot;

	self.caption.text = defaultCaption;
}


- (void)viewDidUnload {
    [super viewDidUnload];
    [self.navigationController setNavigationBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Interface Builder

- (IBAction)cancel:(id)sender {
    [self.navigationController setNavigationBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)upload:(id)sender {
	if (self.image == nil) {
		self.image = [TTIMAGE (@"bundle://empty.png") scaleToSize:CGSizeMake(320, 480)];
	}

	NSData *imageData =
	        UIImageJPEGRepresentation(
	                self.image,
	                GlobalSettings.imageQuality ? GlobalSettings.
	                imageQuality : 0.5);

	NSString *imageName =
	        [@"Mobile_Upload_" stringByAppendingString:[NSString stringWithFormat:@"%d",
	                                                    GlobalSettings.uploadCounter++]];

	NSString *imageCaption =
	        ([self.caption.text isEqual:defaultCaption]) ? @"" : self.caption.text;
	NSDictionary *metaData =
	        [NSDictionary dictionaryWithObjectsAndKeys:
	         [imageName stringByAppendingString:@".jpg"], @"name",
	         (imageCaption == nil) ? @""              :imageCaption,
	         @"description",
	         @"photo", @"type",
	         nil];

	RKClient *client = [RKObjectManager sharedManager].client;
	[client setValue:@"post" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	RKParams *postParams = [RKParams params];

	NSError *error = nil;
	id <RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
	NSString *metaDataString = [parser stringFromObject:metaData error:&error];

	[postParams setValue:metaDataString forParam:@"entity"];
	[postParams setData:imageData MIMEType:@"application/octet-stream" forParam:@"file"];

	NSString *resourcePath = [@"/rest/item/" stringByAppendingString:self.albumID];
	[client post:resourcePath params:postParams delegate:self];

	[client setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
}


- (void)requestDidStartLoad:(RKRequest *)request {
	[_progressAlert show];
}


- (void)request:(RKRequest *)request didSendBodyData:(NSInteger)bytesWritten
       totalBytesWritten:(NSInteger)totalBytesWritten
       totalBytesExpectedToWrite:(NSInteger)
       totalBytesExpectedToWrite {
	_progressView.progress = ( (float)totalBytesWritten / (float)totalBytesExpectedToWrite );
}


- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
	[_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[self.delegate reloadViewController:NO];
	[self dismissModalViewControllerAnimated:YES];
}


- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
	NSLog(@"didFailLoadWithError");
	[_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[self.delegate reloadViewController:NO];
	[self dismissModalViewControllerAnimated:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];

	if (touch.view.tag == 777) {
		NSString *textForPostController =
		        ([self.caption.text isEqual:defaultCaption]) ? @"" : self.caption.text;
		NSDictionary *paramsArray = [NSDictionary dictionaryWithObjectsAndKeys:
		                             self, @"delegate",
		                             @"Add Caption", @"titleView",
		                             textForPostController, @"text",
		                             nil];

		[[TTNavigator navigator] openURLAction:
		 [[[TTURLAction actionWithURLPath:@"tt://loadFromVC/MyPostController"]
		   applyQuery:paramsArray] applyAnimated:YES]];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTPostControllerDelegate

- (void)postController:(TTPostController *)postController didPostText:(NSString *)text
       withResult:(id)result {
	self.caption.text = nil;
	self.caption.text = ([text isEqual:@""]) ? defaultCaption : text;
}


- (void)postControllerDidCancel:(TTPostController *)postController {
}


@end