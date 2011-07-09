//
//  MyPhotoViewController.m
//  gallery3
//
//  Created by David Steinberger on 11/15/10.
//  Copyright 2010 -. All rights reserved.
//

#import "MyPhotoViewController.h"
#import "MyViewController.h"
#import "Three20UICommon/UIViewControllerAdditions.h"

#import "AppDelegate.h"
#import "MyViewController.h"
#import "PhotoSource.h"
#import "MyItemDeleter.h"
#import "MyAlbumUpdater.h"
#import "MySettings.h"

@interface MyPhotoViewController ()

- (void)moveToPhoto:(id<TTPhoto>)photo;

@end

@implementation MyPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

	}
	
	return self;
}

- (id)initWithItemID:(NSString*)itemID {
    PhotoSource* photosource = [[PhotoSource alloc] initWithItemID:itemID];
    self.photoSource = photosource;
	TT_RELEASE_SAFELY(photosource);
    
	return [self initWithNibName:nil bundle:nil];
}

- (id)initWithItemID:(NSString*)itemID atIndex:(NSInteger)photoIndex {
	id instance = [self initWithItemID:itemID];
	[self moveToPhotoAtIndex:photoIndex withDelay:NO];
	return instance;
}

- (void) dealloc {	
    [super dealloc];
}

- (void)loadView {
	[super loadView];
	
	CGRect screenFrame = [UIScreen mainScreen].bounds;
	self.view = [[[UIView alloc] initWithFrame:screenFrame] autorelease];
	
	CGRect innerFrame = CGRectMake(0, 0,
								   screenFrame.size.width, screenFrame.size.height);
	_innerView = [[UIView alloc] initWithFrame:innerFrame];
	_innerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_innerView];
	
	_scrollView = [[TTScrollView alloc] initWithFrame:screenFrame];
	_scrollView.delegate = self;
	_scrollView.dataSource = self;
	_scrollView.rotateEnabled = NO;
	_scrollView.backgroundColor = [UIColor blackColor];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[_innerView addSubview:_scrollView];
	
	_nextButton = [[UIBarButtonItem alloc] initWithImage:
				   TTIMAGE(@"bundle://Three20.bundle/images/nextIcon.png")
												   style:UIBarButtonItemStylePlain target:self action:@selector(nextAction)];
	_previousButton = [[UIBarButtonItem alloc] initWithImage:
					   TTIMAGE(@"bundle://Three20.bundle/images/previousIcon.png")
													   style:UIBarButtonItemStylePlain target:self action:@selector(previousAction)];
	
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
	[super viewDidLoad];
}

- (void)clickComposeItem {
	Photo* p = (Photo *) self.centerPhoto;
	NSString* itemID = p.photoID;
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator openURLAction:[[TTURLAction actionWithURLPath:[@"tt://comments/" stringByAppendingString:itemID]] applyAnimated:YES]];
}

- (void)clickActionItem {
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
											   destructiveButtonTitle:nil
													otherButtonTitles:nil] autorelease];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
	[actionSheet addButtonWithTitle:@"Comments"];
	[actionSheet addButtonWithTitle:@"Make Cover"];
	[actionSheet addButtonWithTitle:@"Save to iPhone"];
	[actionSheet addButtonWithTitle:@"Delete"];
	[actionSheet addButtonWithTitle:@"Cancel"];
	actionSheet.cancelButtonIndex = 4;
	actionSheet.destructiveButtonIndex = 3; 
	
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	Photo* p = (Photo *) self.centerPhoto;
	NSString* itemID = p.photoID;
	
	//NSLog(@"[actionSheet clickedButtonAtIndex] ... (button: %i)", buttonIndex);
	if (buttonIndex == 0) {
		TTNavigator* navigator = [TTNavigator navigator];
		[navigator openURLAction:[[TTURLAction actionWithURLPath:[@"tt://comments/" stringByAppendingString:itemID]] applyAnimated:YES]];
	}
	if (buttonIndex == 1) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		Photo* p = (Photo *) self.centerPhoto;
		NSString* url = p.parentURL;
		NSArray* chunks = [url componentsSeparatedByString: @"/"];
		NSString* albumID = [chunks objectAtIndex:[chunks count] - 1 ];

		MyAlbumUpdater* updater = [[MyAlbumUpdater sharedMyAlbumUpdater] initWithItemID:albumID andDelegate:((id<MyViewController>)self.ttPreviousViewController)];
		[updater setValue:[[appDelegate.baseURL stringByAppendingString: @"/rest/item/"] stringByAppendingString:p.photoID] param: @"album_cover"];
		[updater update];

        [self dismissModalViewControllerAnimated:YES];
	}
	if (buttonIndex == 2) {		
		NSString* url  = [_centerPhoto URLForVersion:TTPhotoVersionLarge];		

        // fetch the image from the server
        TTURLRequest *request = [TTURLRequest
                                 requestWithURL:url
                                 delegate:self];
        
        //set http-headers
        [request setValue:GlobalSettings.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        request.cachePolicy = TTURLRequestCachePolicyNone;
        
        TTURLImageResponse *response = [[TTURLImageResponse alloc] init];
        request.response = response;
        TT_RELEASE_SAFELY(response);
        
        [request send];
	}
	if (buttonIndex == 3) {
		UIAlertView *dialog = [[[UIAlertView alloc] init] autorelease];
		dialog.delegate = self;
        dialog.title = @"Confirm Deletion";
        dialog.message = @"Do you really want to delete this photo?";
 		[dialog addButtonWithTitle:@"Cancel"];
		[dialog addButtonWithTitle:@"OK"];
		[dialog show];		
	}
}

- (void)modalView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView isKindOfClass:[UIAlertView class]]) {
		if (buttonIndex == 1) {
			// start the indicator ...
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			[self performSelector:@selector(deleteCurrentItem) withObject:Nil afterDelay:0.05];
		}
	}
}

- (void)deleteCurrentItem {
	Photo* p = (Photo *) self.centerPhoto;
	NSString* photoID = p.photoID;
	[MyItemDeleter initWithItemID:photoID];	
	
	// stop the indicator ...
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [((id<MyViewController>)self.ttPreviousViewController) reloadViewController:YES];
    [self dismissModalViewControllerAnimated:YES];
}

-(void) reload {
	/*TTNavigator* navigator = [TTNavigator navigator];
	[navigator removeAllViewControllers];
	[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://thumbs/1"]];*/
    [super reload];
}

// see TTPhotoViewController
- (void)moveToPhotoAtIndex:(NSInteger)photoIndex withDelay:(BOOL)withDelay {
    _centerPhotoIndex = photoIndex == TT_NULL_PHOTO_INDEX ? 0 : photoIndex;
    [self moveToPhoto:[_photoSource photoAtIndex:_centerPhotoIndex]];
    _delayLoad = withDelay;
}

- (void)moveToPhoto:(id<TTPhoto>)photo {
	id<TTPhoto> previousPhoto = [_centerPhoto autorelease];
	_centerPhoto = [photo retain];
	[self didMoveToPhoto:_centerPhoto fromPhoto:previousPhoto];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLRequestDelegate

/*
 * So far only used to fetch images
 * -> Save them to the camera roll
 */
- (void)requestDidFinishLoad:(TTURLRequest *)request {
	TTURLImageResponse *response = request.response;
	UIImageWriteToSavedPhotosAlbum(response.image, nil, nil, nil);
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
