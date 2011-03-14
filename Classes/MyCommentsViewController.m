
#import "MyCommentsViewController.h"

#import "Three20UICommon/UIViewControllerAdditions.h"
#import "NSObject+YAJL.h"

#import "MyCommentsDataSource.h"

#import "PhotoSource.h"
#import "AppDelegate.h"

static CGFloat kMargin  = 1;
static CGFloat kPadding = 5;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MyCommentsViewController

@synthesize itemID = _itemID;

- (id)initWithItemID:(NSString* )itemID {
	self = [super init];
	self.itemID = itemID;
	self.variableHeightRows = YES;

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
}

- (void)dealloc {
	self.itemID = nil;
	TT_RELEASE_SAFELY(_textBar);
	TT_RELEASE_SAFELY(_textEditor);
	TT_RELEASE_SAFELY(_clickComposeItem);
	TT_RELEASE_SAFELY(_clickActionItem);
	TT_RELEASE_SAFELY(_toolbar);
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
	MyCommentsDataSource* ds = [[MyCommentsDataSource alloc] initWithSearchQuery:
					   [[appDelegate.baseURL stringByAppendingString: @"/rest/item_comments/"] stringByAppendingString:self.itemID]];
	self.dataSource = ds;
	TT_RELEASE_SAFELY(ds);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITableViewDelegate>)createDelegate {
  return [[[TTTableViewDragRefreshDelegate alloc] initWithController:self] autorelease];
}

- (void)loadView {
	[super loadView];
	
	UIBarButtonItem *rightButton = [[[UIBarButtonItem alloc]
									 initWithTitle:@"Edit"
									 style:UIBarButtonSystemItemEdit
									 target:self
									 action:@selector(toggleEdit)]
									autorelease];
	self.navigationItem.rightBarButtonItem = rightButton;	
	
	self.variableHeightRows = YES;  
	self.title = @"Comments";   
	
	_clickActionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction//TTIMAGE(@"UIBarButtonReply.png")
																	 target:self action:@selector(clickActionItem)];
	
	_clickComposeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose//TTIMAGE(@"UIBarButtonReply.png")
																	  target:self action:@selector(clickComposeItem)];
	
	
	// write a comment section
	CGRect viewFrame = CGRectMake(0, self.view.height - TT_ROW_HEIGHT,
								  self.view.width, TT_ROW_HEIGHT);
	CGSize screenSize = TTScreenBounds().size;
	
	_textBar = [[TTView alloc] init];
	_textBar.frame = viewFrame;
	_textBar.style = TTSTYLE(textBar);
	[self.view addSubview:_textBar];
	
	_textEditor = [[TTTextEditor alloc] init];
	[_textBar addSubview:_textEditor];
	
	_textEditor.text = @"Write a Comment ...";
    _textEditor.delegate = self;
    _textEditor.style = TTSTYLE(textBarTextField);
    _textEditor.backgroundColor = [UIColor clearColor];
    _textEditor.autoresizesToText = NO;
    _textEditor.font = [UIFont systemFontOfSize:16];
	_textEditor.textColor = [UIColor lightGrayColor];
	_textEditor.frame = CGRectMake(kPadding, kMargin,screenSize.width - kPadding, 0);
	[_textEditor sizeToFit];
}

- (void)clickComposeItem {
	TTPostController*postController = [[TTPostController alloc] init];
	postController.delegate = self; // self must implement the TTPostControllerDelegate protocol
	self.popupViewController = postController;
	postController.superController = self; // assuming self to be the current UIViewController
	[postController showInView:self.view animated:YES];
	[postController release]; 
}


#pragma mark -
#pragma mark TTTextEditorDelegate

- (BOOL)textEditorShouldBeginEditing:(TTTextEditor*)textEditor {
	//[_textEditor resignFirstResponder];
	[self textEditorDidEndEditing:textEditor];
	[self clickComposeItem];
	return NO;
}

- (BOOL)textEditorShouldEndEditing:(TTTextEditor*)textEditor {
	return YES;
}

- (void)textEditorDidBeginEditing:(TTTextEditor*)textEditor {
	
}

- (void)textEditorDidEndEditing:(TTTextEditor*)textEditor {
	
}

- (BOOL) textEditor: (TTTextEditor*)textEditor
    shouldChangeTextInRange: (NSRange)range
            replacementText: (NSString*)replacementText {
	return NO;
}

- (void)textEditorDidChange:(TTTextEditor*)textEditor {
	
}

- (BOOL)textEditor:(TTTextEditor*)textEditor shouldResizeBy:(CGFloat)height {
	return NO;
}

- (BOOL)textEditorShouldReturn:(TTTextEditor*)textEditor {
	return YES;
}

#pragma mark -
#pragma mark TTPostControllerDelegate

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
	
	[NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil ];
	
	[request release];
	
	[[TTURLCache sharedCache] removeURL:[[appDelegate.baseURL stringByAppendingString: @"/rest/item_comments/"] stringByAppendingString:self.itemID] fromDisk:YES];
		
	[[self navigationController] popViewControllerAnimated:YES];
} 

- (void)toggleEdit {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    NSString *label = self.tableView.editing == YES ? @"Done" : @"Edit";
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithTitle:label
											   style:UIBarButtonSystemItemEdit
											   target:self
											   action:@selector(toggleEdit)]
											   autorelease];
}

@end

