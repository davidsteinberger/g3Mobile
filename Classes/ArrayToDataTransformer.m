/*
 * ArrayToDataTransformer.m
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

#import "ArrayToDataTransformer.h"
#import "RKOEntity.h"

@implementation ArrayToDataTransformer

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSValueTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}


+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
	//Take an NSArray archive to NSData
    
    /*
    if ([value isKindOfClass:[NSArray class]]) {
        for (RKOEntity* entity in value) {
            if ([entity isKindOfClass:[RKOEntity class]]) {
                NSLog(@"album get stored: %@", entity.title);
            }
        }
    }
    */
    
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
	return data;
}


- (id)reverseTransformedValue:(id)value {
	//Take NSData unarchive to NSArray
	NSArray *array = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:value];
    
    /*
    if ([array isKindOfClass:[NSArray class]]) {
        for (RKOEntity* entity in array) {
            if ([entity isKindOfClass:[RKOEntity class]]) {
                NSLog(@"album retrieved: %@", entity.title);
            }
        }
    }
    */
    
	return array;
}


@end