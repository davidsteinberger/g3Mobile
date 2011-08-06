/*
 * FBLoginButton.m
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

#import "FBLoginButton.h"
#import "MySettings.h"

@interface FBLoginButton (private)

- (UIImage *)buttonImage;
- (UIImage *)buttonHighlightedImage;

@end

@implementation FBLoginButton

@synthesize isLoggedIn = _isLoggedIn;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}


- (id)init {
	if ( (self = [super initWithFrame:CGRectZero]) ) {
		self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

		_isLoggedIn = [[Facebook sharedFacebook] isSessionValid];
		[self updateImage];

		if (_isLoggedIn) {
			[self removeTarget:self action:@selector(fbLogin:) forControlEvents:
			 UIControlEventTouchUpInside];
			[self addTarget:self action:@selector(fbLogout:) forControlEvents:
			 UIControlEventTouchUpInside];
		}
		else {
			[self removeTarget:self action:@selector(fbLogout:) forControlEvents:
			 UIControlEventTouchUpInside];
			[self addTarget:self action:@selector(fbLogin:) forControlEvents:
			 UIControlEventTouchUpInside];
		}

		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		    selector:@selector(fbDidLogin:)
		        name:MyFBDidLogin
		      object:nil];

		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		    selector:@selector(fbDidLogout:)
		        name:MyFBDidLogout
		      object:nil];

		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		    selector:@selector(fbDidNotLogin:)
		        name:MyFBDidNotLogin
		      object:nil];
	}
	return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private

/**
 * To be called whenever the login status is changed
 */
- (void)updateImage {
	self.imageView.image = [self buttonImage];
	[self setImage:[self buttonImage]
	      forState:UIControlStateNormal];

	[self setImage:[self buttonHighlightedImage]
	      forState:UIControlStateHighlighted | UIControlStateSelected];
}


/**
 * return the regular button image according to the login status
 */
- (UIImage *)buttonImage {
	if (_isLoggedIn) {
		return [UIImage imageNamed:@"FBConnect.bundle/images/LogoutNormal.png"];
	}
	else {
		return [UIImage imageNamed:@"FBConnect.bundle/images/LoginNormal.png"];
	}
}


/**
 * return the highlighted button image according to the login status
 */
- (UIImage *)buttonHighlightedImage {
	if (_isLoggedIn) {
		return [UIImage imageNamed:@"FBConnect.bundle/images/LogoutPressed.png"];
	}
	else {
		return [UIImage imageNamed:@"FBConnect.bundle/images/LoginPressed.png"];
	}
}


// Perform FB login
- (void)fbLogin:(id)sender {
	[[Facebook sharedFacebook] login];
}


// Perform FB logout
- (void)fbLogout:(id)sender {
	[[Facebook sharedFacebook] logout];
}


/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin:(NSNotification *)notification {
	_isLoggedIn = [[Facebook sharedFacebook] isSessionValid];
	[self updateImage];
	[self removeTarget:self action:@selector(fbLogin:) forControlEvents:
	 UIControlEventTouchUpInside];
	[self addTarget:self action:@selector(fbLogout:) forControlEvents:
	 UIControlEventTouchUpInside];

	SBJSON *jsonWriter = [[SBJSON new] autorelease];

	NSDictionary *propertyvalue = [NSDictionary dictionaryWithObjectsAndKeys:
	                               @"My Gallery3 Website", @"text",
	                               GlobalSettings.baseURL, @"href",
	                               nil];
	NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:propertyvalue,
	                            @"Checkout my Images on", nil];

	NSDictionary *actions = [NSDictionary dictionaryWithObjectsAndKeys:
	                         @"Get involved", @"name",
	                         @"https://github.com/dave8401/g3Mobile", @"link",
	                         nil];

	NSString *finalproperties = [jsonWriter stringWithObject:properties];
	NSString *finalactions = [jsonWriter stringWithObject:actions];

	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
	                               kAppId, @"app_id",
	                               GlobalSettings.baseURL, @"link",
	                               @"https://fbcdn-photos-a.akamaihd.net/photos-ak-snc1/v43/151/153647701377559/app_1_153647701377559_3550.gif",
	                               @"picture",
	                               @"I'm using g3Mobile to access my images on Gallery3",
	                               @"name",
	                               @"It has never been easier to access Gallery3", @"caption",
	                               @"", @"description",
	                               @"",  @"message",
	                               finalproperties, @"properties",
	                               finalactions, @"actions",
	                               nil];

	[[Facebook sharedFacebook] dialog:@"feed"
	                        andParams:params
	                      andDelegate:self];
}


/**
 * Called when the user canceled the authorization dialog.
 */
- (void)fbDidNotLogin:(NSNotification *)notification {
	_isLoggedIn = NO;
	[self updateImage];
}


/**
 * Called when the user logged out.
 */
- (void)fbDidLogout:(NSNotification *)notification {
	_isLoggedIn = [[Facebook sharedFacebook] isSessionValid];
	[self updateImage];
	[self removeTarget:self action:@selector(fbLogout:) forControlEvents:
	 UIControlEventTouchUpInside];
	[self addTarget:self action:@selector(fbLogin:) forControlEvents:
	 UIControlEventTouchUpInside];
}


@end