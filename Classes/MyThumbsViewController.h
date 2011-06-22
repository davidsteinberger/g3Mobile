#import <Three20/Three20.h>
#import "Three20UI/TTView.h"
#import "Three20UI/UIViewAdditions.h"

@interface MyThumbsViewController : TTThumbsViewController <UIActionSheetDelegate> {
	NSString* _albumID;
    
    BOOL _goBack;
    BOOL _isEmpty;
    BOOL _isInEditingState;
}

@property(nonatomic, copy) NSString* albumID;

@end
