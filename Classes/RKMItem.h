/*
 * RKMItem.h
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
 * Object mapping for item-resource
 *
 * See RKMTree and RestKit documentation.
 */

// RestKit
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

#import "RKMEntity.h"

@interface RKMTag_Member : NSManagedObject {
}

@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* count;

@end

@interface RKMItem : NSManagedObject {
}

@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSArray* members;
@property (nonatomic, retain) RKMEntity* rEntity;
@property (nonatomic, retain) NSSet* rTags;

- (NSString*)concatenatedTagInfo;

@end
