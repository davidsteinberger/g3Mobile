#import "Three20/Three20.h"

static int cursorPosition = 0;

@class MyModel;

@interface MyLoginDataSource : TTSectionedDataSource <UITextFieldDelegate> {
    MyModel* _loginModel;
	UITextField* _baseURL;
    UITextField* _usernameField;
    UITextField* _passwordField;
	UISlider* _imageQualityField;
}

@property (nonatomic, readonly) UITextField* baseURL;
@property (nonatomic, readonly) UITextField* usernameField;

@end
