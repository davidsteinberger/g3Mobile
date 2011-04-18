/*
 * UIImage+scaleAndRotate.h
 * g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 19/4/2011.
 *
 * Copyright (c) 2011 David Steinberger
 * All rights reserved.
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
 * Resizes and Rotates a UIImage based on its imageOrientation
 *
 * see http://www.iphonedevsdk.com/forum/iphone-sdk-development/1164-rotate-uiimage-help.html
 */

#import <Foundation/Foundation.h>

@interface UIImage (scaleAndRotate)

- (UIImage *)scaleAndRotateImageToMaxResolution:(int)maxResolution;

@end