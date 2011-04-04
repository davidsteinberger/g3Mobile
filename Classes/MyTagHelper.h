/*
 * MyTagHelper.h
 * g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 4/4/2011.
 *
 * Copyright (c) 2011 David Steinberger
 * All rights reserved.
 *
 * This file is part of g3Mobile.
 *
 * g3Mobile is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * g3Mobile is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with g3Mobile.  If not, see <http://www.gnu.org/licenses/>.
 */
/*
 * Helper for the various Rest calls to retrieve tags
 *
 * Informs the delegate via the MyTagHelperDelegate protocol that the tags got loaded
 */

// RestKit
#import <RestKit/RestKit.h>

// MyTagHelperDelegate protocol
#import "MyTagHelperDelegate.h"

@interface MyTagHelper : NSObject <RKObjectLoaderDelegate> {
	id <MyTagHelperDelegate> _delegate;
	NSString *_resourcePath;
	NSMutableArray *_objects;
	BOOL _lock;
}

@property (nonatomic, assign) id <MyTagHelperDelegate> delegate;
@property (nonatomic, retain) NSString *resourcePath;
@property (nonatomic, retain) NSMutableArray *objects;

- (id)initWithResourcePath:(NSString *)resourcePath delegate:(id <MyTagHelperDelegate>)delegate;

@end