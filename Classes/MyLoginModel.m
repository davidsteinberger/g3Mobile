/*
 * MyLoginModel.m
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

#import "MyLoginModel.h"

// Others
#import "MyLogin.h"
#import "MySettings.h"

@implementation MyLoginModel

@synthesize credentials = _credentials;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

- (void)dealloc {
	TT_RELEASE_SAFELY(_credentials);
	[super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MyDatabaseRequestDelegate

- (void)login:(MyLogin *)settings {
	if (settings.viewOnly) {
		// the model stores for all other controllers the credentials in singleton
		// GlobalSettings
		[GlobalSettings
		             save:settings.baseURL
		     withUsername:@""
		     withPassword:@""
		    withChallenge:@""
		 withImageQuality:settings.imageQuality];

		settings.challenge = @"";

		// notify the controller that we are done
		[super didUpdateObject:settings atIndexPath:nil];
	}
	else {
		NSString *url = [settings.baseURL stringByAppendingString:@"/rest"];
		TTURLRequest *request = [TTURLRequest requestWithURL:url delegate:self];

		NSString *request_body =
		        [NSString
		         stringWithFormat:@"user=%@&password=%@",
		         [settings.username
		          stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
		         [settings.password
		          stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

		//set request body into HTTPBody.
		request.httpBody = [request_body dataUsingEncoding:NSUTF8StringEncoding];

		request.httpMethod = @"POST";
		request.cachePolicy = TTURLRequestCachePolicyNone;

		request.contentType = @"application/x-www-form-urlencoded";

		id <TTURLResponse> response = [[TTURLDataResponse alloc] init];
		request.response = response;
		TT_RELEASE_SAFELY(response);

		request.userInfo = settings;

		[request send];
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLRequestDelegate

- (void)requestDidFinishLoad:(TTURLRequest *)request {
	TTURLDataResponse *dr = request.response;
	NSData *data = dr.data;

	MyLogin *login = request.userInfo;

	NSString *challenge = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	login.challenge = nil;
	login.challenge =
	        [[challenge substringFromIndex:1] substringToIndex:[challenge length] - 2];
	TT_RELEASE_SAFELY(challenge);

	// the model stores for all other controllers the credentials in singleton GlobalSettings
	[GlobalSettings save:login.baseURL withUsername:login.username withPassword:login.password
	       withChallenge:login.challenge withImageQuality:login.imageQuality];

	// notify the controller that we are done
	[super didUpdateObject:login atIndexPath:nil];
}


- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
	[super didFailLoadWithError:nil];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModel

- (BOOL)isLoaded {
	return YES;
}


- (BOOL)isLoading {
	return NO;
}


@end