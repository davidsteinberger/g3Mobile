
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

//
#import "Three20UI/UIViewAdditions.h"
#import "Three20/Three20.h"

@interface MyCommentsViewController : TTTableViewController <TTPostControllerDelegate, TTTextEditorDelegate> {
	TTView* _textBar;
	TTTextEditor*     _textEditor;
	UIBarButtonItem* _clickComposeItem;
	UIBarButtonItem* _clickActionItem;
	UIToolbar*        _toolbar;
	
	NSString* _itemID;
}

@property (nonatomic, retain) NSString* itemID;

- (void)clickComposeItem;

@end
