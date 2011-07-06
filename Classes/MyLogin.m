/*
 * MyLogin.h
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

#import "MyLogin.h"

// Three20
#import "Three20/Three20.h"

@implementation MyLogin

@synthesize viewOnly = _viewOnly;
@synthesize baseURL = _baseURL;
@synthesize username = _username;
@synthesize password = _password;
@synthesize challenge = _challenge;
@synthesize imageQuality = _imageQuality;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

- (void)dealloc {
	TT_RELEASE_SAFELY(_baseURL);
	TT_RELEASE_SAFELY(_username);
	TT_RELEASE_SAFELY(_password);
	TT_RELEASE_SAFELY(_challenge);
	[super dealloc];
}


@end