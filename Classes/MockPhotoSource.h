#import <Three20/Three20.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
  MockPhotoSourceNormal = 0,
  MockPhotoSourceDelayed = 1,
  MockPhotoSourceVariableCount = 2,
  MockPhotoSourceLoadError = 4,
} MockPhotoSourceType;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface MockPhotoSource : TTURLRequestModel <TTPhotoSource> {
	MockPhotoSourceType _type;
	NSString* _title;
	NSMutableArray* _photos;
	NSArray* _tempPhotos;
	NSTimer* _fakeLoadTimer;
	NSString* _albumID;
	NSString* _parentURL;
}

@property (nonatomic, retain) NSString* albumID;
@property (nonatomic, retain) NSString* parentURL;

- (id)initWithType:(MockPhotoSourceType)type parentURL:(NSString*)parentURL albumID:(NSString*)albumID title:(NSString*)title photos:(NSArray*)photos
		   photos2:(NSArray*)photos2;
+ (MockPhotoSource*)createPhotoSource:(NSString*)albumID;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface MockPhoto : NSObject <TTPhoto> {
  id<TTPhotoSource> _photoSource;
  NSString* _thumbURL;
  NSString* _smallURL;
  NSString* _URL;
  CGSize _size;
  NSInteger _index;
  NSString* _caption;
@public
	BOOL _isAlbum;
	NSString* _photoID;
	NSString* _parentURL;
}

@property BOOL isAlbum;
@property(nonatomic, retain) NSString* photoID;
@property (nonatomic, retain) NSString* parentURL;

- (id)initWithURL:(NSString*)URL smallURL:(NSString*)smallURL size:(CGSize)size isAlbum:(BOOL)isAlbum photoID:(NSString*)photoID parentURL:(NSString*)parentURL;

@end
