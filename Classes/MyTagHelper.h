//
//  RKTagHelper.h
//  g3Mobile
//
//  Created by David Steinberger on 3/3/11.
//  Copyright 2011 -. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "MyTagHelperDelegate.h"


@interface MyTagHelper : NSObject <RKObjectLoaderDelegate> {
	id<MyTagHelperDelegate> _delegate;
	NSString* _resourcePath;
	NSMutableArray* _objects;
	BOOL _lock;
}

@property (nonatomic, assign) id<MyTagHelperDelegate> delegate;
@property (nonatomic, retain) NSString* resourcePath;
@property (nonatomic, retain) NSMutableArray* objects;

- (id)initWithResourcePath:(NSString*)resourcePath delegate:(id<MyTagHelperDelegate>)delegate;

@end
