/*
 * RKOEntity.h
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
 * Object mapping for tree-resource
 *
 * This class is used to map all relevant attributes from an item that's returned as part of the
 * rest tree-response.
 * The entity is not directly stored in the core-data cache (see RKMTree.h). Therefore it's
 * subclassed from RKObject (instead of RKManagedObject).
 */

// RestKit
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@interface RKMEntity : NSManagedObject {
}

@property (nonatomic, retain) NSString *itemID;
@property (nonatomic, retain) NSString *parent;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *thumb_url_public;
@property (nonatomic, retain) NSString *thumb_url;
@property (nonatomic, retain) NSString *resize_url_public;
@property (nonatomic, retain) NSString *resize_url;
@property (nonatomic, retain) NSString *file_url;
@property (nonatomic, retain) NSString *file_url_public;
@property (nonatomic, retain) NSString *thumb_width;
@property (nonatomic, retain) NSString *thumb_height;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSNumber* relative_position;

@end