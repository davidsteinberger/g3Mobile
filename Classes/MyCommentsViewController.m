
#import "MyCommentsViewController.h"

#import "Three20UICommon/UIViewControllerAdditions.h"

#import "MyCommentsDataSource.h"

#import "MockPhotoSource.h"
#import "AppDelegate.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MyCommentsViewController

@synthesize itemID = _itemID;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.title = @"Comments feed";
    self.variableHeightRows = YES;
  }

  return self;
}

- (id)initWithItemID:(NSString* )itemID {
	self.itemID = itemID;
	return [self initWithNibName:nil bundle:nil];
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_nextButton);
	TT_RELEASE_SAFELY(_previousButton);
	
	TT_RELEASE_SAFELY(_clickComposeItem);
	TT_RELEASE_SAFELY(_clickActionItem);
	
	TT_RELEASE_SAFELY(_innerView);
	TT_RELEASE_SAFELY(_scrollView);
	
	TT_RELEASE_SAFELY(_toolbar);
	TT_RELEASE_SAFELY(_itemID);
	[super dealloc];
}

- (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  self.dataSource = [[[MyCommentsDataSource alloc]
                      initWithSearchQuery:[[appDelegate.baseURL stringByAppendingString: @"/rest/item_comments/"] stringByAppendingString:self.itemID]] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITableViewDelegate>)createDelegate {
  return [[[TTTableViewDragRefreshDelegate alloc] initWithController:self] autorelease];
}

- (void)loadView {
	[super loadView];
	
	
	self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds  
                                                    style:UITableViewStyleGrouped] autorelease];  
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;  
	self.variableHeightRows = YES;  
	self.title = @"Comments";  
	[self.view addSubview:self.tableView];  
	
	
	_clickActionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction//TTIMAGE(@"UIBarButtonReply.png")
																	 target:self action:@selector(clickActionItem)];
	
	_clickComposeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose//TTIMAGE(@"UIBarButtonReply.png")
																	  target:self action:@selector(clickComposeItem)];
	
	UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
						 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	/*NSLog(@"width: %i", self.view.height);
	NSLog(@"height: %i", self.view.width);
	NSLog(@"rheight: %i", TT_ROW_HEIGHT);
	NSLog(@"rwidth: %i", TT_ROW_HEIGHT);
	 */
	_toolbar = [[UIToolbar alloc] initWithFrame:
				CGRectMake(0, self.view.height - TT_ROW_HEIGHT,
						   self.view.width, TT_ROW_HEIGHT)];
	if (self.navigationBarStyle == UIBarStyleDefault) {
		_toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);
	}
	
	_toolbar.barStyle = self.navigationBarStyle;
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
	_toolbar.items = [NSArray arrayWithObjects:
					  space, space, _clickComposeItem, nil];
	
	[self.view addSubview:_toolbar];
}

- (void)clickComposeItem {
	TTPostController*postController = [[TTPostController alloc] init];
	postController.delegate = self; // self must implement the TTPostControllerDelegate protocol
	self.popupViewController = postController;
	postController.superController = self; // assuming self to be the current UIViewController
	[postController showInView:self.view animated:YES];
	[postController release]; 
}

- (void)postController:(TTPostController*)postController didPostText:(NSString *)text withResult:(id)result {
	NSString* itemID = self.itemID;
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	//prepare http post parameter: item, text
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:  
							[[appDelegate.baseURL stringByAppendingString:@"/rest/item/"] stringByAppendingString:itemID] , @"item",  
							text, @"text",
							nil];  
	
	//json-encode & urlencode parameters
	NSString* requestString = [params yajl_JSONString];
	requestString = [@"entity=" stringByAppendingString:[self urlEncodeValue:requestString]];
	
	//create data for http-request body
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	
	//---bring everything together
	
	//create http-request
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[appDelegate.baseURL stringByAppendingString:@"/rest/comments"]]];
	
	//set http-headers
	[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"post" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];	
	
	//set 'post'-method
	[request setHTTPMethod: @"POST"];
	
	//set request body into HTTPBody.
	[request setHTTPBody: requestData];
	
	//Data returned by WebService
	NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil ];
	//NSString *returnString = [[NSString alloc] initWithData:returnData encoding: NSUTF8StringEncoding];
	//NSLog(returnString);
	//[returnString release];
	
	[request release];
	
	[[TTURLCache sharedCache] removeURL:[[appDelegate.baseURL stringByAppendingString: @"/rest/item_comments/"] stringByAppendingString:self.itemID] fromDisk:YES];
	TTNavigator* navigator = [TTNavigator navigator];
	TTURLAction* urlaction = [TTURLAction actionWithURLPath:@""];
	//[navigator openURLAction:[TTURLAction actionWithURLPath: parentURLPath]]];
	
	[[self navigationController] popViewControllerAnimated:YES];
} 


@end

