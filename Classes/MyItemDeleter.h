//
//  MyItemDeleter.h
//  Gallery3
//
//  Created by David Steinberger on 11/23/10.
//  Copyright 2010 -. All rights reserved.
//

#import "Three20/Three20.h"
#import <Foundation/Foundation.h>


@interface MyItemDeleter : NSObject {

}

+ (id) initWithItemID:(NSString *)itemID;
+ (id) initWithItemID:(NSString *)itemID type:(NSString *)type;

@end
