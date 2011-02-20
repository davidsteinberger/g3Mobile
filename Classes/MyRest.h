//
//  MyRest.h
//  g3Mobile
//
//  Created by David Steinberger on 1/30/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Three20Network/TTURLRequestDelegate.h";
@class MyRestResource;
@class TTURLRequest;

@protocol MyRestDelegate

- (void)requestDidFinishLoad:(MyRestResource*)resource;
- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error;

@end


@interface MyRest : NSObject <TTURLRequestDelegate> {
@public
	id<MyRestDelegate> _delegate;
	MyRestResource* _restResource;
@private
	NSString* _baseURL;
	NSString* _username;
	NSString* _password;
	NSString* _challenge;
@protected
	NSDictionary* _params;
}

@property (nonatomic, assign) id<MyRestDelegate> delegate;
@property (nonatomic, readonly, retain) MyRestResource* restResource;
@property (nonatomic, retain) NSDictionary* params;

// init
- (id)init;
- (id)initWithUrl:(NSString*)baseUrl withUser:(NSString*)username andPassword:(NSString*)password;

// low-level access
- (NSString*)login:(NSString*)baseUrl withUser:(NSString*)username andPassword:(NSString*)password;
- (void)setValue:(NSString* )value param:(NSString* )param;
- (MyRestResource*)get:(NSString*)url;
- (void)get:(NSString*)url withCallback:(id<MyRestDelegate>)callback;
- (MyRestResource*)post:(NSString*)url;
- (void)put:(NSString*)url;

@end
