//
//  MyRestTest.m
//  g3Mobile
//
//  Created by David Steinberger on 1/30/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyRestTest.h"
#import "MySettings.h"
#import "MyRestResource.h"

@implementation MyRestTest

- (MyRestResource*)getItem:(NSString*)itemID {
	return [self get:
			[[GlobalSettings.baseURL stringByAppendingString:@"/rest/item/"] stringByAppendingString:itemID] ];
}

- (NSArray*)getTree:(NSString*)itemID {
	MyRestResource* tree = [self get:
	 [[[GlobalSettings.baseURL 
		stringByAppendingString:@"/rest/tree/"] 
	   stringByAppendingString:itemID] 
	  stringByAppendingString:@"?depth=1"] ];
	//NSLog(@"tree.entity: %@", tree.entity);
	return (NSArray*)tree.entity;
}

- (MyRestResource*)createAlbum:(NSString*)parentAlbumID withTitle:(NSString*)title andDescription:(NSString*)description andSlug:(NSString*)slug {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
	                        @"album", @"type",
	                        title, @"name",
	                        title, @"title",
	                        description, @"description",
	                        slug, @"slug",
	                        nil];
	
	parentAlbumID = (parentAlbumID) ? parentAlbumID : @"1";
	
	return [self post:[[GlobalSettings.baseURL stringByAppendingString:@"/rest/item/"] stringByAppendingString:parentAlbumID]];
}

- (MyRestResource*)getRootAlbum {
	return [self get:[GlobalSettings.baseURL stringByAppendingString:@"/rest/item/1"]];
}

@end
