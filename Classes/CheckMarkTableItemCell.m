/*
 * CheckMarkTableItemCell.m
 * g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 14/3/2011.
 * Copyright (c) 2011 David Steinberger
 *
 * This file is part of g3Mobile.
 *
 * g3Mobile is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * g3Mobile is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with g3Mobile.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "CheckMarkTableItemCell.h"

@implementation CheckMarkTableItemCell
@synthesize item;
@dynamic state;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

- (void)dealloc {
	TT_RELEASE_SAFELY(item);
	[super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell

- (void)setObject:(id)object {
	// _item is defined in TTTableTextItemCell.
	if (_item != object) {
		[super setObject:object];
		self.item = object;

		self.selectionStyle = TTSTYLEVAR(tableSelectionStyle);

		// Set the accessoryType
		if ([self.item state])
			self.accessoryType = UITableViewCellAccessoryCheckmark;
		else
			self.accessoryType = UITableViewCellAccessoryNone;
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -

- (CheckmarkState)state {
	return self.item.state;
}


- (void)setState:(CheckmarkState)state {
	self.item.state = state;
	if (state)
		self.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		self.accessoryType = UITableViewCellAccessoryNone;
}


@end