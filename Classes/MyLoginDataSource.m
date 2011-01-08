#import "MyLoginDataSource.h"

#import "MyLoginModel.h"
#import "MyLogin.h"

#import "MySettings.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MyLoginDataSource


@synthesize baseURL = _baseURL;
@synthesize usernameField = _usernameField;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    if (self = [super init]) {
		_myLoginModel = [[MyLoginModel alloc] init];
        self.model = _myLoginModel;
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
	//_baseURL.text = nil;
	self.sections = nil;
	self.items = nil;
	TT_RELEASE_SAFELY(_baseURL);
    TT_RELEASE_SAFELY(_usernameField);
    TT_RELEASE_SAFELY(_passwordField);
	TT_RELEASE_SAFELY(_myLoginModel);
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
	if (textField == _baseURL) {
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
	
	_baseURL.text = GlobalSettings.baseURL;
	TTTableControlItem* cBaseURL = [TTTableControlItem itemWithCaption:@"Website"
															   control:_baseURL];
	
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
	
	TTTableControlItem* cUsernameField = [TTTableControlItem itemWithCaption:@"Username"
																	 control:_usernameField];
	
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
	
	// put everything together (for the ttsectioneddatasource)
	// create sections
	NSMutableArray *sections = [[NSMutableArray alloc] init];
	[sections addObject:@"Global"];
	[sections addObject:@"Other"];
	[sections addObject:@"Cache Settings"];
	
	// create section items
	// section 1 will hold items for login details
	NSMutableArray *section1 = [[NSMutableArray alloc] init];
	[section1 addObject:cBaseURL];	
	[section1 addObject:cUsernameField];
	[section1 addObject:cPasswordField];
	// section 2 will hold the image quality slider
	NSMutableArray *section2 = [[NSMutableArray alloc] init];
	[section2 addObject:cImageQuality];
	// section 3 will hold button for clearing the cache
	NSMutableArray *section3 = [[NSMutableArray alloc] init];
	[section3 addObject:button];
	
	// create array for ttsectioneddatasource
	NSMutableArray *items = [[NSMutableArray alloc] init];
	[items addObject:section1];
	[items addObject:section2];
	[items addObject:section3];
	TT_RELEASE_SAFELY(section1);
	TT_RELEASE_SAFELY(section2);
	TT_RELEASE_SAFELY(section3);
	
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
