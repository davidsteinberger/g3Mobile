//
//  MyUploadViewController.m
//  g3Mobile
//
//  Created by David Steinberger on 1/3/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyUploadViewController.h"
#import "Three20/Three20.h"
#import "MyImageUploader.h"
#import "UIImage+resizing.h"
#import "MyThumbsViewController.h"

static NSString* defaultCaption = @"Write a Caption ...";

@implementation MyUploadViewController

@synthesize imageView, caption, screenShot, image, albumID, delegate, params;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	
	self.delegate = [self.params objectForKey:@"delegate"];
	self.image = [self.params objectForKey:@"image"];
	self.screenShot = [self.params objectForKey:@"screenShot"];
	self.albumID = [self.params objectForKey:@"albumID"];
	
	self.imageView.image = self.screenShot;
	
	self.caption.text = defaultCaption;
	/*
	[[self.cancel layer] setCornerRadius:4.0f];
	[[self.cancel layer] setMasksToBounds:YES];
	[[self.cancel layer] setBorderWidth:1.0f];
	[[self.cancel layer] setBackgroundColor:[[UIColor lightGrayColor] CGColor]];
	*/
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	
	self.delegate = nil;
	self.params = nil;
	
	self.imageView = nil;
	self.caption = nil;
	
	self.screenShot = nil;
	self.image = nil;
	self.albumID = nil;
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.delegate = nil;
	self.params = nil;
	
	self.imageView = nil;
	self.caption = nil;
	
	self.screenShot = nil;
	self.image = nil;
	self.albumID = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Toolbar Actions

- (IBAction)Cancel:(id)sender {
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)Upload:(id)sender {
	MyImageUploader* uploader = [[MyImageUploader alloc] initWithAlbumID:self.albumID delegate:self];
	NSString *imageCaption = ([self.caption.text isEqual:defaultCaption]) ? @"" : self.caption.text;
	[uploader uploadImage:self.image withDescription:imageCaption];
	TT_RELEASE_SAFELY(uploader);
}


-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	UITouch *touch = [touches anyObject];

	if(touch.view.tag == 777) {
		NSString *textForPostController = ([self.caption.text isEqual:defaultCaption]) ? @"" : self.caption.text;
		NSDictionary* paramsArray = [NSDictionary dictionaryWithObjectsAndKeys:
								self, @"delegate",
								@"Add Caption", @"titleView",
								textForPostController, @"text",
								nil];
		
		[[TTNavigator navigator] openURLAction:[[[TTURLAction actionWithURLPath:@"tt://loadFromVC/MyPostController"]
												 applyQuery:paramsArray] applyAnimated:YES]];
	}
}

- (void)postController:(TTPostController*)postController didPostText:(NSString *)text withResult:(id)result {
	self.caption.text = nil;
	self.caption.text = ([text isEqual:@""]) ? defaultCaption : text;
}

- (void)postControllerDidCancel:(TTPostController*)postController {

}

- (void)uploaderDidUpload:(id)sender {
	[((MyThumbsViewController*)self.delegate) reload];	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[self dismissModalViewControllerAnimated:YES];
}


@end
