#import "MyLoginDataSource.h"

#import "MyLoginModel.h"
#import "MyLogin.h"

#import "MySettings.h"

static int cursorPosition = 0;

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
	_baseURL.text = nil;
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
	cursorPosition = ++cursorPosition % 3;
    if (textField.returnKeyType == UIReturnKeyNext) {
		if (cursorPosition == 1) {
			[_usernameField becomeFirstResponder];
		}
		else if (cursorPosition == 2) {
			[_passwordField becomeFirstResponder];
		}
    }
    else {
		[_passwordField resignFirstResponder];
		cursorPosition = 0;
		
		MyLogin *settings = [[MyLogin alloc] init];
		settings.baseURL = _baseURL.text;
		settings.username = _usernameField.text;
		settings.password = _passwordField.text;
		settings.imageQuality = _imageQualityField.value;
		
		[(MyLoginModel*)self.model login:[settings autorelease]];
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
	//_loginModel = [[MyLoginModel alloc] init];
	
	NSMutableArray *items = [[NSMutableArray alloc] init];
	NSMutableArray *sections = [[NSMutableArray alloc] init];
	
	[sections addObject:@"Global"];
	NSMutableArray *itemsRow = [[NSMutableArray alloc] init];
	NSMutableArray *itemsRow2 = [[NSMutableArray alloc] init];
	
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
	[itemsRow addObject:cBaseURL];
	
	_usernameField = [[UITextField alloc] init];
	_usernameField.placeholder = @"*****";
	_usernameField.keyboardType = UIKeyboardTypeDefault;
	_usernameField.returnKeyType = UIReturnKeyNext;
	_usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
	_usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_usernameField.clearsOnBeginEditing = NO;
	_usernameField.delegate = self;
	_usernameField.text = @"admin";
	TTTableControlItem* cUsernameField = [TTTableControlItem itemWithCaption:@"Username"
																	 control:_usernameField];
	[itemsRow addObject:cUsernameField];
	
	_passwordField = [[UITextField alloc] init];
	_passwordField.placeholder = @"*****";
	_passwordField.returnKeyType = UIReturnKeyGo;
	_passwordField.secureTextEntry = YES;
	_passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
	_passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_passwordField.clearsOnBeginEditing = NO;
	_passwordField.delegate = self;
	_passwordField.text = @"gallery3";
	TTTableControlItem* cPasswordField = [TTTableControlItem itemWithCaption:@"Password"
																	 control:_passwordField];
	[itemsRow addObject:cPasswordField];		
	
	[sections addObject:@"Other"];
	
	_imageQualityField = [[[UISlider alloc] init] autorelease];
	_imageQualityField.minimumValue = 0.2;
	_imageQualityField.maximumValue = 0.8;
	
	_imageQualityField.value = GlobalSettings.imageQuality ? GlobalSettings.imageQuality : 0.5;
	
	[_imageQualityField addTarget:self
						   action:@selector(imageQualityChanged:) 
				 forControlEvents:UIControlEventTouchUpInside ];
	
	TTTableControlItem* imageQuality = [TTTableControlItem itemWithCaption:@"Image Quality" control:_imageQualityField];
	
	[itemsRow2 addObject:imageQuality];
	
	[items addObject:itemsRow];
	[items addObject:itemsRow2];		
	
	TT_RELEASE_SAFELY(itemsRow);
	TT_RELEASE_SAFELY(itemsRow2);
	
	_items = items;
	_sections = sections;
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
