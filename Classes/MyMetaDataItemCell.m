/*
 * MyMetaDataItemCell.m
 * #g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 16/3/2011.
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

#import "MyMetaDataItemCell.h"

// Three20
#import "Three20Core/NSDateAdditions.h"

// Custom cells (three20)
#import "MyMetaDataItem.h"

@implementation MyMetaDataItemCell

@synthesize title, description, autor, date, tags;
@synthesize background = _background;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

- (void)dealloc {
	TT_RELEASE_SAFELY(_background);
	TT_RELEASE_SAFELY(title);
	TT_RELEASE_SAFELY(description);
	TT_RELEASE_SAFELY(autor);
	TT_RELEASE_SAFELY(date);
	TT_RELEASE_SAFELY(tags);

	[super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView(UIViewHierarchy)

- (void)layoutSubviews {
	[super layoutSubviews];

	UIColor *black = RGBCOLOR(158, 163, 172);

	self.background.backgroundColor = [UIColor blackColor];
	self.background.frame = self.contentView.bounds;
	self.background.autoresizingMask = UIViewAutoresizingFlexibleWidth |
	                                   UIViewAutoresizingFlexibleHeight;

	self.background.style =
	        [TTShapeStyle
	         styleWithShape:[TTRoundedRectangleShape
	                         shapeWithTopLeft:20
	                                 topRight:20
	                              bottomRight:0
	                               bottomLeft:0] next:
	         [TTSolidFillStyle styleWithColor:[UIColor darkGrayColor] next:
	          [TTSolidBorderStyle styleWithColor:black width:1 next:nil]]];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell

- (void)setObject:(id)object {
	if (_item != object) {
		[super setObject:object];

		if ([object isKindOfClass:[MyMetaDataItem class]]) {
			MyMetaDataItem *item = (MyMetaDataItem *)object;

			self.title.text = item.title;

			self.description.text = item.description;
			self.autor.text = item.autor;

			self.date.text = [item.timestamp formatShortTime];
			self.tags.text = item.tags;
		}
		else {
			self.title.text = @"";
			self.description.text = @"";
			self.autor.text = @"";
		}
	}
}


+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)item {
	return 105;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark private

- (TTImageView *)background {
	if (!_background) {
		_background = [[TTImageView alloc] init];
		[self.contentView addSubview:_background];
		[self.contentView sendSubviewToBack:_background];
	}
	return _background;
}


@end