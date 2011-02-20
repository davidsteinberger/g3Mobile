//
//  MyMetaDataItem.m
//  g3Mobile
//
//  Created by David Steinberger on 2/16/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyMetaDataItem.h"


@implementation MyMetaDataItem

@synthesize model = _model;
@synthesize title = _title;
@synthesize description = _description;
@synthesize autor = _autor;
@synthesize timestamp = _timestamp;
@synthesize tags = _tags;

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemWithTitle:(NSString*)title model:(MyRestResource*)model description:(NSString*)description autor:(NSString*)autor timestamp:(NSDate*)timestamp tags:(NSString*)tags {
	MyMetaDataItem* item = [[[self alloc] init] autorelease];
	item.model = model;
	item.title = title;
	item.description = description;
	item.autor = autor;
	item.timestamp = timestamp;
	item.tags = tags;
	return item;
}

#pragma mark -
#pragma mark NSObject

- (id)init {  
	if (self = [super init]) {  
		
	}
	
	return self;
}


- (void)dealloc {  
	TT_RELEASE_SAFELY(_model);
	TT_RELEASE_SAFELY(_title);
	TT_RELEASE_SAFELY(_description);
	TT_RELEASE_SAFELY(_autor);
	TT_RELEASE_SAFELY(_timestamp);
	TT_RELEASE_SAFELY(_tags);
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder {
    if (self = [super initWithCoder:decoder]) {  
		self.title = [decoder decodeObjectForKey:@"title"];
		self.description = [decoder decodeObjectForKey:@"description"];
		self.autor = [decoder decodeObjectForKey:@"autor"];
		self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
		self.tags = [decoder decodeObjectForKey:@"tags"];
	}
	
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {  
    [super encodeWithCoder:encoder];
	
	if (self.title)
		[encoder encodeObject:self.title
					  forKey:@"title"];
	
	if (self.description)
		[encoder encodeObject:self.description
					   forKey:@"description"];
	
	if (self.autor)
		[encoder encodeObject:self.autor
					 forKey:@"autor"];
	
	if (self.timestamp)
		[encoder encodeObject:self.timestamp
					   forKey:@"timestamp"];
	
	if (self.tags)
		[encoder encodeObject:self.tags
					   forKey:@"tags"];
	
	return;
}

@end
