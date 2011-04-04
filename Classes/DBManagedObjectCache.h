/*
 * DBManagedObjectCache.h
 * g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 2/4/2011.
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
 * This class manages the object-cache for RestKit.
 *
 * An implementation of the RestKit object cache. The object cache is
 * used to return locally cached objects that live in a known resource path.
 * This can be used to avoid trips to the network.
 */

#import <RestKit/CoreData/RKManagedObjectCache.h>

@interface DBManagedObjectCache : NSObject <RKManagedObjectCache> {
}

@end