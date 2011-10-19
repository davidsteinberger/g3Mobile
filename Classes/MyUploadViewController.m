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

// Three20
#import <Three20UI/UIViewAdditions.h>

// Settings
#import "MySettings.h"

// RestKit
#import "RKMItem.h"

// Facebook
#import "MyFacebook.h"

// Others
#import "UIImage+scaleAndRotate.h"

static NSString *defaultCaption = @"Write a Caption ...";

@interface MyUploadViewController ()

@property (nonatomic, assign) id <MyViewController> delegate;
@property (nonatomic, retain) UIImagePickerController *pickerController;
@property (nonatomic, assign) UIImagePickerControllerSourceType sourceType;
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
@synthesize query = _query;
@synthesize pickerController = _pickerController;
@synthesize sourceType = _sourceType;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

- (void)dealloc {
	self.delegate = nil;
	TT_RELEASE_SAFELY(_pickerController);
	TT_RELEASE_SAFELY(_query);
	TT_RELEASE_SAFELY(_imageView);
	TT_RELEASE_SAFELY(_caption);
	TT_RELEASE_SAFELY(_screenShot);
	TT_RELEASE_SAFELY(_image);
	TT_RELEASE_SAFELY(_albumID);
	TT_RELEASE_SAFELY(_uploadProgress);
	[super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ( (self = [super initWithNibName:nibNameOrNil bundle:nil]) ) {
		_pickerController = [[UIImagePickerController alloc] init];
		_pickerController.delegate = self;
		_isPhotoUploaded = NO;
	}
	return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.navigationController setNavigationBarHidden:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
	[self.navigationController setToolbarHidden:YES];

	self.albumID = [self.query objectForKey:@"albumID"];
	self.delegate = [self.query objectForKey:@"delegate"];
	self.caption.text = defaultCaption;

	if ([[self.query objectForKey:@"sourceType"] isEqualToString:
	     @"UIImagePickerControllerSourceTypeCamera"] &&
	    [UIImagePickerController isCameraDeviceAvailable:
	     UIImagePickerControllerCameraDeviceFront]
	    == YES) {
		_pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	else {
		_pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	}

	_uploadProgress =
	        [[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleBlackBox];
	UIView *lastView = [self.view viewWithTag:777];
	_uploadProgress.text = @"Uploading ...";
	[_uploadProgress sizeToFit];
	_uploadProgress.frame = CGRectMake(0,
	                                   lastView.bottom - lastView.height - 50,
	                                   self.view.width,
	                                   50);

	_pickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:_pickerController animated:YES];
}


- (void)viewDidUnload {
	[super viewDidUnload];
	[self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
	[self.navigationController setToolbarHidden:NO];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIImagePickerController

// Handles the add-caption functionality by utilizing MyUploadViewController
- (void)imagePickerController:(UIImagePickerController *)picker
       didFinishPickingMediaWithInfo:(NSDictionary *)info {
	// get high-resolution picture (used for upload)
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	self.image = [image scaleAndRotateImageToMaxResolution:1024];

	// get screenshot (used for confirmation-dialog)
	self.screenShot = image;

	//[[[UIApplication sharedApplication] keyWindow] setRootViewController:self];
	[_pickerController dismissModalViewControllerAnimated:YES];

	// update the nib
	[self.imageView performSelector:@selector(setImage:) withObject:self.screenShot afterDelay:
	 0.3];
}


// Handles the cancellation of the picker
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self.delegate reloadViewController:NO];
	[self dismissModalViewControllerAnimated:NO];
	[self.navigationController popViewControllerAnimated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Interface Builder

- (IBAction)cancel:(id)sender {
	[self.delegate reloadViewController:NO];
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)upload:(id)sender {
	NSData *imageData =
	        UIImageJPEGRepresentation(
	                self.image,
	                GlobalSettings.imageQuality ? GlobalSettings.imageQuality : 0.5);
	NSString *imageName =
	        [@"Mobile_" stringByAppendingString:[NSString stringWithFormat:@"%d",
	                                             GlobalSettings.uploadCounter++]];
	NSString *imageCaption =
	        ([self.caption.text isEqual:defaultCaption]) ? @"" : self.caption.text;
	NSDictionary *metaData =
	        [NSDictionary dictionaryWithObjectsAndKeys:
	         imageName, @"name",
	         (imageCaption == nil) ? @""              :imageCaption, @"description",
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


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RKRequestDelegate

- (void)requestDidStartLoad:(RKRequest *)request {
	[self.view addSubview:_uploadProgress];
}


- (void)request:(RKRequest *)request didSendBodyData:(NSInteger)bytesWritten
       totalBytesWritten:(NSInteger)totalBytesWritten
       totalBytesExpectedToWrite:(NSInteger)
       totalBytesExpectedToWrite {
	_uploadProgress.progress = ( (float)totalBytesWritten / (float)totalBytesExpectedToWrite );
}


- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
	// Only the image upload request is handled here
	if (_isPhotoUploaded == NO) {
		_isPhotoUploaded = YES;
		int length = [GlobalSettings.baseURL length];
        NSError* error;
		NSString *urlString = [[response parsedBody:&error] objectForKey:@"url"];
		NSString *resourcePath = [urlString substringFromIndex:length];

		// Load the entity of the item details
		RKObjectManager *objectManager = [RKObjectManager sharedManager];
		RKObjectLoader *objectLoader =
		        [objectManager objectLoaderWithResourcePath:resourcePath delegate:self];
		objectLoader.objectMapping =
		        [objectManager.mappingProvider objectMappingForClass:[RKMItem class]];

		[objectLoader send];
	}
}


- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
	NSLog(@"request:didFailLoadWithError: %@", error.localizedDescription);
	[self.delegate reloadViewController:NO];
	[self.navigationController popViewControllerAnimated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark RKObjectLoaderDelegate

// Called when the uploaded Item got loaded and mapped
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
	RKMItem *item = (RKMItem *)[objects objectAtIndex:0];
	RKMEntity *entity = item.rEntity;

    if (GlobalSettings.showFBOnUploader) {
        [self.delegate
         postToFBWithName:[@"New Photo uploaded: " stringByAppendingString:entity.name]
                  andLink:[entity.web_url copy]
               andPicture:[entity.thumb_url_public copy]];
    }
	[self.delegate reloadViewController:NO];
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	NSLog(@"objectLoader:didFailWithError: %@", error.localizedDescription);
	[self.delegate reloadViewController:NO];
	[self.navigationController popViewControllerAnimated:YES];
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