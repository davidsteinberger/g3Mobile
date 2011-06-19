#import <Three20/Three20.h>
#import "Three20UI/TTView.h"
#import "Three20UI/UIViewAdditions.h"

@interface MyThumbsViewController : TTThumbsViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
	NSString* _albumID;
	UIImagePickerController* _pickerController;
	
	UIAlertView* _progressAlert;
	UIActivityIndicatorView* _activityView;
	UIProgressView* _progressView;
    
    BOOL _goBack;
    BOOL _isEmpty;
    BOOL _isInEditingState;
}

@property(nonatomic, copy) NSString* albumID;

@end
