/*
 * RKMTree.h
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
 * The RKMTree resource holds an unsorted list of RKMEntity classes.
 * Each RKMEntity represents an item entity from gallery3.
 *
 * Note:
 * The tree is stored as an unsorted list (NSSet) of entities.
 * Core data cannot handle sorted lists. To reconstruct the ordering
 * a 'relative_position' attribute is used.
 */

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "RKMEntity.h"

@interface RKMTree : NSManagedObject {
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSSet *rEntity;

- (RKMEntity*) root;
- (NSArray*) children;

@end