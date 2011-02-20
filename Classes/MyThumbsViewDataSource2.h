//
//  MyThumbsViewDataSource.h
//  g3Mobile
//
//  Created by David Steinberger on 2/5/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Three20/Three20.h"
@class MyThumbsViewModel2;

@interface MyThumbsViewDataSource2 : TTListDataSource {
	MyThumbsViewModel2* _thumbsViewModel;
	BOOL _hasOnlyPhoto;
}

@property (nonatomic, assign) BOOL hasOnlyPhotos;

- (id)initWithItemID:(NSString*)itemID;

@end
