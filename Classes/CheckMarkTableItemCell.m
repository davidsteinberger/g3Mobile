//
//  CheckMarkTableItemCell.m
//  g3Mobile
//
//  Created by David Steinberger on 8/8/11.
//  Copyright 2011 -. All rights reserved.
//

#import "CheckMarkTableItemCell.h"

@implementation CheckMarkTableItemCell
@synthesize item;
@dynamic state;

- (void)setObject:(id)object {
    // _item is defined in TTTableTextItemCell.
    if(_item != object) {
        [super setObject:object];
        self.item = object;
        self.selectionStyle = TTSTYLEVAR(tableSelectionStyle);
        // Set the accessoryType
        if([self.item state])
            self.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (CheckmarkState)state {
    return self.item.state;
}

- (void)setState:(CheckmarkState)state {
    self.item.state = state;
    if(state)
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        self.accessoryType = UITableViewCellAccessoryNone;
}
@end