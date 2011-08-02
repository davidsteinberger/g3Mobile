//
//  AddAlbumViewController.m
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import "MySettings.h"
#import <RestKit/Three20/RKObjectLoaderTTModel.h>
#import "AppDelegate.h"

#import "UpdateAlbumViewController.h"
#import "MyViewController.h"
#import "RKMItem.h"
#import "RKMEntity.h"

@interface UpdateAlbumViewController ()

- (void)updateAlbum;

@property (nonatomic, retain) UITextField* albumTitle;
@property (nonatomic, retain) UITextField* description;
@property (nonatomic, retain) UITextField* slug;
    
@end

@implementation UpdateAlbumViewController

@synthesize albumID = _albumID;
@synthesize delegate = _delegate;
@synthesize albumTitle = _albumTitle;
@synthesize description = _description;
@synthesize slug = _slug;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.title = @"Update Album";
		self.navigationItem.backBarButtonItem =
		[[[UIBarButtonItem alloc] initWithTitle:@"Album" style:UIBarButtonItemStyleBordered
										 target:nil action:nil] autorelease];
		
        self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
		self.navigationBarStyle = UIBarStyleBlack;
		self.navigationBarTintColor = nil;
		self.wantsFullScreenLayout = NO;
		self.hidesBottomBarWhenPushed = NO;
        
		self.tableViewStyle = UITableViewStyleGrouped;
	}
	return self;
}

- (id)initWithAlbumID: (NSString* )albumID andDelegate:(id<MyViewController>)delegate {
	self.albumID = albumID;
	self.delegate = delegate;

	return [self initWithNibName:nil bundle: nil];
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_albumID);
    
	TT_RELEASE_SAFELY(_albumTitle);
	TT_RELEASE_SAFELY(_description);
	TT_RELEASE_SAFELY(_slug);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (void)createModel {
    NSString* resourcePath = [[[@""
                                stringByAppendingString:@"/rest/item/"]
                               stringByAppendingString:self.albumID]
                              stringByAppendingString:@"?fields=tag_item.tag"];
    RKObjectLoader* objectLoader = [[RKObjectManager sharedManager] objectLoaderWithResourcePath:resourcePath delegate:nil];
    objectLoader.objectMapping = [[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[RKMItem class]];
    self.model = [RKObjectLoaderTTModel modelWithObjectLoader:objectLoader];
    [super createModel];
}

- (UITextField*)createTextField:(id)delegate title:(NSString*)title value:(NSString*)value position:(NSInteger)position returnKeyType:(UIReturnKeyType)returnKeyType {
    UITextField* textField = [[UITextField alloc] init];
    textField.placeholder = title;
    textField.delegate = delegate;
    textField.text = value;
    textField.tag = position;
    textField.returnKeyType = returnKeyType;
    
    return textField;
}

- (void)didLoadModel:(BOOL)firstTime {
	[super didLoadModel:firstTime];
    
    if ([self.model isKindOfClass:[RKObjectLoaderTTModel class]]) {
        RKObjectLoaderTTModel* model = (RKObjectLoaderTTModel*)self.model;
        NSMutableArray* items = [NSMutableArray arrayWithCapacity:[model.objects count]];
        
        for (RKMItem* item in model.objects) {                        
            self.albumTitle = [self createTextField:self title:@"Title" value:item.rEntity.title position:0 returnKeyType:UIReturnKeyNext];
            TTTableControlItem* cAlbumTitle = [TTTableControlItem itemWithCaption:@"Title" control:_albumTitle];
            
            self.description = [self createTextField:self title:@"Description" value:item.rEntity.desc position:1 returnKeyType:UIReturnKeyNext];
            TTTableControlItem* cAlbumDescription = [TTTableControlItem itemWithCaption:@"Description" control:_description];
            
            self.slug = [self createTextField:self title:@"Internet Address" value:item.rEntity.slug position:2 returnKeyType:UIReturnKeyGo];
            TTTableControlItem* cInternetAddress = [TTTableControlItem itemWithCaption:@"Internet Address" control:_slug];
            
            [items addObject:cAlbumTitle];
            [items addObject:cAlbumDescription];
            [items addObject:cInternetAddress];
        }
        TTSectionedDataSource* dataSource = [TTSectionedDataSource dataSourceWithArrays:@"", items, nil];
        
		dataSource.model = self.model;
		self.dataSource = dataSource;
        
        [_albumTitle becomeFirstResponder];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        switch (textField.tag) {
            case 0:
                [self.description becomeFirstResponder];
                break;
            default:
                break;
        }
    } else {
		[self updateAlbum];
		return YES;
    }
    return NO;
}


- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {

	if (textField.tag == 1)	{
		NSString *textForPostController = textField.text;
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

#pragma mark -
#pragma mark helpers

- (void)postController:(TTPostController*)postController didPostText:(NSString *)text withResult:(id)result {
    self.description.text = text;
	[_slug becomeFirstResponder];
}

- (void)postControllerDidCancel:(TTPostController*)postController {
	[_slug becomeFirstResponder];
}


- (void)updateAlbum {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	RKClient *client = [RKObjectManager sharedManager].client;
	[client setValue:@"put" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	RKParams *postParams = [RKParams params];
    
    NSString *slug = ([_slug.text isEqual:@""]) ? _albumTitle.text : _slug.text;
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:    
							@"album", @"type",
							_albumTitle.text, @"title",
							_description.text, @"description",
							slug, @"slug",
							nil];  
    
    NSError *error = nil;
	id <RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
	NSString *paramsString = [parser stringFromObject:params error:&error];
    
	[postParams setValue:paramsString forParam:@"entity"];
    
    NSString *resourcePath = [@"/rest/item/" stringByAppendingString:self.albumID];
    
	[client post:resourcePath params:postParams delegate:self];
    
	[client setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
}


- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.delegate reloadViewController:YES];
    [self dismissModalViewControllerAnimated:YES];
}


- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	TTAlertViewController* alert = [[[TTAlertViewController alloc] initWithTitle:@"Error" message:@"Please check fields for valid vaues!"] autorelease];
    [alert addCancelButtonWithTitle:@"OK" URL:nil];
    [alert showInView:self.view animated:YES];
	
	[self showLoading:NO];		
}


@end
