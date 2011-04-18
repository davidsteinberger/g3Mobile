/*
 * UIImage+scaleAndRotate.m
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

#import "UIImage+scaleAndRotate.h"

@implementation UIImage (scaleAndRotate)

- (UIImage *)scaleAndRotateImageToMaxResolution:(int)maxResolution {
	int kMaxResolution = maxResolution;

	CGImageRef imgRef = self.CGImage;

	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);

	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width / height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}

	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake( CGImageGetWidth(imgRef), CGImageGetHeight(imgRef) );
	CGFloat boundHeight;
	UIImageOrientation orient = self.imageOrientation;
	switch (orient) {
	case UIImageOrientationUp:         //EXIF = 1
		transform = CGAffineTransformIdentity;
		break;

	case UIImageOrientationUpMirrored:         //EXIF = 2
		transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
		transform = CGAffineTransformScale(transform, -1.0, 1.0);
		break;

	case UIImageOrientationDown:         //EXIF = 3
		transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
		transform = CGAffineTransformRotate(transform, M_PI);
		break;

	case UIImageOrientationDownMirrored:         //EXIF = 4
		transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
		transform = CGAffineTransformScale(transform, 1.0, -1.0);
		break;

	case UIImageOrientationLeftMirrored:         //EXIF = 5
		boundHeight = bounds.size.height;
		bounds.size.height = bounds.size.width;
		bounds.size.width = boundHeight;
		transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
		transform = CGAffineTransformScale(transform, -1.0, 1.0);
		transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
		break;

	case UIImageOrientationLeft:         //EXIF = 6
		boundHeight = bounds.size.height;
		bounds.size.height = bounds.size.width;
		bounds.size.width = boundHeight;
		transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
		transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
		break;

	case UIImageOrientationRightMirrored:         //EXIF = 7
		boundHeight = bounds.size.height;
		bounds.size.height = bounds.size.width;
		bounds.size.width = boundHeight;
		transform = CGAffineTransformMakeScale(-1.0, 1.0);
		transform = CGAffineTransformRotate(transform, M_PI / 2.0);
		break;

	case UIImageOrientationRight:         //EXIF = 8
		boundHeight = bounds.size.height;
		bounds.size.height = bounds.size.width;
		bounds.size.width = boundHeight;
		transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
		transform = CGAffineTransformRotate(transform, M_PI / 2.0);
		break;

	default:
		[NSException raise:NSInternalInconsistencyException format:
		 @"Invalid image orientation"];
	}

	UIGraphicsBeginImageContext(bounds.size);

	CGContextRef context = UIGraphicsGetCurrentContext();

	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}

	CGContextConcatCTM(context, transform);

	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return imageCopy;
}


@end