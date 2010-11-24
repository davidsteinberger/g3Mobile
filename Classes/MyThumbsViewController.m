
#import "AppDelegate.h"
#import "MyThumbsViewController.h"
#import "MockPhotoSource.h"
#import "MyAlbum.h"
#import "FlipsideViewController.h"
#import "MyImageUploader.h"
#import "MyItemDeleter.h"

@implementation MyThumbsViewController

- (void)setSettings {
	//NSLog(@"setSettings called");
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://login"]];
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad {

	MockPhotoSource* ps = (MockPhotoSource* ) self.photoSource;

	//show logout only when on root-album
	if ([ps.albumID isEqualToString: @"1"]) {
		self.navigationItem.rightBarButtonItem
		= [[[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered
										   target:self action:@selector(setSettings)] autorelease];	
		
	} ;
	
	_clickActionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction//TTIMAGE(@"UIBarButtonReply.png")
																	 target:self action:@selector(clickActionItem)];
	UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
						 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	_toolbar = [[UIToolbar alloc] initWithFrame:
				CGRectMake(0, self.view.height - TT_ROW_HEIGHT,
						   self.view.width, TT_ROW_HEIGHT)];
	if (self.navigationBarStyle == UIBarStyleDefault) {
		_toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);
	}
	
	_toolbar.barStyle = self.navigationBarStyle;
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
	_toolbar.items = [NSArray arrayWithObjects:
					  _clickActionItem, space, nil];
	
	[self.view addSubview:_toolbar];
	
	pickerController = [[UIImagePickerController alloc] init];
	pickerController.allowsImageEditing = NO;
	pickerController.delegate = self;
	if ( [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] == YES) {
		pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	} else {
		pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	}

}

- (void) clickActionItem {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
											   destructiveButtonTitle:nil
													otherButtonTitles:nil];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
	[actionSheet addButtonWithTitle:@"Upload"];
	[actionSheet addButtonWithTitle:@"Delete"];
	[actionSheet addButtonWithTitle:@"Cancel"];
	actionSheet.cancelButtonIndex = 2;
	actionSheet.destructiveButtonIndex = 1; 
	
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	//NSLog(@"[actionSheet clickedButtonAtIndex] ... (button: %i)", buttonIndex);

	if (buttonIndex == 0) {
		[self presentModalViewController:pickerController animated:YES];
	}	
	if (buttonIndex == 1) {
		UIAlertView *dialog = [[UIAlertView alloc] init];
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
			AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
			MockPhotoSource* ps = (MockPhotoSource* ) self.photoSource;
			
			NSString* url = [appDelegate.baseURL stringByAppendingString:@"/rest/item/"];
			url = [url stringByAppendingString:ps.albumID];

			[MyItemDeleter initWithItemID:ps.albumID];
			//NSLog(@"parentURL: %@", ps.parentURL);
			[[TTURLCache sharedCache] removeURL:ps.parentURL fromDisk:YES];
			
			TTNavigator* navigator = [TTNavigator navigator];
			[navigator removeAllViewControllers];
			[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://thumbs/1"] applyAnimated:YES]];
		}
	}
    [alertView release];
}

#pragma mark UIImagePickerController Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	MockPhotoSource* ps = (MockPhotoSource* ) self.photoSource;
	//NSLog(@"photosource: %@", ps.albumID);
	
	[self dismissModalViewControllerAnimated:YES];
	
	UIImage* picture = [info objectForKey:@"UIImagePickerControllerOriginalImage"];

	MyImageUploader* uploader = [[MyImageUploader alloc] initWithAlbumID:ps.albumID];
	NSString* result = [uploader uploadImage:picture];
	
	//NSLog(@"uploading result: %@", result);

	// force a reload (yes it's a hack ;))
	[self loadAlbum:ps.albumID];
}

- (void) viewWillAppear: (BOOL) animated
{
	[super viewWillAppear: animated];
	//[self.navigationController setToolbarHidden: NO animated: animated];
}

- (void) viewWillDisappear: (BOOL) animated
{
	[super viewWillDisappear: animated];
	//[self.navigationController setToolbarHidden: YES animated: animated];
} 

- (id)initWithAlbumID:(NSString*)albumID {
	if( self = [super init] )
	{
		[self loadAlbum:albumID];
	}
	return self;
}

- (void)loadAlbum:(NSString* ) albumID {
	
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
		}
		
		NSString* resize_url = [entity objectForKey:@"resize_url_public"];
		if (resize_url == nil) {
			resize_url = [entity objectForKey:@"resize_url"];
		}
		
		BOOL isAlbum;
		if ([(NSString *)[entity objectForKey:@"type"] isEqualToString:@"album"]) {
			isAlbum = YES;
		} else {
			isAlbum = NO;
		}
		
		NSString* parent = [entity objectForKey:@"parent"];
		
		NSString* photoID = [NSString stringWithString:[entity objectForKey:@"id"]];
		
		MockPhoto* mph = [[[MockPhoto alloc]
						   initWithURL:resize_url
						   smallURL:thumb_url
						   size:CGSizeMake(200, 100)
						   isAlbum:isAlbum
						   albumID:photoID
						   parentURL:parent] autorelease];
		
		[album addObject:mph];
	}
	
	
	NSString* albumParent = [g3Album.albumEntity objectForKey:@"parent"];
	if (albumParent == nil) {
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		albumParent = [appDelegate.baseURL stringByAppendingString:@"/rest/item/1"];
	}
	
	self.photoSource = [[MockPhotoSource alloc]
						initWithType:MockPhotoSourceNormal
						parentURL:albumParent
						albumID:albumID
						title:@"David's Pictures"
						photos:[[NSArray alloc] initWithArray:album]
						photos2:nil];
	
}

@end
