

#import "MyThumbsViewController.h"
#import "MockPhotoSource.h"
#import "MyAlbum.h"
#import "FlipsideViewController.h"
#import "MyImageUploader.h"

@implementation MyThumbsViewController

- (void)setSettings {
	NSLog(@"setSettings called");
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad {
	self.navigationItem.rightBarButtonItem
    = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered
									   target:self action:@selector(setSettings)] autorelease];	
	
	//[self loadAlbum:@"7180"];
	
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
	
	NSLog(@"[actionSheet clickedButtonAtIndex] ... (button: %i)", buttonIndex);

	if (buttonIndex == 0) {
		[self presentModalViewController:pickerController animated:YES];
	}	
}

#pragma mark UIImagePickerController Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	MockPhotoSource* ps = (MockPhotoSource* ) self.photoSource;
	//NSLog(@"photosource: %@", ps.albumID);
	
	[self dismissModalViewControllerAnimated:YES];
	
	UIImage* picture = [info objectForKey:@"UIImagePickerControllerOriginalImage"];

	MyImageUploader* uploader = [[MyImageUploader alloc] initWithAlbumID:ps.albumID];
	NSString* result = [uploader uploadImage:picture];
	
	NSLog(@"uploading result: %@", result);
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
		
		NSString* photoID = [NSString stringWithString:[entity objectForKey:@"id"]];
		
		MockPhoto* mph = [[[MockPhoto alloc]
						   initWithURL:resize_url
						   smallURL:thumb_url
						   size:CGSizeMake(200, 100)
						   isAlbum:isAlbum
						   albumID:photoID] autorelease];
		
		[album addObject:mph];
	}
	
	self.photoSource = [[MockPhotoSource alloc]
						initWithType:MockPhotoSourceNormal
						albumID:albumID
						title:@"David's Pictures"
						photos:[[NSArray alloc] initWithArray:album]
						photos2:nil];
	
}

@end
