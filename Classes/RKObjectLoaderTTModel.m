//
//  RKObjectLoaderTTModel.m
//  g3Mobile
//
//  Created by David Steinberger on 6/27/11.
//  Copyright 2011 -. All rights reserved.
//

#import "RKObjectLoaderTTModel.h"
#import "RKMTree.h"

@implementation RKObjectLoaderTTModel (positionInAlbum)


#pragma mark RKModelLoaderDelegate

- (void)objectLoader:(RKObjectLoader*)loader willMapData:(inout id *)mappableData {
     if (loader.objectMapping.objectClass == [RKMTree class]) {         
         NSArray* origEntities = [*mappableData valueForKeyPath:@"entity"];         
         NSMutableArray* newEntity = [[NSMutableArray alloc] initWithCapacity:[origEntities count]];
         
         int i = 0;
         for (NSDictionary* origEntity in origEntities) {
             NSMutableDictionary* oneEntity = [origEntity mutableCopy];

             // inject the position in the array
             NSMutableDictionary* entity = ([(NSDictionary*)[oneEntity objectForKey:@"entity"] mutableCopy]);
             [entity setObject:[NSString stringWithFormat:@"%i", i] forKey:@"positionInAlbum"];
             
             [oneEntity removeObjectForKey:@"entity"];
             [oneEntity setObject:entity forKey:@"entity"];
             
             [newEntity addObject:oneEntity];
             [oneEntity release];
             [entity release];
             i++;
         }
         
         [*mappableData removeObjectForKey:@"entity"];
         [*mappableData setObject:newEntity forKey:@"entity"];
         [newEntity release];
     }
 }


@end
