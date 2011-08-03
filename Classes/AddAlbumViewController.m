//
//  AddAlbumViewController.m
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import "AddAlbumViewController.h"

// Settings
#import "MySettings.h"

@interface AddAlbumViewController ()

- (void)addAlbum;

@end

@implementation AddAlbumViewController

@synthesize parentAlbumID = _parentAlbumID;
@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.title = @"Add Album";
        
        self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
		self.navigationBarStyle = UIBarStyleBlack;
		self.navigationBarTintColor = nil;
		self.wantsFullScreenLayout = NO;
		self.hidesBottomBarWhenPushed = NO;
        
		self.tableViewStyle = UITableViewStyleGrouped;
	}
	return self;
}

- (id)initWithParentAlbumID: (NSString* )albumID andDelegate:(id<MyViewController>) delegate {
	self.parentAlbumID = albumID;	
    self.delegate = delegate;
    
	return [self initWithNibName:nil bundle: nil];
}

- (void)dealloc {
    self.delegate = nil;
	TT_RELEASE_SAFELY(_parentAlbumID);
	TT_RELEASE_SAFELY(_albumTitle);
	TT_RELEASE_SAFELY(_description);
	TT_RELEASE_SAFELY(_slug);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)createModel {	
	_albumTitle = [[UITextField alloc] init];
	_albumTitle.placeholder = @"Title";
	_albumTitle.delegate = self;
    _albumTitle.tag = 0;
	_albumTitle.returnKeyType = UIReturnKeyNext;
	
	TTTableControlItem* cAlbumName = [TTTableControlItem itemWithCaption:@"Title"
															   control:_albumTitle];

	_description = [[UITextField alloc] init];
	_description.placeholder = @"Description";
	_description.delegate = self;
    _description.tag = 1;
	_description.returnKeyType = UIReturnKeyNext;

	TTTableControlItem* cAlbumTitle = [TTTableControlItem itemWithCaption:@"Description"
																 control:_description];
	
	_slug = [[UITextField alloc] init];
	_slug.placeholder = @"Address";
	_slug.delegate = self;
    _slug.tag = 2;
	_slug.returnKeyType = UIReturnKeyGo;
	
	TTTableControlItem* cInternetAddress = [TTTableControlItem itemWithCaption:@"Internet Address"
																  control:_slug];
	
	self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
					   @"Album Details",
					   cAlbumName,
					   cAlbumTitle,
					   cInternetAddress,
					   nil];
	
	[_albumTitle becomeFirstResponder];
}


#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _description)	{
		NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:
									 self, @"delegate",
									 @"Add Description", @"titleView",
									 textField.text, @"text",
									 nil];
		
		[[TTNavigator navigator] openURLAction:[[[TTURLAction actionWithURLPath:@"tt://loadFromVC/MyPostController"]
												 applyQuery:query] applyAnimated:YES]];		
		return NO;
	}
	else {
		return YES;
	}

}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        switch (textField.tag) {
            case 0:
                [_description becomeFirstResponder];
                break;                
            default:
                break;
        }
    } else {
        [self addAlbum];
		return YES;
    }
    return NO;	
}

#pragma mark -
#pragma mark MyPostController delegate

- (void)postController:(TTPostController*)postController didPostText:(NSString *)text withResult:(id)result {
	_description.text = nil;
	_description.text = text;
	
	[_slug becomeFirstResponder];
}

- (void)postControllerDidCancel:(TTPostController*)postController {
	[_slug becomeFirstResponder];
}



#pragma mark -
#pragma mark helpers

- (void)addAlbum {	
    RKClient *client = [RKObjectManager sharedManager].client;
	[client setValue:@"post" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	RKParams *postParams = [RKParams params];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:    
							@"album", @"type",
							_albumTitle.text, @"name",
							_albumTitle.text, @"title",
							_description.text, @"description",
							_slug.text, @"slug",
							nil]; 
    
    NSError *error = nil;
	id <RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
	NSString *paramsString = [parser stringFromObject:params error:&error];
    
	[postParams setValue:paramsString forParam:@"entity"];
    
    NSString *resourcePath = [@"/rest/item/" stringByAppendingString:self.parentAlbumID];
    
	[client post:resourcePath params:postParams delegate:self];
    
	[client setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    [self.delegate reloadViewController:YES];
    [self dismissModalViewControllerAnimated:YES];
}


- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
	NSLog(@"didFailLoadWithError");
    
    TTAlertViewController* alert = [[[TTAlertViewController alloc] initWithTitle:@"Error" message:@"Please check fields for valid vaues!"] autorelease];
    [alert addCancelButtonWithTitle:@"OK" URL:nil];
    [alert showInView:self.view animated:YES];
	
	[self showLoading:NO];
}

@end
