//
//  MyCredentials.m
//  g3Mobile
//
//  Created by David Steinberger on 12/27/10.
//  Copyright 2010 -. All rights reserved.
//

#import "MySettings.h"
#import "SynthesizeSingleton.h"

#import "MyDatabase.h"


@interface MySettings ()
	@property(nonatomic, readwrite, retain) NSString* username;
	@property(nonatomic, readwrite, retain) NSString* password;
	@property(nonatomic, readwrite, retain) NSString* challenge;
	@property(nonatomic, readwrite, retain) NSString* baseURL;
@end


@implementation MySettings

@synthesize username = _username;
@synthesize password = _password;
@synthesize challenge = _challenge;
@synthesize baseURL = _baseURL;
@synthesize imageQuality = _imageQuality;

SYNTHESIZE_SINGLETON_FOR_CLASS(MySettings);

- (void)save:(NSString*)baseURL 
	 withUsername:(NSString*)username 
 withPassword:(NSString*)password
withChallenge:(NSString*)challenge 
withImageQuality:(float) imageQuality {

	self.baseURL = baseURL;
	self.username = username;
	self.password = password;
	self.challenge = challenge;
	
	self.imageQuality = imageQuality;
}

- (NSString*)baseURL {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString* baseURL = [prefs stringForKey:@"baseURL"];

	if (!baseURL || [baseURL isEqual:@""]) {
		baseURL = [[MyDatabase readSettingsFromDatabase] objectForKey:@"baseURL"];
		//baseURL = @"http://david-steinberger.at/test/index.php";
		self.baseURL = baseURL;
	}
	
	return (baseURL) ? baseURL : @"";
}

- (void)setBaseURL:(NSString*)baseURL {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setObject:baseURL forKey:@"baseURL"];	
	[prefs synchronize];
}

- (NSString*)challenge {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString* challenge = [prefs stringForKey:@"challenge"];
	
	if (!challenge || [challenge isEqual:@""] ) {
		challenge = [[MyDatabase readSettingsFromDatabase] objectForKey:@"challenge"];
		//challenge = @"6b27e31c164657fea05fd0d28fecb120";
		self.challenge = challenge;
	}
	
	return (challenge) ? challenge : @"" ;
}

- (void)setChallenge:(NSString*)challenge {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setObject:challenge forKey:@"challenge"];	
	[prefs synchronize];
}

- (NSString*)username {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString* username = [prefs stringForKey:@"username"];
	
	if (!username) {
		username = [[MyDatabase readSettingsFromDatabase] objectForKey:@"username"];		
		self.username = username;
	}
	
	return (username) ? username : @"username" ;
}

- (void)username:(NSString*)username {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setObject:username forKey:@"username"];	
	[prefs synchronize];
}

- (NSString*)password {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString* password = [prefs stringForKey:@"password"];
	
	if (!password) {
		password = [[MyDatabase readSettingsFromDatabase] objectForKey:@"password"];		
		self.password = password;
	}
	
	return (password) ? password : @"username" ;
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
