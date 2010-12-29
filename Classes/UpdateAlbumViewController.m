//
//  AddAlbumViewController.m
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import "NSObject+YAJL.h"

#import "AppDelegate.h"
#import "MyImageUploader.h"

#import "UpdateAlbumViewController.h"


@implementation UpdateAlbumViewController

@synthesize albumID = _albumID;
@synthesize entity = _entity;
@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Update Album";
		self.navigationItem.backBarButtonItem =
		[[[UIBarButtonItem alloc] initWithTitle:@"Album" style:UIBarButtonItemStyleBordered
										 target:nil action:nil] autorelease];
		
		self.tableViewStyle = UITableViewStyleGrouped;
	}
	return self;
}

- (id)initWithAlbumID: (NSString* )albumID delegate: (MyThumbsViewController *)delegate {
	self.albumID = albumID;
	self.delegate = delegate;
	
	return [self initWithNibName:nil bundle: nil];
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_albumID);
	TT_RELEASE_SAFELY(_entity);
	TT_RELEASE_SAFELY(_albumName);
	TT_RELEASE_SAFELY(_albumTitle);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)createModel {
	[self loadAlbum];
	_albumName = [[UITextField alloc] init];
	_albumName.placeholder = @"New Name";
	_albumName.delegate = self;
	_albumName.text = [self.entity objectForKey:@"name"];
	_albumName.returnKeyType = UIReturnKeyNext;
	
	TTTableControlItem* cAlbumName = [TTTableControlItem itemWithCaption:@"Name"
															   control:_albumName];

	_albumTitle = [[UITextField alloc] init];
	_albumTitle.placeholder = @"New Title";
	_albumTitle.delegate = self;
	_albumTitle.returnKeyType = UIReturnKeyGo;
	_albumTitle.text = [self.entity objectForKey:@"title"];
	
	TTTableControlItem* cAlbumTitle = [TTTableControlItem itemWithCaption:@"Title"
																 control:_albumTitle];
	
	self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
					   @"",
					   cAlbumName,
					   cAlbumTitle,
					   nil];	
	[_albumName becomeFirstResponder];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
		[_albumTitle becomeFirstResponder];
    }
    else {
		[_albumTitle resignFirstResponder];
		
		[self updateAlbum];
    }
    return YES;
}

#pragma mark -
#pragma mark helpers

- (void) loadAlbum {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	//create http-request
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[[appDelegate.baseURL stringByAppendingString:@"/rest/item/"] stringByAppendingString:self.albumID]]];
	
	//set http-headers
	[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];	
	
	//set 'post'-method
	[request setHTTPMethod: @"GET"];
	
	NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil ];
	
	NSDictionary* arrayFromData = [returnData yajl_JSON];
	NSDictionary* entity = [arrayFromData objectForKey:@"entity"];
	
	if ((NSNull*)entity != [NSNull null]) {
		self.entity = entity;
	}
	
	TT_RELEASE_SAFELY(request);
}

- (void)updateAlbum {
	//NSLog(@"Add Album for albumID: %@", self.albumID);
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	//prepare http post parameter: item, text
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:    
							@"album", @"type",
							_albumName.text, @"name",
							_albumTitle.text, @"title",
							nil];  
	
	//json-encode & urlencode parameters
	NSString* requestString = [params yajl_JSONString];
	requestString = [@"entity=" stringByAppendingString:[self urlEncodeValue:requestString]];
	
	//create data for http-request body
	NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	
	//---bring everything together
	
	//create http-request
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[[appDelegate.baseURL stringByAppendingString:@"/rest/item/"] stringByAppendingString:self.albumID]]];
	
	//set http-headers
	[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"put" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];	
	
	//set 'post'-method
	[request setHTTPMethod: @"POST"];
	
	//set request body into HTTPBody.
	[request setHTTPBody: requestData];
	
	[NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil ];
	
	[request release];
	
	[self.delegate updateFinished];
}

- (NSString *)urlEncodeValue:(NSString *)str {
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}

@end
