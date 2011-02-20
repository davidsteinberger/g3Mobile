//
//  MyRestTest.h
//  g3Mobile
//
//  Created by David Steinberger on 1/30/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyRest.h";
@class MyRestResource;

@interface MyRestTest : MyRest {

}

- (MyRestResource*)getItem:(NSString*)itemID;
- (NSArray*)getTree:(NSString*)itemID;
- (MyRestResource*)createAlbum:(NSString*)parentAlbumID withTitle:(NSString*)title andDescription:(NSString*)description andSlug:(NSString*)slug;
- (MyRestResource*)getRootAlbum;

@end
