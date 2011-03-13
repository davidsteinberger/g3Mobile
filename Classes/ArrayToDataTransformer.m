//
//  EntitiesTransformer.m
//  RKTwitter
//
//  Created by David Steinberger on 2/28/11.
//  Copyright 2011 -. All rights reserved.
//

#import "ArrayToDataTransformer.h"


@implementation ArrayToDataTransformer

+ (BOOL)allowsReverseTransformation {
    return YES;
}

+ (Class)transformedValueClass {
    return [NSData class];
}

- (id)transformedValue:(id)value {
    //Take an NSArray archive to NSData
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    return data;
}

- (id)reverseTransformedValue:(id)value {
    //Take NSData unarchive to NSArray 
    NSArray *array = (NSArray*)[NSKeyedUnarchiver unarchiveObjectWithData:value];
    return array;
}

@end
