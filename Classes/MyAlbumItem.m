//
//  TTTableMessageItem+g3.m
//  g3Mobile
//
//  Created by David Steinberger on 2/6/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyAlbumItem.h"


@implementation MyAlbumItem

@synthesize model = _model;
@synthesize itemID = _itemID;
@synthesize type = _type;
@synthesize title = _title;
@synthesize autor = _autor;
@synthesize description = _description;
@synthesize timestamp = _timestamp;
@synthesize imageURL = _imageURL;
@synthesize width = _width;
@synthesize height = _height;

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithItemID:(NSString*)itemID model:(MyRestResource*)model type:(NSString*)type title:(NSString*)title caption:(NSString*)caption description:(NSString*)description text:(NSString*)text
          timestamp:(NSDate*)timestamp imageURL:(NSString*)imageURL width:(CGFloat)width height:(CGFloat)height URL:(NSString*)URL {
	MyAlbumItem* item = [[[self alloc] init] autorelease];
	item.model = model;
	item.itemID = itemID;
	item.type = type;
	item.title = title;
	item.description = description;
	item.timestamp = timestamp;
	item.imageURL = imageURL;
	item.width = width;
	item.height = height;
	item.URL = URL;
	return item;
}

#pragma mark -
#pragma mark NSObject

- (id)init {  
	if (self = [super init]) {  
		_width = 34;
		_height = 34;
		_description = @"";
	}
	
	return self;
}


- (void)dealloc {  
	TT_RELEASE_SAFELY(_model);
	TT_RELEASE_SAFELY(_itemID);
	TT_RELEASE_SAFELY(_type);
	TT_RELEASE_SAFELY(_title);
	TT_RELEASE_SAFELY(_autor);
	TT_RELEASE_SAFELY(_description);
	TT_RELEASE_SAFELY(_timestamp);
	TT_RELEASE_SAFELY(_imageURL);
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
    if (self = [super initWithCoder:decoder]) {  
        self.width = [decoder decodeFloatForKey:@"width"];
        self.height = [decoder decodeFloatForKey:@"height"];
		self.description = [decoder decodeObjectForKey:@"description"];
    }
	
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {  
    [super encodeWithCoder:encoder];
	
    if (self.width) {
        [encoder encodeFloat:self.width
					   forKey:@"width"];
    }
    if (self.height) {
        [encoder encodeFloat:self.height
					   forKey:@"height"];
    }
	if (self.description) {
		[encoder encodeObject:self.description 
					   forKey:@"description"];
	}
}

#pragma mark -
#pragma mark MyAlbumItem Protocol
- (MyRestResource*)model {
	return self->_model;
}

@end
