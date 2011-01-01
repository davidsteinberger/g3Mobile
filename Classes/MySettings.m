//
//  MyCredentials.m
//  g3Mobile
//
//  Created by David Steinberger on 12/27/10.
//  Copyright 2010 -. All rights reserved.
//

#import "MySettings.h"
#import "SynthesizeSingleton.h"


@interface MySettings ()
	@property(nonatomic, readwrite, retain) NSString* user;
	@property(nonatomic, readwrite, retain) NSString* password;
	@property(nonatomic, readwrite, retain) NSString* challenge;
	@property(nonatomic, readwrite, retain) NSString* baseURL;
@end


@implementation MySettings

@synthesize user = _user;
@synthesize password = _password;
@synthesize challenge = _challenge;
@synthesize baseURL = _baseURL;
@synthesize imageQuality = _imageQuality;

SYNTHESIZE_SINGLETON_FOR_CLASS(MySettings);

- (void)save:(NSString*)baseURL 
	 withUser:(NSString*)user 
 withPassword:(NSString*)password
withChallenge:(NSString*)challenge 
withImageQuality:(float) imageQuality {

	self.baseURL = baseURL;
	self.user = user;
	self.password = password;
	self.challenge = challenge;
	
	self.imageQuality = imageQuality;
	
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:self.baseURL forKey:@"baseURL"];
	[prefs setObject:self.user forKey:@"user"];
	[prefs setObject:self.password forKey:@"password"];
	[prefs setObject:self.challenge forKey:@"challenge"];	
	[prefs setFloat:self.imageQuality forKey:@"imageQuality"];
	
	[prefs synchronize];
}

- (NSString*)baseUrl {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	return [prefs stringForKey:@"baseURL"];
}

- (NSString*)challenge {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	return [prefs stringForKey:@"challenge"];
}

- (void)setImageQuality:(float)imageQuality {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setFloat:imageQuality forKey:@"imageQuality"];	
	[prefs synchronize];	
}

- (float)imageQuality {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	return [prefs floatForKey:@"imageQuality"];
}

@end
