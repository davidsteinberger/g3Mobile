#import <Three20/Three20.h>
#import <RestKit/RestKit.h>
#import <RestKit/Three20/RKRequestTTModel.h>
#import "RKMTree.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
  MockPhotoSourceNormal = 0,
  MockPhotoSourceDelayed = 1,
  MockPhotoSourceVariableCount = 2,
  MockPhotoSourceLoadError = 4,
} MockPhotoSourceType;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface PhotoSource : TTURLRequestModel <TTPhotoSource> {
	BOOL _lock;
	RKRequestTTModel* _model;
	MockPhotoSourceType _type;
	NSString* _title;
	NSMutableArray* newPhotos;
	NSMutableArray* _photos;
	NSArray* _tempPhotos;
	NSTimer* _fakeLoadTimer;
	NSString* _albumID;
	NSString* _parentURL;
}

@property (nonatomic, retain) RKRequestTTModel* model;
@property (nonatomic, retain) NSString* albumID;
@property (nonatomic, retain) NSString* parentURL;

- (id)initWithType:(MockPhotoSourceType)type parentURL:(NSString*)parentURL albumID:(NSString*)albumID title:(NSString*)title photos:(NSArray*)photos
		   photos2:(NSArray*)photos2;
+ (PhotoSource*)createPhotoSource:(NSString*)albumID;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface Photo : NSObject <TTPhoto> {
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
