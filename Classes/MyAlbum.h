//
//  MyAlbum.h
//  TTCatalog
//
//  Created by David Steinberger on 11/11/10.
//  Copyright 2010 -. All rights reserved.
//

#import <Three20/Three20.h>

#import <Foundation/Foundation.h>


@interface MyAlbum : NSObject {
	NSMutableDictionary* _array;
	NSMutableArray* _albumEntity;
	BOOL _parentLoaded;
}

@property(nonatomic, retain) NSArray* root;
@property(nonatomic, retain) NSMutableDictionary* array;
@property(nonatomic, retain) NSMutableArray* albumEntity;

- (id)init;
- (id)initWithID:(NSString* )albumId;
- (id)initWithUrl:(NSString* )url;
- (void)dealloc;
- (void)getAlbum:(NSString* )url;
- (void)requestDidFinishLoad:(TTURLRequest*)request;
- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error;

@end