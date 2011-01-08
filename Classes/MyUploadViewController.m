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


@implementation MyUploadViewController

@synthesize imageView, caption, cancel, screenShot, image, albumID, delegate, params;

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
	
	[self.caption setTitle:@"Add Caption ..." forState:UIControlStateNormal];
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
	NSString *imageCaption = ([self.caption.titleLabel.text isEqual:@"Add Caption ..."]) ? @"" : self.caption.titleLabel.text;
	[uploader uploadImage:self.image withDescription:imageCaption];
	TT_RELEASE_SAFELY(uploader);
}

- (IBAction)Caption:(id)sender {	
	// prepare params
	NSString *textForPostController = ([self.caption.titleLabel.text isEqual:@"Add Caption ..."]) ? @"" : self.caption.titleLabel.text;
	NSDictionary* paramsArray = [NSDictionary dictionaryWithObjectsAndKeys:
							self, @"delegate",
							@"Add Caption", @"titleView",
							textForPostController, @"text",
							nil];
	
	//[[TTNavigator navigator] openURLAction:[[[TTURLAction actionWithURLPath:@"tt://nib/MyPostController"]
	//										 applyQuery:paramsArray] applyAnimated:YES]];
	
	[[TTNavigator navigator] openURLAction:[[[TTURLAction actionWithURLPath:@"tt://loadFromVC/MyPostController"]
											 applyQuery:paramsArray] applyAnimated:YES]];
}

- (void)postController:(TTPostController*)postController didPostText:(NSString *)text withResult:(id)result {
	self.caption.titleLabel.text = nil;
	[self.caption setTitle:text forState:UIControlStateNormal];
}

- (void)postControllerDidCancel:(TTPostController*)postController {

}

- (void)uploaderDidUpload:(id)sender {
	[((MyThumbsViewController*)self.delegate) loadAlbum:self.albumID];	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[self dismissModalViewControllerAnimated:YES];
}


@end
