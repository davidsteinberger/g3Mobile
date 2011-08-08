//
//  CheckMarkTableItemCell.h
//  g3Mobile
//
//  Created by David Steinberger on 8/8/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Three20/Three20.h"

#import <Foundation/Foundation.h>
#import "CheckMarkTableItem.h"

@interface CheckMarkTableItemCell : TTTableTextItemCell {
    CheckMarkTableItem *item;
}

@property (nonatomic, retain) CheckMarkTableItem *item;
@property (nonatomic, assign) CheckmarkState state;

@end