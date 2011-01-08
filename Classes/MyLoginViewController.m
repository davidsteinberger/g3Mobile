#import "MyLoginViewController.h"
#import "AppDelegate.h"

#import "MyLoginDataSource.h"
#import "MyLogin.h"

#import "MySettings.h"
#import "MyAlbum.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MyLoginViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Settings";
		self.variableHeightRows = YES;
		self.tableViewStyle = UITableViewStyleGrouped;
		
		[[TTNavigator navigator].URLMap from:@"tt://removeAllCache"
					   toObject:self selector:@selector(removeAllCache)];
	}
	
	return self;
}

- (void)removeAllCache {
//	[self dismissModalViewControllerAnimated:NO];
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
															  delegate:self
													 cancelButtonTitle:@"Cancel"
												destructiveButtonTitle:nil
													 otherButtonTitles:@"Really delete all cache?!", nil] autorelease];
	
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
	//[actionSheet addButtonWithTitle:@"Really delete all cache?!"];
	//actionSheet.cancelButtonIndex = 4;
	//actionSheet.destructiveButtonIndex = 3; 
	
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	NSLog(@"[actionSheet clickedButtonAtIndex] ... (button: %i)", buttonIndex);
	
	if (buttonIndex == 0) {
		[MyAlbum updateFinished];
		TTNavigator *navigator = [TTNavigator navigator];
		[navigator removeAllViewControllers];
		[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://thumbs/1"] applyAnimated:YES]];
	}	
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
	[[TTNavigator navigator].URLMap removeURL:@"tt://removeAllCache"];
    TT_RELEASE_SAFELY(_emptyTable);
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
    self.dataSource = [[[MyLoginDataSource alloc] init] autorelease];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showLoading:(BOOL)show {
	//NSLog(@"here");
    /*if (show) {
        self.loadingView = _emptyTable;
    }
    else {
        self.loadingView = nil;
    }*/
	//self.loadingView = nil;
}

/*
- (void)showModel:(BOOL)show {
	NSLog(@"here");
}*/


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSNotifications

- (void)modelDidStartLoad:(id<TTModel>)model {
	
}

- (void)modelDidFinishLoad:(id<TTModel>)model {}

- (void)modelDidCancelLoad:(id<TTModel>)model {}


- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate finishedLogin];
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError *)error {
    TTAlertViewController* alert = [[[TTAlertViewController alloc] initWithTitle:@"Login" message:TTDescriptionForError(error)] autorelease];
    [alert addCancelButtonWithTitle:@"OK" URL:nil];
    [alert showInView:self.view animated:YES];

	[self showLoading:NO];
	[super model:model didFailLoadWithError:error];
}


@end
