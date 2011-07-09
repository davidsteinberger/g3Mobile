//
//  Param.h
//  g3Mobile
//
//  Created by David Steinberger on 5/2/11.
//  Copyright (c) 2011 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Param : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSManagedObject * vars;

@end
