
#import <Three20/Three20.h>
#import "MyViewController.h"

@interface MyThumbsViewController : TTThumbsViewController <MyViewController, UIActionSheetDelegate> {
	NSString* _albumID;
    
    BOOL _isEmpty;
    BOOL _isInEditingState;
}

@property(nonatomic, copy) NSString* albumID;

@end
