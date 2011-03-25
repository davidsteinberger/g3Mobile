//
//  AddAlbumViewController.m
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import "extThree20JSON/extThree20JSON.h"
#import "NSObject+YAJL.h"
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
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
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
	TT_RELEASE_SAFELY(_albumTitle);
	TT_RELEASE_SAFELY(_description);
	TT_RELEASE_SAFELY(_internetAddress);
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
#pragma mark TTModel


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)delegates {
	return TTCreateNonRetainingArray();
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

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
		[_albumTitle becomeFirstResponder];
		return NO;
    }
    else {
		[_albumTitle resignFirstResponder];
		
		[self updateAlbum];
		return YES;
    }
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
		NSDictionary* feed = [response.rootObject objectForKey:@"entity"];
		
		if ((NSNull*)feed != [NSNull null]) {
			self.entity = feed;
		}
	
		_albumTitle = [[UITextField alloc] init];
		_albumTitle.placeholder = @"Title";
		_albumTitle.delegate = self;
		_albumTitle.text = [self.entity objectForKey:@"title"];
		_albumTitle.returnKeyType = UIReturnKeyGo;
		
		TTTableControlItem* cAlbumTitle = [TTTableControlItem itemWithCaption:@"Title"
																	 control:_albumTitle];
		
		_description = [[UITextField alloc] init];
		_description.placeholder = @"Description";
		_description.delegate = self;
		_description.returnKeyType = UIReturnKeyGo;
		
		NSString *description = [self.entity objectForKey:@"description"];
		description = ((NSNull*)description == [NSNull null]) ? @"" : description;
		_description.text = description;
		
		TTTableControlItem* cAlbumDescription = [TTTableControlItem itemWithCaption:@"Description"
																	  control:_description];
		
		_internetAddress = [[UITextField alloc] init];
		_internetAddress.placeholder = @"Address";
		_internetAddress.delegate = self;
		_internetAddress.returnKeyType = UIReturnKeyGo;
		_internetAddress.text = [self.entity objectForKey:@"slug"];
		
		TTTableControlItem* cInternetAddress = [TTTableControlItem itemWithCaption:@"Internet Address"
																		   control:_internetAddress];
		
		self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
						   @"",
						   cAlbumTitle,
						   cAlbumDescription,
						   cInternetAddress,
						   nil];	
		[_albumTitle becomeFirstResponder];
		
		[super modelDidFinishLoad:self];
	}
	if ([request.userInfo isEqual:@"updateAlbum"]) {
		[MyAlbum updateFinishedWithItemURL:[[GlobalSettings.baseURL stringByAppendingString:@"/rest/item/"] stringByAppendingString:self.albumID]];	
		[MyAlbum updateFinishedWithItemURL:[self.entity valueForKey:@"parent"]];
		
		//[self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:[[self.navigationController viewControllers] count] - 3] animated:YES];
		/*
		int index = [[self.navigationController viewControllers] count] - 3;
		if (index >= 0) {
			[self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:index] animated:YES];
		}
		else {
			TTNavigator *navigator = [TTNavigator navigator];
			[navigator removeAllViewControllers];
			[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://root/1"] applyAnimated:YES]];
		}*/
		
		NSArray* viewControllers = [self.navigationController viewControllers];
		TTViewController* viewController = nil;
		if ([viewControllers count] > 1) {
			viewController = [viewControllers objectAtIndex:[viewControllers count]-2];
			[self.navigationController popToViewController:viewController animated:YES];
			[viewController performSelector:@selector(reload) withObject:nil afterDelay:0.3];	
		} else {
			[self performSelector:@selector(reload) withObject:nil afterDelay:0.3];		
		}
	}

}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == _description)	{
		NSString *textForPostController = _description.text;
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

- (void)postController:(TTPostController*)postController didPostText:(NSString *)text withResult:(id)result {
	_description.text = nil;
	_description.text = text;
	[_internetAddress becomeFirstResponder];
}

- (void)postControllerDidCancel:(TTPostController*)postController {
	[_albumTitle becomeFirstResponder];
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
	TTAlertViewController* alert = [[[TTAlertViewController alloc] initWithTitle:@"Error" message:@"Please check fields for valid vaues!"] autorelease];
    [alert addCancelButtonWithTitle:@"OK" URL:nil];
    [alert showInView:self.view animated:YES];
	
	[self showLoading:NO];		
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
		
	NSString *slug = ([_internetAddress.text isEqual:@""]) ? _albumTitle.text : _internetAddress.text;
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:    
							@"album", @"type",
							_albumTitle.text, @"name",
							_albumTitle.text, @"title",
							_description.text, @"description",
							slug, @"slug",
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
