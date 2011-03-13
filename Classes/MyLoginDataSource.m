#import "MyLoginDataSource.h"

#import "MyLoginModel.h"
#import "MyLogin.h"

#import "MySettings.h"
#import "AppDelegate.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MyLoginDataSource

@synthesize baseURL = _baseURL;
@synthesize usernameField = _usernameField;
@synthesize viewOnly = _viewOnly;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    if (self = [super init]) {
        self.model = [[[MyLoginModel alloc] init] autorelease];
		
		// view-only switch
		_viewOnly = [[UISwitch alloc] init];
		
		// url for website
		_baseURL = [[UITextField alloc] init];
		_baseURL.placeholder = @"http://example.com";
		_baseURL.keyboardType = UIKeyboardTypeURL;
		_baseURL.returnKeyType = UIReturnKeyNext;
		_baseURL.autocorrectionType = UITextAutocorrectionTypeNo;
		_baseURL.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_baseURL.clearButtonMode = UITextFieldViewModeWhileEditing;
		_baseURL.clearsOnBeginEditing = NO;
		_baseURL.delegate = self;		
		
		// username field
		_usernameField = [[UITextField alloc] init];
		_usernameField.placeholder = @"*****";
		_usernameField.keyboardType = UIKeyboardTypeDefault;
		_usernameField.returnKeyType = UIReturnKeyNext;
		_usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
		_usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
		_usernameField.clearsOnBeginEditing = NO;
		_usernameField.delegate = self;
		
		// password field
		_passwordField = [[UITextField alloc] init];
		_passwordField.placeholder = @"*****";
		_passwordField.returnKeyType = UIReturnKeyGo;
		_passwordField.secureTextEntry = YES;
		_passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
		_passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
		_passwordField.clearsOnBeginEditing = NO;
		_passwordField.delegate = self;
		
		// layout switcher
		_segmentedControlFrame = [[TTView alloc] initWithFrame:CGRectMake(-1.0f, -1.0f, 302.0f, 46.0f)];
		
		//_baseURL.text = @"http://192.168.1.89/~David/gallery3/index.php"; //@"http://www.menalto.com/photos"; //GlobalSettings.baseURL;
		_baseURL.text = GlobalSettings.baseURL;
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
	TT_RELEASE_SAFELY(_model);
	TT_RELEASE_SAFELY(_viewOnly);
	TT_RELEASE_SAFELY(_baseURL);
    TT_RELEASE_SAFELY(_usernameField);
    TT_RELEASE_SAFELY(_passwordField);
	TT_RELEASE_SAFELY(_segmentedControlFrame);
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
	if (textField == _baseURL && !self.viewOnly.on) {
		[_usernameField becomeFirstResponder];
	}
	else {
		if (textField == _usernameField) {
			[_passwordField becomeFirstResponder];
		}
		else {
			[_passwordField resignFirstResponder];

			MyLogin *settings = [[MyLogin alloc] init];
			settings.baseURL = _baseURL.text;
			settings.username = _usernameField.text;
			settings.password = _passwordField.text;
			settings.imageQuality = _imageQualityField.value;
			
			[(MyLoginModel*)self.model login:[settings autorelease]];
		}
	}
    return YES;
}

- (BOOL)isLoaded {
	return YES;
}

- (BOOL) tableView: (UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:
(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:
(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		GlobalSettings.viewOnly = YES;
		
		NSIndexPath *userPath = [NSIndexPath indexPathForRow:1 inSection:1];
		NSIndexPath *passwordPath = [NSIndexPath indexPathForRow:2 inSection:1];
		
		[[_items objectAtIndex:userPath.section]
		 removeObjectAtIndex:userPath.row];
		[[_items objectAtIndex:userPath.section]
		 removeObjectAtIndex:userPath.row];
		
		_baseURL.returnKeyType = UIReturnKeyGo;
		_usernameField.text = @"";
		_passwordField.text = @"";
		
		[tableView deleteRowsAtIndexPaths:[NSArray
										   arrayWithObjects:userPath,passwordPath, nil]
						 withRowAnimation:UITableViewRowAnimationFade];
		
		[tableView endUpdates];
		
		[_baseURL becomeFirstResponder];
	}
	if (editingStyle == UITableViewCellEditingStyleInsert) {
		
		GlobalSettings.viewOnly = NO;
		
		[tableView beginUpdates];
		
		NSIndexPath *userPath = [NSIndexPath indexPathForRow:1 inSection:1];
		NSIndexPath *passwordPath = [NSIndexPath indexPathForRow:2 inSection:1];
		
		TTTableControlItem* cUsernameField = [TTTableControlItem itemWithCaption:@"Username"
																		 control:_usernameField];
		TTTableControlItem* cPasswordField = [TTTableControlItem itemWithCaption:@"Password"
																		 control:_passwordField];
		
		_usernameField.enabled = YES;
		_passwordField.enabled = YES;
		
		[[_items objectAtIndex:userPath.section] insertObject:cUsernameField
													   atIndex:userPath.row];
		[[_items objectAtIndex:passwordPath.section] insertObject:cPasswordField
													  atIndex:passwordPath.row];
		
		[tableView insertRowsAtIndexPaths:[NSArray
										   arrayWithObjects:userPath,passwordPath, nil]
						 withRowAnimation:UITableViewRowAnimationFade];
		
		[tableView endUpdates];
		
		[_usernameField becomeFirstResponder];
	}
	
} 

- (void)imageQualityChanged:(UISlider*)control {
	NSNumber* number = [NSNumber numberWithFloat:control.value];
	GlobalSettings.imageQuality = [number floatValue];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties


///////////////////////////////////////////////////////////////////////////////////////////////////
/*- (id<TTModel>)model {
    //return _loginModel;
	return _model;
}*/


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableViewDidLoadModel:(UITableView*)tableView {	
	// create ui-elements
	
	if (!GlobalSettings.viewOnly) {
		_viewOnly.on = NO;
	} else {
		_viewOnly.on = YES;
		_usernameField.text = @"";
		_passwordField.text = @"";
	}

    TTTableControlItem* cViewOnly = [TTTableControlItem itemWithCaption:@"View Only" control:_viewOnly];
	
	[_viewOnly addTarget:tableView.delegate  action:@selector(toggleViewOnly:) forControlEvents:UIControlEventValueChanged];
	
	
	TTTableControlItem* cBaseURL = [TTTableControlItem itemWithCaption:@"Website"
															   control:_baseURL];
	
		
	TTTableControlItem* cUsernameField = [TTTableControlItem itemWithCaption:@"Username"
																	 control:_usernameField];
	
	
	TTTableControlItem* cPasswordField = [TTTableControlItem itemWithCaption:@"Password"
																	 control:_passwordField];
	
	// image quality field
	_imageQualityField = [[[UISlider alloc] init] autorelease];
	_imageQualityField.minimumValue = 0.2;
	_imageQualityField.maximumValue = 0.8;
	
	_imageQualityField.value = GlobalSettings.imageQuality ? GlobalSettings.imageQuality : 0.5;
	
	[_imageQualityField addTarget:self
						   action:@selector(imageQualityChanged:) 
				 forControlEvents:UIControlEventTouchUpInside ];
	
	TTTableControlItem* cImageQuality = [TTTableControlItem itemWithCaption:@"Image Quality" control:_imageQualityField];
	
	// a button to clear all cache
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
	[button setTitle:@"Delete all Cache" forState:UIControlStateNormal];
	[button addTarget:@"tt://removeAllCache" action:@selector(openURL)
	 forControlEvents:UIControlEventTouchUpInside];
	button.frame = CGRectMake(20, 20, appFrame.size.width - 40, 50);
	
	_segmentedControlFrame.backgroundColor = [UIColor clearColor];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:_segmentedControlFrame.bounds];
	[segmentedControl insertSegmentWithTitle:@"Album" atIndex:0 animated:NO];
	[segmentedControl insertSegmentWithTitle:@"Thumbs" atIndex:1 animated:NO];
	segmentedControl.selectedSegmentIndex = (GlobalSettings.viewStyle == kAlbumView) ? 0 : 1;
	[segmentedControl addTarget:(AppDelegate *)[[UIApplication sharedApplication] delegate]
						 action:@selector(dispatchToRootController:)
			   forControlEvents:UIControlEventValueChanged];
	[_segmentedControlFrame addSubview:segmentedControl];
	TT_RELEASE_SAFELY(segmentedControl);	
	
	// put everything together (for the ttsectioneddatasource)
	// create sections
	NSMutableArray *sections = [[NSMutableArray alloc] init];
	[sections addObject:@""];
	[sections addObject:@"Global"];
	[sections addObject:@"Other"];
	[sections addObject:@"Cache Settings"];
	[sections addObject: @"View Settings"];
	
	NSMutableArray *section0 = [[NSMutableArray alloc] init];
	[section0 addObject:cViewOnly];
	
	// create section items
	// section 1 will hold items for login details
	NSMutableArray *section1 = [[NSMutableArray alloc] init];
	[section1 addObject:cBaseURL];	
	
	if (!GlobalSettings.viewOnly) {
		[section1 addObject:cUsernameField];
		[section1 addObject:cPasswordField];
	}
	
	// section 2 will hold the image quality slider
	NSMutableArray *section2 = [[NSMutableArray alloc] init];
	[section2 addObject:cImageQuality];
	// section 3 will hold button for clearing the cache
	NSMutableArray *section3 = [[NSMutableArray alloc] init];
	[section3 addObject:button];
	// section 4 will hold button for chossing the view-style
	NSMutableArray *section4 = [[NSMutableArray alloc] init];
	[section4 addObject:_segmentedControlFrame];
	
	// create array for ttsectioneddatasource
	NSMutableArray *items = [[NSMutableArray alloc] init];
	[items addObject:section0];
	[items addObject:section1];
	[items addObject:section2];
	[items addObject:section3];
	[items addObject: section4];
	TT_RELEASE_SAFELY(section0);
	TT_RELEASE_SAFELY(section1);
	TT_RELEASE_SAFELY(section2);
	TT_RELEASE_SAFELY(section3);
	TT_RELEASE_SAFELY(section4);
	
	self.items = items;
	self.sections = sections;
	TT_RELEASE_SAFELY(sections);
	TT_RELEASE_SAFELY(items);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForLoading:(BOOL)reloading {
	if (reloading) {
		return NSLocalizedString(@"Updating settings", @"Settings updating text");
	} else {
		return NSLocalizedString(@"Getting settings...", @"Settings feed loading text");
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForEmpty {
	return NSLocalizedString(@"Error", @"Error");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
	return NSLocalizedString(@"Sorry, there was an error logging you in!", @"");
}


@end
