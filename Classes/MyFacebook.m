/*
 * MyFacebook.m
 * g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 14/3/2011.
 * Copyright (c) 2011 David Steinberger
 *
 * This file is part of g3Mobile.
 *
 * g3Mobile is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * g3Mobile is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with g3Mobile.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "MyFacebook.h"
#import "MySettings.h"

static Facebook *sharedFacebook;

@interface Facebook (private)

- (void)setupNotification:(id <FBSessionDelegate>)delegate;

@end

@implementation Facebook (shared)

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Singleton

+ (Facebook *)sharedFacebook {
	return [Facebook sharedFacebookWithAppId:kAppId];
}


+ (Facebook *)sharedFacebookWithAppId:(NSString *)app_id {
	@synchronized(self) {
		if (sharedFacebook == nil) {
			sharedFacebook = [[self alloc] initWithAppId:app_id];
		}
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		if ([defaults objectForKey:@"FBAccessTokenKey"]
		    && [defaults objectForKey:@"FBExpirationDateKey"]) {
			sharedFacebook.accessToken =
			        [defaults objectForKey:@"FBAccessTokenKey"];
			sharedFacebook.expirationDate =
			        [defaults objectForKey:@"FBExpirationDateKey"];
		}
	}

	return sharedFacebook;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public

+ (void)postToFBWithName:(NSString *)name andLink:(NSString *)link andPicture:(NSString *)picture {
	Facebook *facebook = [Facebook sharedFacebook];

	if (![facebook isSessionValid]) {
		return;
	}

	SBJSON *jsonWriter = [[SBJSON new] autorelease];

	NSDictionary *actions = [NSDictionary dictionaryWithObjectsAndKeys:
	                         @"Get involved", @"name",
	                         @"https://github.com/dave8401/g3Mobile", @"link",
	                         nil];

	NSString *finalactions = [jsonWriter stringWithObject:actions];

	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
	                               kAppId, @"app_id",
	                               link, @"link",
	                               picture, @"picture",
	                               name, @"name",
	                               @"", @"caption",
	                               @"", @"description",
	                               @"",  @"message",
	                               finalactions, @"actions",
	                               nil];

	[facebook dialog:@"feed"
	       andParams:params
	     andDelegate:nil];
}


- (void)loginWithDelegate:(id <FBSessionDelegate>)delegate {
	[self setupNotification:delegate];

	if (![self isSessionValid]) {
		NSArray *permissions = [NSArray arrayWithObjects:
		                        @"read_stream", @"publish_stream", @"offline_access", nil];

		// Utilize the notification center to forward the notification to the session
		// delegate; the singleton needs to get notified to store the credentials
		[self authorize:permissions delegate:(id < FBSessionDelegate >)self];
	}
}


- (void)logoutWithDelegate:(id <FBSessionDelegate>)delegate {
	[self setupNotification:delegate];
	[self logout:(id < FBSessionDelegate >)self];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private

- (void)setupNotification:(id <FBSessionDelegate>)sessionDelegate {
	[[NSNotificationCenter defaultCenter] removeObserver:sessionDelegate];

	[[NSNotificationCenter defaultCenter]
	 addObserver:sessionDelegate
	    selector:@selector(fbDidLogin)
	        name:@"fbDidLogin"
	      object:nil];

	[[NSNotificationCenter defaultCenter]
	 addObserver:sessionDelegate
	    selector:@selector(fbDidLogout)
	        name:@"fbDidLogout"
	      object:nil];
}


- (void)fbDidLogin {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[[Facebook sharedFacebook] accessToken] forKey:@"FBAccessTokenKey"];
	[defaults setObject:[[Facebook sharedFacebook] expirationDate] forKey:
	 @"FBExpirationDateKey"];
	[defaults synchronize];

	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"fbDidLogin"
	               object:nil];
}


- (void)fbDidLogout {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"FBAccessTokenKey"];
	[defaults removeObjectForKey:@"FBExpirationDateKey"];
	[defaults synchronize];

	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"fbDidLogout"
	               object:nil];
}


- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"fbDidNotLogin");
}


@end