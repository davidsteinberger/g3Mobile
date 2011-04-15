//
//  MyViewController.h
//  g3Mobile
//
//  Created by David Steinberger on 4/11/11.
//  Copyright 2011 -. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MyViewController 

// Reloads after an action was taken
- (void)reloadViewController:(BOOL)goBack;

@end
