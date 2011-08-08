//
//  CheckMarkTableItem.h
//  g3Mobile
//
//  Created by David Steinberger on 8/8/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Three20/Three20.h"

typedef enum CheckmarkState {
    CheckmarkNone = NO,
    CheckmarkChecked = YES
} CheckmarkState;

@interface CheckMarkTableItem : TTTableTextItem {
    CheckmarkState state;
}
@property (nonatomic) CheckmarkState state;

+ (id)itemWithText:(NSString *)text;

@end