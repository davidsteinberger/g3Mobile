//
//  AddAlbumViewController.m
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import "extThree20JSON/extThree20JSON.h"

#import "AppDelegate.h"
#import "MySettings.h"
#import "MyImageUploader.h"
#import "MyAlbum.h"

#import "AddAlbumViewController.h"


@implementation AddAlbumViewController

@synthesize parentAlbumID = _parentAlbumID;
@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Add Album";
		self.navigationItem.backBarButtonItem =
		[[[UIBarButtonItem alloc] initWithTitle:@"Album" style:UIBarButtonItemStyleBordered
										 target:nil action:nil] autorelease];
		
		self.tableViewStyle = UITableViewStyleGrouped;
	}
	return self;
}

- (id)initWithParentAlbumID: (NSString* )albumID delegate: (MyThumbsViewController *)delegate {
	self.parentAlbumID = albumID;	
	self.delegate = delegate;

	return [self initWithNibName:nil bundle: nil];
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_parentAlbumID);
	TT_RELEASE_SAFELY(_albumName);
	TT_RELEASE_SAFELY(_albumTitle);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)createModel {
	_albumName = [[UITextField alloc] init];
	_albumName.placeholder = @"My Album";
	_albumName.delegate = self;
	//_albumName.text = @"Name";
	_albumName.returnKeyType = UIReturnKeyNext;
	
	TTTableControlItem* cAlbumName = [TTTableControlItem itemWithCaption:@"Name"
															   control:_albumName];

	_albumTitle = [[UITextField alloc] init];
	_albumTitle.placeholder = @"My Title";
	_albumTitle.delegate = self;
	_albumTitle.returnKeyType = UIReturnKeyGo;
	//_albumTitle.text = @"Title";
	
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
		
		[self addAlbum];
    }
    return YES;
}

#pragma mark -
#pragma mark helpers

- (void)addAlbum {	
	NSString *url = [[GlobalSettings.baseURL stringByAppendingString:@"/rest/item/"] stringByAppendingString:self.parentAlbumID];
	
	TTURLRequest* request = [TTURLRequest
                             requestWithURL: url
                             delegate: self];
	
	//set http-headers
	[request setValue:GlobalSettings.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"post" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];	
	
	//set 'post'-method
	request.httpMethod = @"POST";
	
	// don't cache
	request.cacheExpirationAge = 0;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:    
							@"album", @"type",
							_albumName.text, @"name",
							_albumTitle.text, @"title",
							nil];  
	
	//json-encode & urlencode parameters
	NSString* requestString = [params yajl_JSONString];
	requestString = [@"entity=" stringByAppendingString:[self urlEncodeValue:requestString]];
	
	request.httpBody = [requestString dataUsingEncoding:NSUTF8StringEncoding];
	
	request.userInfo = @"addAlbum";
	
	TTURLJSONResponse* response = [[TTURLJSONResponse alloc] init];
    request.response = response;
	TT_RELEASE_SAFELY(response);
	
	[request send];
}


- (void)requestDidFinishLoad:(TTURLRequest*)request {
	if ([request.userInfo isEqual:@"addAlbum"]) {
		TTURLJSONResponse* response = request.response;
		NSString* url = [response.rootObject objectForKey:@"url"];

		NSArray* chunks = [url componentsSeparatedByString: @"/"];
		NSString* newAlbumID = [chunks objectAtIndex:[chunks count] - 1 ];
		
		MyImageUploader* uploader = [[MyImageUploader alloc] initWithAlbumID:[[[NSString alloc] initWithString:newAlbumID] autorelease] delegate:nil];
		[uploader uploadImage:nil withDescription:@"to_be_deleted"];
		TT_RELEASE_SAFELY(uploader);
		
		[MyAlbum updateFinishedWithItemURL:[[GlobalSettings.baseURL stringByAppendingString: @"/rest/item/"] stringByAppendingString:self.parentAlbumID] ];
		
		int index = [[self.navigationController viewControllers] count] - 3;
		if (index >= 0) {
			[self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:index] animated:YES];
		} else {
			TTNavigator* navigator = [TTNavigator navigator];
			[navigator removeAllViewControllers];
			[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://thumbs/1"] applyAnimated:YES]];
		}
	}
}

- (NSString *)urlEncodeValue:(NSString *)str {
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}

@end
