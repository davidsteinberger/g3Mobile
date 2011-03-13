//
//  UIImage+resizing.m
//  g3Mobile
//
//  Created by David Steinberger on 1/4/11.
//  Copyright 2011 -. All rights reserved.
//

#import "UIImage+resizing.h"


@implementation UIImage (resizing)

- (UIImage*)scaleToSize:(CGSize)size {
	
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextTranslateCTM(context, 0.0, size.height);
	
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
	
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return scaledImage;
	
}

@end