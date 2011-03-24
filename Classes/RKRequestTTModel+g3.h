//
//  untitled.h
//  g3Mobile
//
//  Created by David Steinberger on 3/6/11.
//  Copyright 2011 -. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/Three20/RKRequestTTModel.h>

@interface RKRequestTTModel (sync)
    
- (id)loadSynchronous:(BOOL)forceReload;

@end