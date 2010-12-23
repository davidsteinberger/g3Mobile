//
//  MyPhotoViewController.m
//  gallery3
//
//  Created by David Steinberger on 11/15/10.
//  Copyright 2010 -. All rights reserved.
//

#import "MyPhotoViewController.h"

#import "AppDelegate.h"
#import "MockPhotoSource.h"
#import "MyItemDeleter.h"
#import "MyAlbumUpdater.h"

#import "extThree20JSON/extThree20JSON.h"

@implementation MyPhotoViewController

@synthesize parentController = _parentController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		/*self.navigationItem.backBarButtonItem =
		[[[UIBarButtonItem alloc]
		  initWithTitle:
		  TTLocalizedString(@"Photo",
							@"Title for back button that returns to photo browser")
		  style: UIBarButtonItemStylePlain
		  target: nil
		  action: nil] autorelease];
		*/
		self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
		self.navigationBarStyle = UIBarStyleBlackTranslucent;
		self.navigationBarTintColor = nil;
		self.wantsFullScreenLayout = YES;
		self.hidesBottomBarWhenPushed = YES;
		
		self.navigationItem.rightBarButtonItem
		= [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered
										   target:self action:@selector(setSettings)] autorelease];	  
		
		self.defaultImage = TTIMAGE(@"bundle://Three20.bundle/images/photoDefault.png");
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void)viewDidAppear {
	//self.navigationController.navigationBar.bar = UIBarStyleDefault;
	self.navigationItem.rightBarButtonItem
    = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered
									   target:self action:@selector(setSettings)] autorelease];		
}

- (void)loadView {
	
	//[self uploadImage];
	
	CGRect screenFrame = [UIScreen mainScreen].bounds;
	self.view = [[[UIView alloc] initWithFrame:screenFrame] autorelease];
	
	CGRect innerFrame = CGRectMake(0, 0,
								   screenFrame.size.width, screenFrame.size.height);
	_innerView = [[[UIView alloc] initWithFrame:innerFrame] autorelease];
	_innerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_innerView];
	
	_scrollView = [[[TTScrollView alloc] autorelease] initWithFrame:screenFrame];
	_scrollView.delegate = self;
	_scrollView.dataSource = self;
	_scrollView.rotateEnabled = NO;
	_scrollView.backgroundColor = [UIColor blackColor];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[_innerView addSubview:_scrollView];
	
	_nextButton = [[[UIBarButtonItem alloc] initWithImage:
				   TTIMAGE(@"bundle://Three20.bundle/images/nextIcon.png")
												   style:UIBarButtonItemStylePlain target:self action:@selector(nextAction)] autorelease];
	_previousButton = [[[UIBarButtonItem alloc] initWithImage:
					   TTIMAGE(@"bundle://Three20.bundle/images/previousIcon.png")
													   style:UIBarButtonItemStylePlain target:self action:@selector(previousAction)] autorelease];
	
	UIBarButtonItem* _clickActionItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction//TTIMAGE(@"UIBarButtonReply.png")
																	 target:self action:@selector(clickActionItem)] autorelease];
	
	UIBarButtonItem* _clickComposeItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose//TTIMAGE(@"UIBarButtonReply.png")
																	   target:self action:@selector(clickComposeItem)] autorelease];
	
	UIBarButtonItem* playButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
									UIBarButtonSystemItemPlay target:self action:@selector(playAction)] autorelease];
	playButton.tag = 1;
	
	UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
						 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	_toolbar = [[UIToolbar alloc] initWithFrame:
				CGRectMake(0, screenFrame.size.height - TT_ROW_HEIGHT,
						   screenFrame.size.width, TT_ROW_HEIGHT)];
	if (self.navigationBarStyle == UIBarStyleDefault) {
		_toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);
	}
	
	
	_toolbar.barStyle = self.navigationBarStyle;
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
	_toolbar.items = [NSArray arrayWithObjects:
					  _clickActionItem, space, _previousButton, space, playButton, space, _nextButton, space, _clickComposeItem, nil];
	
	[_innerView addSubview:_toolbar];
}

- (void)viewDidLoad {

}

- (void)clickComposeItem {
	MockPhoto* p = (MockPhoto *) self.centerPhoto;
	NSString* itemID = p.photoID;
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator openURLAction:[[TTURLAction actionWithURLPath:[@"tt://comments/" stringByAppendingString:itemID]] applyAnimated:YES]];
}

- (void)clickActionItem {
	//NSLog(@"clickActionItem clicked (%@)", albumID);
	
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
											   destructiveButtonTitle:nil
													otherButtonTitles:nil] autorelease];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
	[actionSheet addButtonWithTitle:@"Comments"];
	[actionSheet addButtonWithTitle:@"Make Cover"];
	[actionSheet addButtonWithTitle:@"Delete"];
	[actionSheet addButtonWithTitle:@"Cancel"];
	actionSheet.cancelButtonIndex = 3;
	actionSheet.destructiveButtonIndex = 2; 
	
    [actionSheet showInView:self.view];
}

- (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	MockPhoto* p = (MockPhoto *) self.centerPhoto;
	NSString* itemID = p.photoID;
	
	//NSLog(@"[actionSheet clickedButtonAtIndex] ... (button: %i)", buttonIndex);
	if (buttonIndex == 0) {
		TTNavigator* navigator = [TTNavigator navigator];
		[navigator openURLAction:[[TTURLAction actionWithURLPath:[@"tt://comments/" stringByAppendingString:itemID]] applyAnimated:YES]];
	}
	if (buttonIndex == 1) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		MockPhoto* p = (MockPhoto *) self.centerPhoto;
		NSString* url = p.parentURL;
		NSArray* chunks = [url componentsSeparatedByString: @"/"];
		NSString* albumID = [chunks objectAtIndex:[chunks count] - 1 ];
		//NSLog(@"albumID: %@", albumID);
		MyAlbumUpdater* updater = [[MyAlbumUpdater alloc] initWithItemID:albumID];
		[updater setValue:[[appDelegate.baseURL stringByAppendingString: @"/rest/item/"] stringByAppendingString:p.photoID] param: @"album_cover"];
		[updater update];
		TT_RELEASE_SAFELY(updater);
	}
	if (buttonIndex == 2) {
		UIAlertView *dialog = [[[UIAlertView alloc] init] autorelease];
		[dialog setDelegate:self];
		[dialog setTitle:@"Confirm Deletion"];
		[dialog addButtonWithTitle:@"Cancel"];
		[dialog addButtonWithTitle:@"OK"];
		[dialog show];		
	}
}

//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
- (void)modalView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView isKindOfClass:[UIAlertView class]]) {
		if (buttonIndex == 1) {
			MockPhoto* p = (MockPhoto *) self.centerPhoto;
			NSString* photoID = p.photoID;
			[MyItemDeleter initWithItemID:photoID];	

			[[TTURLCache sharedCache] removeURL:p.parentURL fromDisk:YES];
			
			TTNavigator* navigator = [TTNavigator navigator];
			[navigator removeAllViewControllers];
			[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://thumbs/1"] applyAnimated:YES]];
		}
	}
}

@end
