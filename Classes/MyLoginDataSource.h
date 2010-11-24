#import "Three20/Three20.h"

@class MyModel;

@interface MyLoginDataSource : TTSectionedDataSource <UITextFieldDelegate> {
    MyModel* _loginModel;
	UITextField* _baseURL;
    UITextField* _usernameField;
    UITextField* _passwordField;
}

@property (nonatomic, readonly) UITextField* baseURL;
@property (nonatomic, readonly) UITextField* usernameField;

@end
