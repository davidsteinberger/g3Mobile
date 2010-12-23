#import <Three20/Three20.h>
#import "Three20UI/TTView.h"
#import "Three20UI/UIViewAdditions.h"

#import "FlipsideViewController.h"
#import "MyAlbum.h"

@interface MyThumbsViewController : TTThumbsViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate> {
	NSString* _albumID;
	UIToolbar* _toolbar;
	UIBarButtonItem* _clickActionItem;
	UIImagePickerController* _pickerController;
	
	UIAlertView* _progressAlert;
	UIActivityIndicatorView* _activityView;
	UIProgressView* _progressView;
}

@property(nonatomic, copy) NSString* albumID;

- (void)loadAlbum:(NSString* ) albumID;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
