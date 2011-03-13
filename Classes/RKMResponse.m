//
//  Response.m
//  RKTwitter
//
//  Created by David Steinberger on 2/22/11.
//  Copyright 2011 -. All rights reserved.
//

#import "RKMResponse.h"
#import "ArrayToDataTransformer.h"


@implementation RKMResponse

@dynamic url;
@dynamic entities;


+ (NSDictionary*)elementToPropertyMappings {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			@"url", @"url", nil];
}

+ (NSDictionary*)elementToRelationshipMappings {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			@"entities", @"entity.entity",
			@"url", @"url", 
			nil];
}

+ (NSString*)primaryKeyProperty {
	return @"url";
}
			

@end
