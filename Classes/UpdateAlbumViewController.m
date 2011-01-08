//
//  AddAlbumViewController.m
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import "extThree20JSON/extThree20JSON.h"

#import "MySettings.h"

#import "AppDelegate.h"
#import "MyAlbum.h"

#import "UpdateAlbumViewController.h"


@implementation UpdateAlbumViewController

@synthesize albumID = _albumID;
@synthesize entity = _entity;

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

- (id)initWithAlbumID: (NSString* )albumID {
	self.albumID = albumID;
	
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

- (void)loadAlbum {
	NSString *url = [[GlobalSettings.baseURL stringByAppendingString:@"/rest/item/"] stringByAppendingString:self.albumID];
	TTURLRequest* request = [TTURLRequest
                             requestWithURL: url
                             delegate: self];
	
	//set http-headers
	[request setValue:GlobalSettings.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];	
	
	//set 'post'-method
	request.httpMethod = @"GET";
	
	// don't cache
	request.cacheExpirationAge = 0;
		
	TTURLJSONResponse* response = [[TTURLJSONResponse alloc] init];
    request.response = response;
	TT_RELEASE_SAFELY(response);
	
	request.userInfo = @"loadAlbum";
	[request send];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
	if ([request.userInfo isEqual:@"loadAlbum"]) {
		TTURLJSONResponse* response = request.response;
		NSMutableArray* feed = [response.rootObject objectForKey:@"entity"];
		
		if ((NSNull*)feed != [NSNull null]) {
			self.entity = feed;
		}
	
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
		
		[super modelDidFinishLoad:self];
	}
	if ([request.userInfo isEqual:@"updateAlbum"]) {
		[MyAlbum updateFinishedWithItemURL:[[GlobalSettings.baseURL stringByAppendingString:@"/rest/item/"] stringByAppendingString:self.albumID]];	
		[MyAlbum updateFinishedWithItemURL:[self.entity valueForKey:@"parent"]];
		
		[self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 3] animated:YES];
	}

}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
	//NSLog(@"error: %@", error);
}


- (void)updateAlbum {
	NSString *url = [[GlobalSettings.baseURL stringByAppendingString:@"/rest/item/"] stringByAppendingString:self.albumID];

	TTURLRequest* request = [TTURLRequest
                             requestWithURL: url
                             delegate: self];
	
	//set http-headers
	[request setValue:GlobalSettings.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"put" forHTTPHeaderField:@"X-Gallery-Request-Method"];
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
	
	request.userInfo = @"updateAlbum";
	
	[request send];	
}

- (NSString *)urlEncodeValue:(NSString *)str {
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}

@end
