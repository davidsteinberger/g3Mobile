//
//  Vars.m
//  g3Mobile
//
//  Created by David Steinberger on 5/2/11.
//  Copyright (c) 2011 -. All rights reserved.
//

#import "Vars.h"
#import "Param.h"


@implementation Vars
@dynamic params;

- (void)addParamsObject:(Param *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"params" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"params"] addObject:value];
    [self didChangeValueForKey:@"params" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeParamsObject:(Param *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"params" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"params"] removeObject:value];
    [self didChangeValueForKey:@"params" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addParams:(NSSet *)value {    
    [self willChangeValueForKey:@"params" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"params"] unionSet:value];
    [self didChangeValueForKey:@"params" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeParams:(NSSet *)value {
    [self willChangeValueForKey:@"params" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"params"] minusSet:value];
    [self didChangeValueForKey:@"params" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
