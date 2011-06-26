
#import "AppDelegate.h"
#import "MyThumbsViewController.h"
#import "PhotoSource.h"

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

	[super dealloc];
}

- (id)initWithAlbumID:(NSString *)albumID {
	if ((self = [super init])) {
		self.albumID = albumID;
		PhotoSource* photosource = [[PhotoSource alloc] initWithItemID:albumID];
        photosource.photosOnly = NO;
		self.photoSource = photosource;
		TT_RELEASE_SAFELY(photosource);
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
	AddAlbumViewController* addAlbum = [[AddAlbumViewController alloc] initWithParentAlbumID: self.albumID andDelegate:self];
	[self.navigationController pushViewController:addAlbum animated:YES];
	TT_RELEASE_SAFELY(addAlbum);
}

// Handles the modification of an album
- (void)editAlbum:(id)sender {
    UpdateAlbumViewController* updateAlbum = [[UpdateAlbumViewController alloc] initWithAlbumID: self.albumID andDelegate:self];
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
  	NSMutableDictionary* query = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                   self, @"delegate",
                                   self.albumID, @"albumID",
                                   nil] autorelease];
    
    if (buttonIndex == 0) {
        [query setValue:@"UIImagePickerControllerSourceTypeCamera" forKey:@"sourceType"];
	}
    if (buttonIndex == 1) {
        [query setValue:@"UIImagePickerControllerSourceTypeSavedPhotosAlbum" forKey:@"sourceType"];
    }
    if (buttonIndex == 2) {
        return;
    }
    [[TTNavigator navigator] openURLAction:[[[TTURLAction actionWithURLPath:
                                              @"tt://nib/MyUploadViewController"]
                                             applyQuery:query] applyAnimated:YES]];
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

    [((id<MyViewController>)self) reloadViewController:YES];
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
	
    if (_isEmpty) {
        [actionSheet showInView:self.view];
    } else {
        [actionSheet showFromToolbar:self.navigationController.toolbar];   
    }
}


// Reloads the data -> resets the detail-view
- (void)reload {
	[super reload];
}

// Reloads after an action was taken
- (void)reloadViewController:(BOOL)goBack {
    _isInEditingState = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];      
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    if (_isEmpty) {
        goBack = YES;
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
    
    MyThumbsViewController* prev = ((MyThumbsViewController *)self.ttPreviousViewController);
    [self invalidateView];
    [prev invalidateView];
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    TTViewController* viewController;
    if ([viewControllers count] > 1 && goBack) {
        viewController = [viewControllers objectAtIndex:[viewControllers count] - 2];
        [self.navigationController popToViewController:viewController animated:YES];
	}
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self.photoSource
                                   selector:@selector(load) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:2 target:prev.photoSource
                                   selector:@selector(load) userInfo:nil repeats:NO];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)showEmpty:(BOOL)show {        
    /*
     * We expect a tree-resource
     * Should the resource have only 1 object the load was complete and  no children found
     * --> empty album
     */
    if (show) {        
		NSString* title = [_dataSource titleForEmpty];
		NSString* subtitle = @""; //[_dataSource subtitleForEmpty];
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
