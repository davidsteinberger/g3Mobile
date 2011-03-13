//
//  Response.h
//  RKTwitter
//
//  Created by David Steinberger on 2/22/11.
//  Copyright 2011 -. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "RKOEntity.h"

@interface RKMTree : RKManagedObject {
}

@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSArray* entities;

@end
