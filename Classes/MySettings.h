//
//  MyCredentials.h
//  g3Mobile
//
//  Created by David Steinberger on 12/27/10.
//  Copyright 2010 -. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GlobalSettings \
((MySettings *)[MySettings sharedMySettings])

@interface MySettings : NSObject {
	NSString* _user;
	NSString* _password;
	NSString* _challenge;
	NSString* _baseURL;
	
	float _imageQuality;
}

@property(nonatomic, readonly, retain) NSString* challenge;
@property(nonatomic, readonly, retain) NSString* baseURL;
@property float imageQuality;

+ (MySettings *)sharedMySettings;
- (void)save:(NSString*)baseURL 
	 withUser:(NSString*)user 
 withPassword:(NSString*)password
withChallenge:(NSString*)challenge 
withImageQuality:(float) imageQuality;
- (float)getImageQuality;

@end
