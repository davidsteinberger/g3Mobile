//
//  RKObjectLoaderTTModel.h
//  g3Mobile
//
//  Created by David Steinberger on 6/27/11.
//  Copyright 2011 -. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/Three20/RKObjectLoaderTTModel.h>

@interface RKObjectLoaderTTModel (positionInAlbum)

- (void)objectLoader:(RKObjectLoader*)loader willMapData:(inout id *)mappableData;

@end
