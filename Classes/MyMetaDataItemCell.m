//
//  MyMetaDataItemCell.m
//  g3Mobile
//
//  Created by David Steinberger on 2/16/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyMetaDataItemCell.h"
#import "MyMetaDataItem.h"
#import "NSDateAdditions.h"


@implementation MyMetaDataItemCell

@synthesize title, description, autor, date, tags;
@synthesize background = _background;

- (void)dealloc {
	TT_RELEASE_SAFELY(_background);
	TT_RELEASE_SAFELY(title);
	TT_RELEASE_SAFELY(description);
	TT_RELEASE_SAFELY(autor);
	TT_RELEASE_SAFELY(date);
	TT_RELEASE_SAFELY(tags);
	
	[super dealloc];
}

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)item {  
	return 105;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	UIColor* black = RGBCOLOR(158, 163, 172);

	self.background.backgroundColor = [UIColor blackColor];
	//int width = (self.contentView.orientationWidth > self.contentView.orientationHeight) ? self.contentView.orientationWidth : self.contentView.orientationHeight;
	self.background.frame = self.contentView.bounds; // CGRectMake(0, 0, 320, 150);
	self.background.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight; 

	self.background.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:20 topRight:20 bottomRight:0 bottomLeft:0] next:
							 [TTSolidFillStyle styleWithColor:[UIColor darkGrayColor] next:
							  [TTSolidBorderStyle styleWithColor:black width:1 next:nil]]];
}

#pragma mark -
#pragma mark TTTableViewCell

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)object {
	return _item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
	if (_item != object) {
		//[_item release];
		//_item = [object retain];
		[super setObject:object];
		
		MyMetaDataItem *item = object;
		
		self.title.text = item.title;
		self.description.text = item.description;
		self.autor.text = item.autor;
	
		self.date.text = [item.timestamp formatShortTime];
		self.tags.text = item.tags;
	}
	return;
}

- (TTImageView*)background {
	if (!_background) {
		_background = [[TTImageView alloc] init];
		[self.contentView addSubview:_background];
		[self.contentView sendSubviewToBack:_background];
	}
	return _background;
}

@end
