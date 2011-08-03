/*
 * MyFacebook.h
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
 * Singleton that makes it easier to interact with Facebook
 */

#import "FBConnect.h"

@interface Facebook (shared)

+ (Facebook *)sharedFacebook;
+ (Facebook *)sharedFacebookWithAppId:(NSString *)app_id;
+ (void)postToFBWithName:(NSString *)name andLink:(NSString *)link andPicture:(NSString *)picture;

// low level access to perform login & logout
- (void)loginWithDelegate:(id <FBSessionDelegate>)delegate;
- (void)logoutWithDelegate:(id <FBSessionDelegate>)delegate;

@end