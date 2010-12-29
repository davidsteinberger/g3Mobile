
#import "AppDelegate.h"
#import "MyThumbsViewController.h"
#import "MockPhotoSource.h"
#import "MyAlbum.h"
#import "FlipsideViewController.h"
#import "MyImageUploader.h"
#import "MyItemDeleter.h"
#import "AddAlbumViewController.h"
#import "UpdateAlbumViewController.h"

@implementation MyThumbsViewController

@synthesize albumID = _albumID;

- (void)dealloc {
	TT_RELEASE_SAFELY(self->_toolbar);
	TT_RELEASE_SAFELY(self->_clickActionItem);
	TT_RELEASE_SAFELY(self->_pickerController);

	[super dealloc];
}

- (void)setSettings {
	//NSLog(@"setSettings called");
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://login"] applyAnimated:YES]];
}

- (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}

- (void)addAlbum {	
	AddAlbumViewController* addAlbum = [[AddAlbumViewController alloc] initWithParentAlbumID: self.albumID delegate: self];
	[self.navigationController pushViewController:addAlbum animated:YES];
	TT_RELEASE_SAFELY(addAlbum);
}

- (void)updateAlbum {
	UpdateAlbumViewController* updateAlbum = [[UpdateAlbumViewController alloc] initWithAlbumID: self.albumID delegate: self];
	[self.navigationController pushViewController:updateAlbum animated:YES];
	TT_RELEASE_SAFELY(updateAlbum);
}

- (void)viewDidLoad {
	/*
	UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
	[progressView setFrame:CGRectMake(0,0,320,100)];
	[self.view addSubview:progressView];
	*/
	
	MockPhotoSource* ps = (MockPhotoSource* ) self.photoSource;
	
	//show logout only when on root-album
	if ([ps.albumID isEqualToString: @"1"]) {
		self.navigationItem.rightBarButtonItem
		= [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered
										   target:self action:@selector(setSettings)] autorelease];	
		
	}
	
	_clickActionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction//TTIMAGE(@"UIBarButtonReply.png")
																	 target:self action:@selector(clickActionItem)];
	_toolbar = [[UIToolbar alloc] initWithFrame:
				CGRectMake(0, self.view.height - TT_ROW_HEIGHT,
						   self.view.width, TT_ROW_HEIGHT)];
	
	UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
						 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	if (self.navigationBarStyle == UIBarStyleDefault) {
		_toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);
	}
	
	_toolbar.barStyle = self.navigationBarStyle;
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
	_toolbar.items = [NSArray arrayWithObjects:
					  _clickActionItem, space, nil];
	
	[self.view addSubview:_toolbar];
	
	_pickerController = [[UIImagePickerController alloc] init];
	_pickerController.delegate = self;
	if ( [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] == YES) {
		_pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	} else {
		_pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	}
	
}

- (void) clickActionItem {
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
											   destructiveButtonTitle:nil
													otherButtonTitles:nil] autorelease];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
	[actionSheet addButtonWithTitle:@"Upload"];
	[actionSheet addButtonWithTitle:@"Add Album"];
	[actionSheet addButtonWithTitle:@"Change Album"];
	[actionSheet addButtonWithTitle:@"Delete"];
	[actionSheet addButtonWithTitle:@"Cancel"];
	actionSheet.cancelButtonIndex = 4;
	actionSheet.destructiveButtonIndex = 3; 
	
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
		
	//NSLog(@"[actionSheet clickedButtonAtIndex] ... (button: %i)", buttonIndex);
	
	if (buttonIndex == 0) {
		[self presentModalViewController:_pickerController animated:YES];
	}	
	if (buttonIndex == 1) {
		[self addAlbum];
	}
	if (buttonIndex == 2) {
		[self updateAlbum];
	}
	if (buttonIndex == 3) {
		UIAlertView *dialog = [[[UIAlertView alloc] init] autorelease];
		[dialog setDelegate:self];
		[dialog setTitle:@"Confirm Deletion"];
		[dialog addButtonWithTitle:@"Cancel"];
		[dialog addButtonWithTitle:@"OK"];
		[dialog show];		
	}
}

- (void)modalView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView isKindOfClass:[UIAlertView class]]) {
		if (buttonIndex == 1) {
			MockPhotoSource* ps = (MockPhotoSource* ) self.photoSource;
			[MyItemDeleter initWithItemID:ps.albumID];
			//NSLog(@"parentURL: %@", ps.parentURL);
			[[TTURLCache sharedCache] removeURL:ps.parentURL fromDisk:YES];
			
			TTNavigator* navigator = [TTNavigator navigator];
			[navigator removeAllViewControllers];
			[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://thumbs/1"] applyAnimated:YES]];
		}
	}
}

#pragma mark UIImagePickerController Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	MockPhotoSource* ps;
	
	ps = (MockPhotoSource* ) self.photoSource;
	
	[self dismissModalViewControllerAnimated:YES];
	
	UIImage* picture = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	
	MyImageUploader* uploader = [[MyImageUploader alloc] initWithAlbumID:[[[NSString alloc] initWithString:ps.albumID] autorelease] delegate:self];
	[uploader uploadImage:picture];
	TT_RELEASE_SAFELY(uploader);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
}

#pragma mark UINavigationController Methods
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
}

- (void) viewWillAppear: (BOOL) animated
{
	[super viewWillAppear: animated];
}

- (void) viewWillDisappear: (BOOL) animated
{
	[super viewWillDisappear: animated];
} 

- (id)initWithAlbumID:(NSString*)albumID {
	if( self = [super init] )
	{
		self.albumID = albumID;
		[self loadAlbum:albumID];
	}
	return self;
}

- (void)loadAlbum:(NSString* ) albumID {
	//NSLog(@"albumID: %@", albumID); 

	NSMutableArray* album = [[NSMutableArray alloc] init];
	MyAlbum* g3Album = [[MyAlbum alloc] initWithID:albumID];
	
	NSArray *keyArray = [g3Album.array allKeys];
	for (int i=0; i < [keyArray count]; i++) {
		NSDictionary* obj = [g3Album.array objectForKey:[ keyArray objectAtIndex:i]];
		NSDictionary* entity = [obj objectForKey:@"entity"];
		//NSLog(@"iterating over: %@", entity);

		NSString* thumb_url = [entity objectForKey:@"thumb_url_public"];
		if (thumb_url == nil) {
			thumb_url = [entity objectForKey:@"thumb_url"];
			if (thumb_url == nil) {
				thumb_url = @"bundle://empty.png";
			}
		}
		
		NSString* resize_url = [entity objectForKey:@"resize_url_public"];
		if (resize_url == nil) {
			resize_url = [entity objectForKey:@"resize_url"];
			if (resize_url == nil) {
				resize_url = thumb_url;
				if (resize_url == nil) {
					resize_url = @"bundle://empty.png";
				}
			}
		}
		
		BOOL isAlbum;
		if ([(NSString *)[entity objectForKey:@"type"] isEqualToString:@"album"]) {
			isAlbum = YES;
		} else {
			isAlbum = NO;
		}
		
		NSString* parent = [entity objectForKey:@"parent"];
		if (parent == nil) {
			parent = @"1";
		}
		
		NSString* photoID = [entity objectForKey:@"id"];
		if (photoID == nil) {
			photoID = @"1";
		}
		
		id iWidth = [entity objectForKey:@"resize_width"];
		id iHeight = [entity objectForKey:@"resize_height"];
		
		short int width = 100;
		short int height = 100;
		
		if ([iWidth isKindOfClass:[NSString class]] && [iHeight isKindOfClass:[NSString class]]) {
			if ([@"" isEqualToString:iWidth] || [@"" isEqualToString:iHeight]) {
				//NSLog(@"String is empty!!!");
				width = 100;
				height = 100;
			}	
			else if ([iWidth length] > 0 && [iHeight length] > 0 ) {
				width = [iWidth longLongValue];
				height = [iHeight longLongValue];
			}
		}
				
		MockPhoto* mph = [[[MockPhoto alloc]
						   initWithURL:[NSString stringWithString: resize_url]
						   smallURL:[NSString stringWithString: thumb_url]
						   size:CGSizeMake(width, height)
						   isAlbum:isAlbum
						   photoID:[NSString stringWithString: photoID]
						   parentURL:[NSString stringWithString: parent]] autorelease];
		
		[album addObject:mph];
	}
	
	NSString* albumParent = nil;
	NSString* albumTitle = nil;
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if ([g3Album.albumEntity count] > 0) {
		if ([g3Album.albumEntity valueForKey:@"parent"] != nil) {
			albumParent = [g3Album.albumEntity valueForKey:@"parent"];
		} else {
			albumParent = [appDelegate.baseURL stringByAppendingString:@"/rest/item/1"];
		}
		if ([g3Album.albumEntity valueForKey:@"title"] != nil) {
			albumTitle = [g3Album.albumEntity valueForKey:@"title"];
		} else {
			albumTitle = @"";
		}
	} else {		
		albumParent = [appDelegate.baseURL stringByAppendingString:@"/rest/item/1"];
	}
	
	self.photoSource = [[[MockPhotoSource alloc]
						 initWithType:MockPhotoSourceNormal
						 parentURL:[NSString stringWithString: albumParent]
						 albumID:[NSString stringWithString: albumID]
						 title:albumTitle
						 photos:album
						 photos2:nil] autorelease];

	TT_RELEASE_SAFELY(album);
	TT_RELEASE_SAFELY(g3Album);
}

-(void) reload {
	[self updateView];
}

- (void)updateFinished {
	[[TTURLCache sharedCache] removeAll:YES];
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator removeAllViewControllers];
	[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://thumbs/1"] applyAnimated:YES]];
}

@end
