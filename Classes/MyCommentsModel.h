
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#import <Three20/Three20.h>

@interface MyCommentsModel : TTURLRequestModel {
	NSTimeInterval _cacheExpirationAge;
	NSString* _searchQuery;
	short int _memberCount;
	short int _count;
	NSString* _itemID;
	NSMutableArray*  _comments;
	NSDictionary* _userDetails;

	BOOL _parentLoaded;
	
	BOOL done;
	BOOL loading;
}

@property (nonatomic, copy)     NSString* searchQuery;
@property (nonatomic, retain)   NSString* itemID;
@property (nonatomic, retain)	NSMutableArray*  comments;
@property (nonatomic, retain)	NSDictionary*  userDetails;

- (id)initWithSearchQuery:(NSString*)searchQuery;

@end
