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

// RestKit
#import "RestKit/RestKit.h"

// Settings
#import "MySettings.h"

// Others
#import "UIImage+scaleAndRotate.h"

static NSString *defaultCaption = @"Write a Caption ...";

@interface MyUploadViewController ()

@property (assign) id delegate;
@property (nonatomic, retain) UIImagePickerController* pickerController;
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
	TT_RELEASE_SAFELY(_progressView);
	TT_RELEASE_SAFELY(_progressAlert);
	[super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ( (self = [super initWithNibName:nibNameOrNil bundle:nil]) ) {
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
        
        _pickerController = [[UIImagePickerController alloc] init];
        _pickerController.delegate = self;
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
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setToolbarHidden:YES];

    self.albumID = [self.query objectForKey:@"albumID"];
    self.delegate = [self.query objectForKey:@"delegate"];
	self.caption.text = defaultCaption;
    
    if ( [[self.query objectForKey:@"sourceType"] isEqualToString: @"UIImagePickerControllerSourceTypeCamera"] && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] == YES) {
        _pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        _pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    [self presentModalViewController:_pickerController animated:YES];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    [self.navigationController setNavigationBarHidden:NO];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIImagePickerController

// Handles the add-caption functionality by utilizing MyUploadViewController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(
                                                                                               NSDictionary *)info {    
	// get high-resolution picture (used for upload)
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	self.image = [image scaleAndRotateImageToMaxResolution:1024];
    
	// get screenshot (used for confirmation-dialog)
	self.screenShot = image;
    
    // update the nib
    self.imageView.image = self.screenShot;
    
    [_pickerController dismissModalViewControllerAnimated:YES];
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
	[self.delegate reloadViewController:NO];
	[_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
	NSLog(@"didFailLoadWithError");
	[_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
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