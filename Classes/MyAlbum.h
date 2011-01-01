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
	NSString* _albumID;
	NSMutableDictionary* _array;
	NSMutableDictionary* _albumEntity;
}

@property(nonatomic, retain) NSString* albumID;
@property(nonatomic, retain) NSMutableDictionary* array;
@property(nonatomic, retain) NSMutableDictionary* albumEntity;

- (id)init;
- (id)initWithID:(NSString* )albumId;
- (id)initWithUrl:(NSString* )url;
- (void)dealloc;
- (void)getAlbum:(NSString* )url;
- (void)requestDidFinishLoad:(TTURLRequest*)request;
- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error;
+ (void)updateFinished;
+ (void)updateFinishedWithItemID:(NSString*)itemID;
+ (void)updateFinishedWithItemURL:(NSString*)url;

@end