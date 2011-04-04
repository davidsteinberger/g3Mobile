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
 * The RKMTree resource holds an array of RKOEntity classes.
 * Each RKOEntity represents an item from gallery3.
 *
 * Note:
 * By purpose the array of RKOEntity objects gets stored in the database via ArrayToDataTransformer:
 * - It ensures that the order of the item is the same as in the gallery3 web-interface
 *   (This could be a bit tricky with RestKit and the current G3 tree rest resource.)
 * - This app fetches only 1 level of an album at a time. So the number of items and the volume of
 *   data is never that much.
 * See <https://github.com/twotoasters/RestKit/blob/master/Docs/
 * MobileTuts%20Introduction%20to%20RestKit/index.html>
 */

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "RKOEntity.h"

@interface RKMTree : RKManagedObject {
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSArray *entities;

@end