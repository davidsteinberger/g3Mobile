
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

//
#import "Three20UI/UIViewAdditions.h"
#import "Three20/Three20.h"

@interface MyCommentsViewController : TTTableViewController <TTPostControllerDelegate> {
	UIBarButtonItem*  _nextButton;
	UIBarButtonItem*  _previousButton;
	
	UIBarButtonItem* _clickComposeItem;
	UIBarButtonItem* _clickActionItem;
	
	UIView*           _innerView;
	TTScrollView*     _scrollView;
	
	UIToolbar*        _toolbar;
	NSString*		  _itemID;
}

@property (nonatomic, retain) NSString* itemID;

@end
