#import <RestKit/RestKit.h>
#import <RestKit/Three20/RKObjectLoaderTTModel.h>
#import "Three20/Three20.h"
#import "RKMTree.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum {
  MockPhotoSourceNormal = 0,
  MockPhotoSourceDelayed = 1,
  MockPhotoSourceVariableCount = 2,
  MockPhotoSourceLoadError = 4,
} MockPhotoSourceType;

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface PhotoSource : RKObjectLoaderTTModel <TTPhotoSource> {
	MockPhotoSourceType _type;
	NSMutableArray* _newPhotos;
	NSArray* _photos;
	NSString* _albumID;
	NSString* _title;
    BOOL _photosOnly;
}

@property (nonatomic, retain) NSString* albumID;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, assign) BOOL photosOnly;

- (id)initWithItemID:(NSString*)itemID;

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

- (id)initWithURL:(NSString *)URL smallURL:(NSString *)smallURL thumbURL:(NSString *)thumbURL size:(CGSize)size
          caption:(NSString *)caption isAlbum:(BOOL)isAlbum photoID:(NSString *)photoID parentURL:(NSString *)parentURL;

@end
