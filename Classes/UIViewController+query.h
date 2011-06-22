//
//  UIViewController+params.h
//  g3Mobile
//
//  Created by David Steinberger on 1/5/11.
//  Copyright 2011 -. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;

@interface UIViewController(query) 

- (void)setQuery:(NSDictionary*)query;

@end