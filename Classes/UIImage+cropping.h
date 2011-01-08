//
//  UIImage+cropping.h
//  g3Mobile
//
//  Created by David Steinberger on 1/5/11.
//  Copyright 2011 -. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage(cropping)

+ (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;

@end
