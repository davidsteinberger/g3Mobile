//
//  TTTableViewDataSource+g3.h
//  g3Mobile
//
//  Created by David Steinberger on 2/16/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Three20/Three20.h"

@interface TTTableViewDataSource (xib)

- (UITableViewCell*)createNewCellWithClass:(Class)klaz
								identifier:(NSString*)identifier;

@end
