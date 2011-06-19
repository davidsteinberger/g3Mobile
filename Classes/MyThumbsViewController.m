
#import "AppDelegate.h"
#import "MyThumbsViewController.h"
#import "PhotoSource.h"

#import "MyImageUploader.h"
#import "MyItemDeleter.h"
#import "AddAlbumViewController.h"
#import "UpdateAlbumViewController.h"

#import "UIImage+cropping.h"
#import "MyUploadViewController.h"
#import "Three20UI/TTPhotoSource.h"
#import "MyViewController.h"
#import "Three20UICommon/UIViewControllerAdditions.h"
#import "MySettings.h"
#import "UIImage+scaleAndRotate.h"
#import "TTTableViewController+g3.h"
#import "Overlay.h"

@interface MyThumbsViewController ()

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

// Disable all other buttons on the toolbar
- (void)disableToolbarItemsExceptButton:(UIButton*)button;

// Enable all buttons on the toolbar
- (void)enableToolbarItems;

// Sets the default button with default behavior
- (void)setStandartRightBarButtonItem;

@end

@implementation MyThumbsViewController

@synthesize albumID = _albumID;

- (void)dealloc {
    [[RKRequestQueue sharedQueue] cancelAllRequests];
	self.albumID = nil;
	TT_RELEASE_SAFELY(_photoSource);
	TT_RELEASE_SAFELY(self->_pickerController);

	[super dealloc];
}

- (id)initWithAlbumID:(NSString *)albumID {
	if ((self = [super init])) {
		self.albumID = albumID;
		PhotoSource* photosource = [[PhotoSource alloc] initWithItemID:albumID];
        photosource.photosOnly = NO;
		self.photoSource = photosource;
		TT_RELEASE_SAFELY(photosource);
        
        _pickerController = [[UIImagePickerController alloc] init];
        _pickerController.delegate = self;
	}
	return self;
}


- (void)updateTableLayout { 
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(TTBarsHeight(), 0, 0, 0);
} 

- (void)loadView {
    [super loadView];
    
    self.hidesBottomBarWhenPushed = NO;
    
    self.statusBarStyle = UIBarStyleDefault;
    self.navigationBarStyle = UIBarStyleBlack;
    self.navigationBarTintColor = nil;
    [self setWantsFullScreenLayout:YES];
}


- (void)modelDidFinishLoad:(id <TTModel>)model {
	self.title = self.photoSource.title;
	[super modelDidFinishLoad:model];
}

// Shows the Login page with all the settings
- (void)setSettings {
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://login"] applyAnimated:YES]];
}

- (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}

// Handles the creation of a new album
- (void)createAlbum:(id)sender {	
	AddAlbumViewController* addAlbum = [[AddAlbumViewController alloc] initWithParentAlbumID: self.albumID];
	[self.navigationController pushViewController:addAlbum animated:YES];
	TT_RELEASE_SAFELY(addAlbum);
}

// Handles the modification of an album
- (void)editAlbum:(id)sender {
    UpdateAlbumViewController* updateAlbum = [[UpdateAlbumViewController alloc] initWithAlbumID: self.albumID];
    [self.navigationController pushViewController:updateAlbum animated:YES];	
    TT_RELEASE_SAFELY(updateAlbum);
}

- (void)viewDidLoad {
	[super viewDidLoad];

    if ([self.albumID isEqual:@"1"]) {
		self.navigationItem.leftBarButtonItem
        = [[[UIBarButtonItem alloc] initWithTitle:@"Settings" style:
            UIBarButtonItemStyleBordered
                                           target:self action:@selector(setSettings)
            ] autorelease];
	}
    
	[self setStandartRightBarButtonItem];
    
    self.navigationController.toolbar.barStyle = self.navigationBarStyle;
    [self.navigationController.toolbar sizeToFit];
    
    NSArray* toolbarItems = [Overlay buildThumbViewToolbarWithDelegate:self];
	[self setToolbarItems:toolbarItems animated:YES]; 
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];      
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    //self.tableView.backgroundColor = [UIColor blackColor];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  	if (buttonIndex == 0) {
		if ( [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] == YES) {
            _pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            _pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
        [self presentModalViewController:_pickerController animated:YES];
	}
    if (buttonIndex == 1) {
        _pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentModalViewController:_pickerController animated:YES];
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


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark private

// Show/hide details of album above the first album
- (void)toggleEditing:(id)sender {
    _isInEditingState = !_isInEditingState;
    
    if (_isInEditingState) {
        [self.navigationController setToolbarHidden:NO animated:YES];
    } else {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

// Confirms via dialog that the current item should be deleted
- (void)deleteCurrentItem:(id)sender {
	UIAlertView *dialog = [[[UIAlertView alloc] init] autorelease];
	[dialog setDelegate:self];
	[dialog setTitle:@"Confirm Deletion"];
	[dialog addButtonWithTitle:@"Cancel"];
	[dialog addButtonWithTitle:@"OK"];
	[dialog show];
}

- (void)deleteCurrentItem {
	PhotoSource* ps = (PhotoSource* ) self.photoSource;
	[MyItemDeleter initWithItemID:ps.albumID];
	
    // stop the indicator ...
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [((id<MyViewController>)self) reloadViewController:NO];
}

- (void)disableToolbarItemsExceptButton:(UIButton*)button {
    for (UIBarButtonItem* item in self.toolbarItems) {
        if (item.customView != button) {
            item.enabled = NO;   
        }
    }
}

- (void)enableToolbarItems {
    for (UIBarButtonItem* item in self.toolbarItems) {
        item.enabled = YES;   
    }
}

- (void)setStandartRightBarButtonItem {
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(toggleEditing:)] autorelease];
}


- (void)uploadImage:(id)sender {
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil] autorelease];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
	[actionSheet addButtonWithTitle:@"Camera"];
	[actionSheet addButtonWithTitle:@"Library"];
	[actionSheet addButtonWithTitle:@"Cancel"];
	actionSheet.cancelButtonIndex = 2;
	
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIImagePickerController Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	PhotoSource* ps;
	ps = (PhotoSource* ) self.photoSource;
	
	// get high-resolution picture (used for upload)
	UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage* finalImage = [image scaleAndRotateImageToMaxResolution:1024];
    
	// get screenshot (used for confirmation-dialog)
    UIImage* screenshot = finalImage;
    
	// prepare params
	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
							self, @"delegate",
							finalImage, @"image",
							screenshot, @"screenShot",
							ps.albumID, @"albumID",
							nil];
	
	[[TTNavigator navigator] openURLAction:[[[TTURLAction actionWithURLPath:@"tt://nib/MyUploadViewController"]
											applyQuery:params] applyAnimated:YES]];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
}


#pragma mark UINavigationController Methods
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {	
}

// Reloads the data -> resets the detail-view
- (void)reload {
    PhotoSource* photosource = [[PhotoSource alloc] initWithItemID:self.albumID];
    photosource.photosOnly = NO;
    self.photoSource = photosource;
    TT_RELEASE_SAFELY(photosource);
	[super reload];
}

// Reloads after an action was taken
- (void)reloadViewController:(BOOL)goBack {
    _isInEditingState = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];      
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    self->_goBack = goBack;
    
    if (_isEmpty) {
        self->_goBack = YES;
    }
    
    RKObjectLoaderTTModel* model = (RKObjectLoaderTTModel *)self.photoSource;
    RKMTree *tree = (RKMTree *)[model.objects objectAtIndex:0];
    RKMEntity *entity = [tree root];
    
    if (![entity.thumb_url_public isEqualToString:@""] && entity.thumb_url_public != nil) {
        [[TTURLCache sharedCache] removeURL:entity.thumb_url_public fromDisk:YES];
    }
    if (![entity.thumb_url isEqualToString:@""] && entity.thumb_url != nil) {
        [[TTURLCache sharedCache] removeURL:entity.thumb_url fromDisk:YES];
    }
    
    [((PhotoSource*)self.photoSource) load:TTURLRequestCachePolicyDefault more:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self  
                                   selector:@selector(finishUp) userInfo:nil repeats:NO];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)finishUp {
    PhotoSource* photosource = [[PhotoSource alloc] initWithItemID:self.albumID];
    photosource.photosOnly = NO;
    self.photoSource = photosource;
    TT_RELEASE_SAFELY(photosource);
    
    [((MyThumbsViewController*)self.ttPreviousViewController) invalidateView];
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    TTViewController* viewController;
    if ([viewControllers count] > 1 && self->_goBack) {
        viewController = [viewControllers objectAtIndex:[viewControllers count] - 2];
        [self.navigationController popToViewController:viewController animated:YES];
        [(TTNavigator*)[TTNavigator navigator] performSelector:@selector(reload) withObject:nil afterDelay:1];
	}
}

- (void)showEmpty:(BOOL)show {    
    RKObjectLoaderTTModel *model = (RKObjectLoaderTTModel *)self.photoSource;
    NSArray* objects = model.objects;
    
    /*
     * We expect a tree-resource
     * Should the resource have only 1 object the load was complete and  no children found
     * --> empty album
     */
    if ([objects count] == 1 && show) {        
		NSString* title = [_dataSource titleForEmpty];
		NSString* subtitle = [_dataSource subtitleForEmpty];
		UIImage* image = [_dataSource imageForEmpty];
        
		if (title.length || subtitle.length || image) {
			TTErrorView* errorView = [[[TTErrorView alloc] initWithTitle:title
																subtitle:subtitle
																   image:nil] autorelease];
			errorView.backgroundColor = _tableView.backgroundColor;
			
			TTView* buttonMenu = [((TTTableViewController*)self) buildOverlayMenu];
			[errorView addSubview:buttonMenu];
			[errorView bringSubviewToFront:buttonMenu];
            
			self.emptyView = errorView;
            self.navigationItem.rightBarButtonItem = nil;
            self->_isEmpty = YES;
		} else {
			self.emptyView = nil;
            self->_isEmpty = NO;
		}
		_tableView.dataSource = nil;
		[_tableView reloadData];
	} else {
		self.emptyView = nil;
	}
}


@end
