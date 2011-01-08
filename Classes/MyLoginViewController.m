#import "MyLoginViewController.h"
#import "AppDelegate.h"

#import "MyLoginDataSource.h"
#import "MyLogin.h"

#import "MySettings.h"

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
	}
	
	return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
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
	NSLog(@"here");
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
