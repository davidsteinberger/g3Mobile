/*
 * RKMTree.m
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

#import "RKMTree.h"

@interface RKMTree()

- (NSArray*) sortEntitiesByRelativePosition;

@end

@implementation RKMTree

@dynamic url;
@dynamic rEntity;

#pragma mark - 
#pragma mark private

- (NSArray*) sortEntitiesByRelativePosition {
    NSSortDescriptor* descriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"relative_position" ascending:YES];
    NSSortDescriptor* descriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"itemID" ascending:YES];
    NSArray* entities = [[self.rEntity allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor1, descriptor2, nil]];
    return entities;
}

- (RKMEntity*) root {
    if ([self.rEntity count] > 0) {
        NSArray* entities = [self sortEntitiesByRelativePosition];
        RKMEntity* entity = [entities objectAtIndex:0];
        return entity;
    } else {
        return nil;
    }
}

- (NSArray*) children {
    if ([self.rEntity count] > 1) {
        NSArray* entities = [self sortEntitiesByRelativePosition];
        NSMutableArray* mc = [NSMutableArray arrayWithArray:entities];
        [mc removeObjectAtIndex:0];
        return [NSArray arrayWithArray:mc];
    } else {
        return nil;
    }
}

@end