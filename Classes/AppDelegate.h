/*
 * AppDelegate.h
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
/*
 * The UIApplicationDelegate
 *
 * The UIApplicationDelegate handles start-up of the application.
 * It initializes Three20: url-maps, request-queue size etc.
 * It initializes RestKit: used to map rest-resources to local objects
 */

#import "MyLoginDelegate.h"

@class Reachability;

@interface AppDelegate : NSObject <UIApplicationDelegate, MyLoginDelegate> {
	NSString* _user;
	NSString* _password;
	Reachability* hostReach;
@public
	NSString* _challenge;
	NSString* _baseURL;
    BOOL _isRestKitLoad;
}

@property(nonatomic, retain) NSString* challenge;
@property(nonatomic, retain) NSString* baseURL;

@end

