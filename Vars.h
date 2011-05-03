//
//  Vars.h
//  g3Mobile
//
//  Created by David Steinberger on 5/2/11.
//  Copyright (c) 2011 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Param;

@interface Vars : NSManagedObject {
@private
}
@property (nonatomic, retain) NSSet* params;

@end
