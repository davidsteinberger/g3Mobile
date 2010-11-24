#import "MyLoginViewController.h"
#import "AppDelegate.h"

#import "MyLoginDataSource.h"
#import "MyLogin.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MyLoginViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id) init {
  if (self = [super init]) {
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
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
    [super loadView];
	
    // disable scrolling after the table view is created
    self.tableView.scrollEnabled = NO;
    
	self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds  
												   style:UITableViewStyleGrouped] autorelease];  
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;  
	self.variableHeightRows = YES;  
	self.title = @"Login";  
	[self.view addSubview:self.tableView];
	
    // Create an empty table view a activity label to better update the table
    _emptyTable = [[UITableView alloc] initWithFrame:self.tableView.frame style:UITableViewStyleGrouped];
    TTTableActivityItem *activityCell = [TTTableActivityItem itemWithText:@"Logging in"];
    _emptyTable.rowHeight = 160;
    _emptyTable.backgroundColor = [UIColor clearColor];
    _emptyTable.dataSource = [[TTListDataSource dataSourceWithItems:[NSArray arrayWithObject:activityCell]] retain];
    _emptyTable.scrollEnabled = NO;
	
	//NSLog(@"test for model %@", [self.model getChallenge]);
    
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
    if (show) {
        self.loadingView = _emptyTable;
    }
    else {
        self.loadingView = nil;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSNotifications


- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    [[[TTNavigator navigator] rootViewController] dismissModalViewControllerAnimated:NO];

	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	MyLogin* settings = object;
	appDelegate.baseURL = settings.baseURL;
	appDelegate.user = settings.username;
	appDelegate.password = settings.password;
	appDelegate.challenge = settings.challenge;
	
	[appDelegate finishedLogin];
	
    [super model:model didUpdateObject:object atIndexPath:indexPath];
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError *)error {
    //id userInfo = [error userInfo];
    TTAlertViewController* alert = [[[TTAlertViewController alloc] initWithTitle:@"Login" message:TTDescriptionForError(error)] autorelease];
    [alert addCancelButtonWithTitle:@"OK" URL:nil];
    [alert showInView:self.view animated:YES];

	[self showLoading:NO];
	[super model:model didFailLoadWithError:error];
}


@end
