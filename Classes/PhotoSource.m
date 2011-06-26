#import "PhotoSource.h"
#import "Three20Core/NSArrayAdditions.h"
#import "AppDelegate.h"
#import "RKMItem.h"

@interface PhotoSource ()

- (NSString*)getAlbumTitle:(NSArray*)objects;
- (NSArray*)buildArrayOfPhotos:(NSArray*)objects forAlbum:(NSString*)albumID photosOnly:(BOOL)photosOnly;

@end


@implementation PhotoSource

@synthesize title = _title;
@synthesize albumID = _albumID;
@synthesize photosOnly = _photosOnly;


// see RKObjectLoaderTTModel
- (void)modelsDidLoad:(NSArray*)models {
    [models retain];
	[_objects release];
	_objects = nil;
    
	_objects = models;
	_isLoaded = YES;
    
    NSArray* newPhotos = [self buildArrayOfPhotos:self.objects forAlbum:self.albumID photosOnly:self.photosOnly];
    
    self.title = [self getAlbumTitle:self.objects];
    [_photos release];
    _photos = [newPhotos retain];
    
    for (int i = 0; i < _photos.count; ++i) {
        id <TTPhoto> photo = [_photos objectAtIndex:i];
        if ( (NSNull *)photo != [NSNull null] ) {
            photo.photoSource = self;
            photo.index = i;
        }
    }
    [super didFinishLoad];
}

- (id)initWithItemID:(NSString*)itemID
{
    NSString* treeResourcePath = [[[@"" 
                                    stringByAppendingString:@"/rest/tree/"] 
                                   stringByAppendingString:itemID]
                                  stringByAppendingString:@"?depth=1"];
    
    RKObjectLoader* objectLoader = [[RKObjectManager sharedManager] objectLoaderWithResourcePath:treeResourcePath delegate:nil];
    objectLoader.objectMapping = [[RKObjectManager sharedManager].mappingProvider objectMappingForClass:[RKMTree class]];
    
    if ((self = [self initWithObjectLoader:objectLoader])) {
        self.title = @"Photos";
		self.albumID = itemID;
        self.photosOnly = YES;
    }
    return self;
}

// RKObjectLoaderTTModel
- (BOOL)isLoaded {
    return !!_photos;
}

- (void)dealloc {
    [[RKRequestQueue sharedQueue] cancelAllRequests];
	TT_RELEASE_SAFELY(_newPhotos);
	TT_RELEASE_SAFELY(_photos);
	TT_RELEASE_SAFELY(_title);

	TT_RELEASE_SAFELY(_albumID);

	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoSource

- (NSInteger)numberOfPhotos {
	return _photos.count;
}

- (NSInteger)maxPhotoIndex {
	return _photos.count - 1;
}

- (id <TTPhoto>)photoAtIndex:(NSInteger)photoIndex {
    if (photoIndex < _photos.count) {
		id photo = [_photos objectAtIndex:photoIndex];
		if (photo == [NSNull null]) {
			return nil;
		}
		else {
			return photo;
		}
	}
	else {
		return nil;
	}
}

- (NSString*)getAlbumTitle:(NSArray*)objects {
    RKMTree* tree = [objects objectAtIndex:0];
    RKMEntity* root = [tree root];
    
	return [NSString stringWithString:(root.title) ? root.title : @""];
}

- (NSArray*)buildArrayOfPhotos:(NSArray*)objects forAlbum:(NSString*)albumID photosOnly:(BOOL)photosOnly{
	RKMTree* tree = [objects objectAtIndex:0];

	[_newPhotos release];
	_newPhotos = [[NSMutableArray alloc] init];
	
	for (RKMEntity* item in [tree children]) {
		
		if ([item.itemID isEqualToString:albumID]) {
			continue;
		}
		
		NSString* photoID = item.itemID;
		if (photoID == nil) {
			photoID = @"1";
		}
		
		NSString* parent = item.parent;
		if (parent == nil) {
			parent = @"1";
		}
		
		BOOL isAlbum;
		if ([item.type isEqualToString:@"album"]) {
			isAlbum = YES;
		} else {
			isAlbum = NO;
		}
		
		if (photosOnly && isAlbum) {
			continue;
		}
		
		NSString* thumb_url = (item.thumb_url_public != nil) ? item.thumb_url_public : item.thumb_url;
		if (thumb_url == nil) {
			thumb_url = @"bundle://empty.png";
		}
		
		NSString* resize_url = (item.resize_url_public != nil) ? item.resize_url_public : item.resize_url;
		if (resize_url == nil) {
			resize_url = @"bundle://empty.png";
		}
        
        NSString* url = (item.file_url_public != nil) ? item.file_url_public : item.file_url;
		if (url == nil) {
			url = @"bundle://empty.png";
		}
		
		id iWidth = item.thumb_width;
		id iHeight = item.thumb_height;
		short int width = 100;
		short int height = 100;
		
		if ([iWidth isKindOfClass:[NSString class]] && [iHeight isKindOfClass:[NSString class]]) {
			if ([@"" isEqualToString:iWidth] || [@"" isEqualToString:iHeight] || [@"0" isEqualToString:iWidth] || [@"0" isEqualToString:iHeight]) {
				width = 100;
				height = 100;
			}	
			else if ([iWidth length] > 0 && [iHeight length] > 0 ) {
				width = [iWidth longLongValue];
				height = [iHeight longLongValue];
			}
		}
		
		Photo* mph = [[Photo alloc]
					  initWithURL:[NSString stringWithString: url]
					  smallURL:[NSString stringWithString: resize_url]
                      thumbURL:[NSString stringWithString: thumb_url]
					  size:CGSizeMake(width, height)
					  caption:[NSString stringWithString:(item.title) ? item.title : @""]
					  isAlbum:isAlbum
					  photoID:[NSString stringWithString: photoID]
					  parentURL:[NSString stringWithString: parent]];
		
		[_newPhotos addObject:mph];
		TT_RELEASE_SAFELY(mph);
	}	
	NSArray* newPhotos = [NSArray arrayWithArray:_newPhotos];
	TT_RELEASE_SAFELY(_newPhotos);
	return newPhotos;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation Photo

@synthesize photoSource = _photoSource, size = _size, index = _index, caption = _caption,
            isAlbum = _isAlbum, photoID = _photoID, parentURL = _parentURL;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithURL:(NSString *)URL smallURL:(NSString *)smallURL thumbURL:(NSString *)thumbURL size:(CGSize)size
       caption:(NSString *)caption isAlbum:(BOOL)isAlbum photoID:(NSString *)photoID parentURL:(NSString *)parentURL {
	if ((self = [super init])) {
		_URL = [URL copy];
		_smallURL = [smallURL copy];
		_thumbURL = [thumbURL copy];
		_size = size;
		_caption = [caption copy];
		_index = NSIntegerMax;
		_isAlbum = isAlbum;
		_photoID = [photoID copy];
		_parentURL = [parentURL copy];
	}
	return self;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_thumbURL);
	TT_RELEASE_SAFELY(_smallURL);
	TT_RELEASE_SAFELY(_URL);
	TT_RELEASE_SAFELY(_caption);
	TT_RELEASE_SAFELY(_photoID);
	TT_RELEASE_SAFELY(_parentURL);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhoto

- (NSString *)URLForVersion:(TTPhotoVersion)version {
	if (version == TTPhotoVersionLarge) {
		return _URL;
	}
	else if (version == TTPhotoVersionMedium) {
		return _smallURL;
	}
	else if (version == TTPhotoVersionSmall) {
		return _smallURL;
	}
	else if (version == TTPhotoVersionThumbnail) {
		return _thumbURL;
	}
	else {
		return nil;
	}
}

@end