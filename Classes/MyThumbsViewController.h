#import <Three20/Three20.h>
#import "Three20UI/TTView.h"
#import "Three20UI/UIViewAdditions.h"

#import "FlipsideViewController.h"

@interface MyThumbsViewController : TTThumbsViewController <FlipsideViewControllerDelegate> {
	UIToolbar* _toolbar;
	UIBarButtonItem* _clickActionItem;
	
	UIImagePickerController* pickerController;
}

@end
