//
//  CheckMarkTableItem.m
//  g3Mobile
//
//  Created by David Steinberger on 8/8/11.
//  Copyright 2011 -. All rights reserved.
//

#import "CheckMarkTableItem.h"
#import "MySettings.h"

@implementation CheckMarkTableItem
@synthesize state;

+ (id)itemWithText:(NSString *)text {
    CheckMarkTableItem *item = [[[self alloc] init] autorelease];
    item.text = text;
    
    return item;
}

- (void)setState:(CheckmarkState)checked {
    state = checked;
    GlobalSettings.showFBOnUploader = checked;
}

- (CheckmarkState) state {
    return GlobalSettings.showFBOnUploader;
}

-(void) dealloc{
    [super dealloc];
}

@end