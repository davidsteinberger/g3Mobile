#import "PhotoSource.h"
#import "MyAlbum.h"
#import "AppDelegate.h"

@implementation PhotoSource

@synthesize model = _model;
@synthesize title = _title;
@synthesize albumID = _albumID;
@synthesize parentURL = _parentURL;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void)fakeLoadReady {
	_fakeLoadTimer = nil;

	RKMTree* response = [self.model.objects objectAtIndex:0];
	RKOEntity* entity = [response.entities objectAtIndex:0];
	
	if ([response.entities count] == 0) {
		_fakeLoadTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self  
														selector:@selector(fakeLoadReady) userInfo:nil repeats:NO];
		return;
	}
	
	
	if (_type & MockPhotoSourceLoadError) {
		[_delegates perform:@selector(model:didFailLoadWithError:)
		         withObject:self
		         withObject:nil];
	}
	else {
		newPhotos = [[NSMutableArray alloc] init];
		
		for (RKOEntity* item in response.entities) {
			
			if ([item.id isEqualToString:self.albumID]) {
				self.title = [NSString stringWithString:(item.title) ? item.title : @""];
				continue;
			}
			
			NSString* photoID = item.id;
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
			
			NSString* thumb_url = (item.thumb_url_public != nil) ? item.thumb_url_public : item.thumb_url;
			if (thumb_url == nil) {
				thumb_url = @"bundle://empty.png";
			}
			
			NSString* resize_url = (item.resize_url_public != nil) ? item.resize_url_public : item.resize_url;
			if (resize_url == nil) {
				resize_url = @"bundle://empty.png";
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
			
			Photo* mph = [[[Photo alloc]
							   initWithURL:[NSString stringWithString: resize_url]
							   smallURL:[NSString stringWithString: thumb_url]
							   size:CGSizeMake(width, height)
							   isAlbum:isAlbum
							   photoID:[NSString stringWithString: photoID]
							   parentURL:[NSString stringWithString: parent]] autorelease];
			
			[newPhotos addObject:mph];
			
		}

		[_photos release];
		_photos = [newPhotos retain];

		for (int i = 0; i < _photos.count; ++i) {
			id <TTPhoto> photo = [_photos objectAtIndex:i];
			if ( (NSNull *)photo != [NSNull null] ) {
				photo.photoSource = self;
				photo.index = i;
			}
		}

		[_delegates perform:@selector(modelDidFinishLoad:) withObject:self];		
	}
}



- (id)initWithItemID:(NSString*)itemID
{
    if ((self = [super init])) {
        self.title = @"Photos";
		self.albumID = itemID;
        NSString* treeResourcePath = [[[@"" 
										stringByAppendingString:@"/rest/tree/"] 
									   stringByAppendingString:itemID]
									  stringByAppendingString:@"?depth=1"];
		
		[RKRequestTTModel setDefaultRefreshRate:3600];
		RKRequestTTModel* myModel = [[RKRequestTTModel alloc] 
									 initWithResourcePath:treeResourcePath
									 params:nil objectClass:[RKMTree class]];
		self.model = myModel;
		[myModel load:TTURLRequestCachePolicyDefault more:NO];
		
		TT_RELEASE_SAFELY(myModel);

		_fakeLoadTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self  
														selector:@selector(fakeLoadReady) userInfo:nil repeats:NO];
    }
    return self;
}

- (void)dealloc {
	[_fakeLoadTimer invalidate];
	TT_RELEASE_SAFELY(newPhotos);
	TT_RELEASE_SAFELY(_model);
	TT_RELEASE_SAFELY(_photos);
	TT_RELEASE_SAFELY(_tempPhotos);
	TT_RELEASE_SAFELY(_title);

	TT_RELEASE_SAFELY(_albumID);

	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (BOOL)isLoading {
	return !!_fakeLoadTimer;
}

- (BOOL)isLoaded {
	return !!_photos;
}

- (void)cancel {
	[_fakeLoadTimer invalidate];
	_fakeLoadTimer = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoSource

- (NSInteger)numberOfPhotos {
	if (_tempPhotos) {
		return _photos.count + (_type & MockPhotoSourceVariableCount ? 0 : _tempPhotos.count);
	}
	else {
		return _photos.count;
	}
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

+ (PhotoSource*)createPhotoSource:(NSString*)albumID {
	
	NSString* treeResourcePath = [[[@"" 
									stringByAppendingString:@"/rest/tree/"] 
								   stringByAppendingString:albumID]
								  stringByAppendingString:@"?depth=1"];
	
	[RKRequestTTModel setDefaultRefreshRate:3600];
	RKRequestTTModel* myModel = [[RKRequestTTModel alloc] 
								 initWithResourcePath:treeResourcePath
								 params:nil objectClass:[RKMTree class]];

	NSArray* objects = [myModel loadSynchronous:NO];
	RKMTree* response = [objects objectAtIndex:0];

	NSMutableArray* newPhotos = [[NSMutableArray alloc] init];
	NSString* albumTitle;
	
	for (RKOEntity* item in  response.entities) {
		
		if ([item.id isEqualToString:albumID]) {
			albumTitle = [NSString stringWithString:(item.title) ? item.title : @""];
			continue;
		}
		
		NSString* photoID = item.id;
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
		
		if (isAlbum) continue;
		
		NSString* thumb_url = (item.thumb_url_public != nil) ? item.thumb_url_public : item.thumb_url;
		if (thumb_url == nil) {
			thumb_url = @"bundle://empty.png";
		}
		
		NSString* resize_url = (item.resize_url_public != nil) ? item.resize_url_public : item.resize_url;
		if (resize_url == nil) {
			resize_url = @"bundle://empty.png";
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
						   initWithURL:[NSString stringWithString: resize_url]
						   smallURL:[NSString stringWithString: thumb_url]
						   size:CGSizeMake(width, height)
						  caption:[NSString stringWithString:(item.title) ? item.title : @""]
						   isAlbum:isAlbum
						   photoID:[NSString stringWithString: photoID]
						   parentURL:[NSString stringWithString: parent]];
		
		[newPhotos addObject:mph];
		TT_RELEASE_SAFELY(mph);
	}
	
	
	NSString* albumParent = nil;
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	albumParent = [appDelegate.baseURL stringByAppendingString:@"/rest/item/1"];
	//[NSString stringWithString:albumTitle];
	
	PhotoSource* myPhotoSource = [[PhotoSource alloc] init];
	
	for (int i = 0; i < newPhotos.count; ++i) {
		id <TTPhoto> photo = [newPhotos objectAtIndex:i];
		if ( (NSNull *)photo != [NSNull null] ) {
			photo.photoSource = myPhotoSource;
			photo.index = i;
		}
	}
	
	myPhotoSource->_type = MockPhotoSourceNormal;
	myPhotoSource->_parentURL = [NSString stringWithString: albumParent];
	myPhotoSource.albumID = [NSString stringWithString: albumID];
	myPhotoSource.title = albumTitle;
	myPhotoSource->_photos = [newPhotos retain];
	
	TT_RELEASE_SAFELY(myModel);
	TT_RELEASE_SAFELY(newPhotos);
	return myPhotoSource;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation Photo

@synthesize photoSource = _photoSource, size = _size, index = _index, caption = _caption,
            isAlbum = _isAlbum, photoID = _photoID, parentURL = _parentURL;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithURL:(NSString *)URL smallURL:(NSString *)smallURL size:(CGSize)size isAlbum:(BOOL)isAlbum photoID:(NSString *)photoID parentURL:(NSString *)parentURL {
	return [self initWithURL:URL smallURL:smallURL size:size caption:nil isAlbum:isAlbum photoID:photoID parentURL:parentURL];
}

- (id)initWithURL:(NSString *)URL smallURL:(NSString *)smallURL size:(CGSize)size
       caption:(NSString *)caption isAlbum:(BOOL)isAlbum photoID:(NSString *)photoID parentURL:(NSString *)parentURL {
	if (self = [super init]) {
		_URL = [URL copy];
		_smallURL = [smallURL copy];
		_thumbURL = [smallURL copy];
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
		return _URL;
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