//
//  AddAlbumViewController.m
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import "extThree20JSON/NSObject+YAJL.h"
#import "extThree20JSON/extThree20JSON.h"

#import "AppDelegate.h"
#import "MySettings.h"
#import "MyImageUploader.h"
#import "MyAlbum.h"

#import "AddAlbumViewController.h"
#import "MyViewController.h"

@implementation AddAlbumViewController

@synthesize parentAlbumID = _parentAlbumID;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.title = @"Add Album";
		self.navigationItem.backBarButtonItem =
		[[[UIBarButtonItem alloc] initWithTitle:@"Album" style:UIBarButtonItemStyleBordered
										 target:nil action:nil] autorelease];
		
		self.tableViewStyle = UITableViewStyleGrouped;
	}
	return self;
}

- (id)initWithParentAlbumID: (NSString* )albumID {
	self.parentAlbumID = albumID;	

	return [self initWithNibName:nil bundle: nil];
}

- (void)dealloc {
	self.parentAlbumID = nil;
	TT_RELEASE_SAFELY(_parentAlbumID);
	TT_RELEASE_SAFELY(_albumTitle);
	TT_RELEASE_SAFELY(_description);
	TT_RELEASE_SAFELY(_internetAddress);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)createModel {	
	_albumTitle = [[UITextField alloc] init];
	_albumTitle.placeholder = @"Title";
	_albumTitle.delegate = self;
	_albumTitle.returnKeyType = UIReturnKeyGo;
	
	TTTableControlItem* cAlbumName = [TTTableControlItem itemWithCaption:@"Title"
															   control:_albumTitle];

	_description = [[UITextField alloc] init];
	_description.placeholder = @"Description";
	_description.delegate = self;
	_description.returnKeyType = UIReturnKeyGo;

	TTTableControlItem* cAlbumTitle = [TTTableControlItem itemWithCaption:@"Description"
																 control:_description];
	
	_internetAddress = [[UITextField alloc] init];
	_internetAddress.placeholder = @"Address";
	_internetAddress.delegate = self;
	_internetAddress.returnKeyType = UIReturnKeyGo;
	
	TTTableControlItem* cInternetAddress = [TTTableControlItem itemWithCaption:@"Internet Address"
																  control:_internetAddress];
	
	self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
					   @"Album Details",
					   cAlbumName,
					   cAlbumTitle,
					   cInternetAddress,
					   nil];
	
	[_albumTitle becomeFirstResponder];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModel


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)delegates {
	NSMutableArray* delegates = [[NSMutableArray alloc] init];
	return [delegates autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
	return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
	return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoadingMore {
	return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isOutdated {
	return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidate:(BOOL)erase {
}


#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == _description)	{
		NSString *textForPostController = @"";
		NSDictionary* paramsArray = [NSDictionary dictionaryWithObjectsAndKeys:
									 self, @"delegate",
									 @"Add Description", @"titleView",
									 textForPostController, @"text",
									 nil];
		
		[[TTNavigator navigator] openURLAction:[[[TTURLAction actionWithURLPath:@"tt://loadFromVC/MyPostController"]
												 applyQuery:paramsArray] applyAnimated:YES]];		
		return NO;
	}
	else {
		return YES;
	}

}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyGo) {
		[self addAlbum];
		return YES;
    }
	else {
		return NO;
	}
	
}

#pragma mark -
#pragma mark MyPostController delegate

- (void)postController:(TTPostController*)postController didPostText:(NSString *)text withResult:(id)result {
	_description.text = nil;
	_description.text = text;
	
	[_albumTitle becomeFirstResponder];
}

- (void)postControllerDidCancel:(TTPostController*)postController {
	[_albumTitle becomeFirstResponder];
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
							_albumTitle.text, @"name",
							_albumTitle.text, @"title",
							_description.text, @"description",
							_internetAddress.text, @"slug",
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
				
		[MyAlbum updateFinishedWithItemURL:[[GlobalSettings.baseURL stringByAppendingString: @"/rest/item/"] stringByAppendingString:self.parentAlbumID] ];
		
		NSArray* viewControllers = [self.navigationController viewControllers];
		TTViewController* viewController = nil;
		        
        if ([viewControllers count] > 1) {
			viewController = [viewControllers objectAtIndex:[viewControllers count]-2];
			[self.navigationController popToViewController:viewController animated:YES];
			[((id<MyViewController>)viewController) reloadViewController:NO];
		}
	}
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
	TTAlertViewController* alert = [[[TTAlertViewController alloc] initWithTitle:@"Error" message:@"Please check fields for valid vaues!"] autorelease];
    [alert addCancelButtonWithTitle:@"OK" URL:nil];
    [alert showInView:self.view animated:YES];
	
	[self showLoading:NO];	
}

- (NSString *)urlEncodeValue:(NSString *)str {
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}

@end
