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
        _loginModel = [[MyLoginModel alloc] init];
		
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

        TTTableControlItem* cPasswordField = [TTTableControlItem itemWithCaption:@"Password"
																		 control:_passwordField];
        [itemsRow addObject:cPasswordField];		
		
		[sections addObject:@"Other"];
		
		_imageQualityField = [[[UISlider alloc] init] autorelease];
		_imageQualityField.minimumValue = 0;
		_imageQualityField.maximumValue = 1;
		
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
        
        //[_baseURL becomeFirstResponder];
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    TT_RELEASE_SAFELY(_loginModel);
	TT_RELEASE_SAFELY(_baseURL);
    TT_RELEASE_SAFELY(_usernameField);
    TT_RELEASE_SAFELY(_passwordField);
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
		[_loginModel login:_baseURL.text username:_usernameField.text password:_passwordField.text imageQuality:_imageQualityField.value];
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
- (id<TTModel>)model {
    return _loginModel;
}

@end
