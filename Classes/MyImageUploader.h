//
//  MyImageUploader.h
//  gallery3
//
//  Created by David Steinberger on 11/21/10.
//  Copyright 2010 -. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyImageUploader : NSObject {
	NSString* _albumID;
	NSString* _returnURL;
}

@property (nonatomic, retain) NSString* albumID;
@property (nonatomic, retain) NSString* returnURL;

- (id)initWithAlbumID:(NSString* ) albumID;

@end
