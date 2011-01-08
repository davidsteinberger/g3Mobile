#import "Three20/Three20.h"

@class MyLoginModel;

@interface MyLoginDataSource : TTSectionedDataSource <UITextFieldDelegate> {
	MyLoginModel* _myLoginModel;
	UITextField* _baseURL;
    UITextField* _usernameField;
    UITextField* _passwordField;
	UISlider* _imageQualityField;
}

@property (nonatomic, readonly) UITextField* baseURL;
@property (nonatomic, readonly) UITextField* usernameField;

@end
