#import <Three20/Three20.h>
#import "Three20UI/TTView.h"
#import "Three20UI/UIViewAdditions.h"

#import "MyAlbum.h"

@interface MyThumbsViewController : TTThumbsViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
	NSString* _albumID;
	UIToolbar* _toolbar;
	UIBarButtonItem* _clickActionItem;
	UIImagePickerController* _pickerController;
	
	UIAlertView* _progressAlert;
	UIActivityIndicatorView* _activityView;
	UIProgressView* _progressView;
    
    BOOL _goBack;
}

@property(nonatomic, copy) NSString* albumID;

@end
