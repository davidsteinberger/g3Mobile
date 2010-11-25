#import <Three20/Three20.h>
#import "Three20UI/TTView.h"
#import "Three20UI/UIViewAdditions.h"

#import "FlipsideViewController.h"
#import "MyAlbum.h"

@interface MyThumbsViewController : TTThumbsViewController <UIActionSheetDelegate, FlipsideViewControllerDelegate> {
	//NSMutableArray* _album;
	//MyAlbum* _g3Album;
	
	UIToolbar* _toolbar;
	UIBarButtonItem* _clickActionItem;
	UIImagePickerController* _pickerController;
}

//@property (nonatomic, retain) NSMutableArray* album;
//@property (nonatomic, retain) MyAlbum* g3Album;

@end
