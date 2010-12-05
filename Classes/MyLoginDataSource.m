#import "MyLoginDataSource.h"

#import "MyLoginModel.h"
#import "MyLogin.h"

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
        
        [sections addObject:@""];
        NSMutableArray *itemsRow = [[NSMutableArray alloc] init];
        
		_baseURL = [[UITextField alloc] init];
        _baseURL.placeholder = @"Website";
        _baseURL.keyboardType = UIKeyboardTypeURL;
        _baseURL.returnKeyType = UIReturnKeyNext;
        _baseURL.autocorrectionType = UITextAutocorrectionTypeNo;
        _baseURL.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _baseURL.clearButtonMode = UITextFieldViewModeWhileEditing;
        _baseURL.clearsOnBeginEditing = NO;
        _baseURL.delegate = self;
//		_baseURL.text = @"";
        _baseURL.text = @"http://192.168.1.100/~David/gallery3/index.php";
//		_baseURL.text = @"http://www.david-steinberger.at/gallery3/index.php";
        [itemsRow addObject:_baseURL];
		
        _usernameField = [[UITextField alloc] init];
        _usernameField.placeholder = @"Username";
        _usernameField.keyboardType = UIKeyboardTypeDefault;
        _usernameField.returnKeyType = UIReturnKeyNext;
        _usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
        _usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _usernameField.clearsOnBeginEditing = NO;
        _usernameField.delegate = self;
//        _usernameField.text = @"";
        _usernameField.text = @"admin";
        [itemsRow addObject:_usernameField];
        
        _passwordField = [[UITextField alloc] init];
        _passwordField.placeholder = @"Password";
        _passwordField.returnKeyType = UIReturnKeyGo;
        _passwordField.secureTextEntry = YES;
        _passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
        _passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordField.clearsOnBeginEditing = NO;
        _passwordField.delegate = self;
//        _passwordField.text = @"";
       _passwordField.text = @"gallery3";
        [itemsRow addObject:_passwordField];
        
        [items addObject:itemsRow];
        TT_RELEASE_SAFELY(itemsRow);
        
        _items = items;
        _sections = sections;
        
        [_baseURL becomeFirstResponder];
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
    if (textField.returnKeyType == UIReturnKeyNext) {
        [_passwordField becomeFirstResponder];
    }
    else {
		[_passwordField resignFirstResponder];
		[_loginModel login:_baseURL.text username:_usernameField.text password:_passwordField.text];
    }
    return YES;
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
