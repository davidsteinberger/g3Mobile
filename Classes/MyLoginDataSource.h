#import "Three20/Three20.h"

@interface MyLoginDataSource : TTSectionedDataSource <UITextFieldDelegate> {
	UISwitch* _viewOnly;
	UITextField* _baseURL;
    UITextField* _usernameField;
    UITextField* _passwordField;
	UISlider* _imageQualityField;
	TTView* _segmentedControlFrame;
    UITextField* _buildDateField;
    UITextField* _buildVersionField;
}

@property (nonatomic, readonly) UITextField* baseURL;
@property (nonatomic, readonly) UITextField* usernameField;

@end
