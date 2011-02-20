//
//  TTTableMessageItemCell+g3.m
//  g3Mobile
//
//  Created by David Steinberger on 2/6/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyAlbumItemCell.h"
#import "MyAlbumItem.h"

// UI
#import "Three20UI/TTImageView.h"
#import "Three20UI/TTTableMessageItem.h"
#import "Three20UI/UIViewAdditions.h"
#import "Three20Style/UIFontAdditions.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"
#import "Three20Core/NSDateAdditions.h"


static const NSInteger  kMessageTextLineCount       = 4;
static const CGFloat    kDefaultMessageImageWidth   = 80; //34;
static const CGFloat    kDefaultMessageImageHeight  = 80; //34;

static const CGFloat    kThumbAreaWidth = 120;
static const CGFloat    kRowHeight = 75;

@interface MyAlbumItemCell()
	- (NSString*)fixupTextForStyledTextLabel:(NSString*)text;
	- (NSString*)indentString:(NSString*)text;
@end

@implementation MyAlbumItemCell

@synthesize imageWidth = _imageWidth;
@synthesize imageHeight = _imageHeight;
@synthesize description = _description;

@synthesize titleLabel = _titleLabel;
@synthesize timestampLabel = _timestampLabel;
@synthesize imageView2 = _imageView2;

@synthesize thumbFrame = _thumbFrame;
@synthesize descriptionFrame = _descriptionFrame;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize landscapeModeOn = _landscapeModeOn;

- (void)dealloc {
	TT_RELEASE_SAFELY(_description);
	
	TT_RELEASE_SAFELY(_titleLabel);
	TT_RELEASE_SAFELY(_timestampLabel);
	TT_RELEASE_SAFELY(_imageView2);
	
	TT_RELEASE_SAFELY(_thumbFrame);
	TT_RELEASE_SAFELY(_descriptionFrame);
	TT_RELEASE_SAFELY(_descriptionLabel);

	[super dealloc];
}

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)item {  
	// Set the height for the particular cell
	//return ((MyAlbumItem*)item).height + 20;
	return kRowHeight + 2 * kTableCellSmallMargin;
}

#pragma mark -
#pragma mark UIView

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
	[super prepareForReuse];
	[_imageView2 unsetImage];
	_titleLabel.text = nil;
	_timestampLabel.text = nil;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	// identify orientation
	self.landscapeModeOn = (self.contentView.orientationWidth > self.contentView.orientationHeight) ? NO : YES;

	UIColor* black = RGBCOLOR(158, 163, 172);
	// try to fit it in with max-length
	float factor = self.imageWidth / kThumbAreaWidth;

	TTDASSERT(self.imageWidth);
	CGFloat imageWidth = self.imageWidth / factor;
	CGFloat imageHeight = self.imageHeight / factor;
	
	// if it's too heigh --> shrink it down
	if (imageHeight > kRowHeight) {
		imageHeight = kRowHeight;
		imageWidth = imageWidth * (kRowHeight / (self.imageHeight / factor));
	}
	
	// center
	CGFloat left = ((kThumbAreaWidth + 2 * (kTableCellSmallMargin/2)) - imageWidth ) / 2;
	CGFloat top = ((kRowHeight + 2 * kTableCellSmallMargin) - imageHeight) / 2;
	
	// image-view: rounded + white background
	_imageView2.style = TTSTYLE(rounded);
	_imageView2.backgroundColor = [UIColor clearColor];
	
	if (_imageView2) {
		_imageView2.frame = CGRectMake(left, top,
									   imageWidth, imageHeight);
		
		// background
		self.thumbFrame.frame = CGRectMake(left-5, top-5,
										   imageWidth+10, imageHeight+10);
		self.thumbFrame.backgroundColor = [UIColor clearColor];
		
		// draw a thin border
		self.thumbFrame.style = [TTShapeStyle styleWithShape:[TTRectangleShape shape] next:
								 [TTSolidFillStyle styleWithColor:[UIColor clearColor] next:
								 [TTSolidBorderStyle styleWithColor:black width:0.1 next:nil]]];
		
		left = kTableCellSmallMargin + kThumbAreaWidth + kTableCellSmallMargin + 10;
	} else {
		left = kTableCellMargin;
	}
	
	// get new dimensions
	CGFloat width = self.contentView.width - left;
	top = kTableCellSmallMargin;
	
	if (_timestampLabel.text.length) {
		_timestampLabel.alpha = !self.showingDeleteConfirmation;
		[_timestampLabel sizeToFit];
		_timestampLabel.left = self.contentView.width - (_timestampLabel.width + kTableCellSmallMargin);
		_timestampLabel.top = 5;
		_titleLabel.width -= _timestampLabel.width + kTableCellSmallMargin*2;
	} else {
		_timestampLabel.frame = CGRectZero;
	}
	
	_titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	_titleLabel.numberOfLines = 0;
	if (_titleLabel.text.length) {
		if (self.landscapeModeOn) {
			_titleLabel.frame = CGRectMake(left, 
										   top, 
										   _timestampLabel.ttScreenX - left - kTableCellSmallMargin, 
										   _titleLabel.font.ttLineHeight);
			top += _titleLabel.height;
		} else {
			_titleLabel.frame = CGRectMake(left, 
										   (kRowHeight + 2 * kTableCellSmallMargin) / 2 -  _titleLabel.font.ttLineHeight, 
										   self.contentView.width - left, 
										   _titleLabel.font.ttLineHeight * 2);
			top += _titleLabel.height;
		}
	} else {
		_titleLabel.frame = CGRectZero;
	}
	
	self.detailTextLabel.frame = CGRectZero;
	
	//NSLog(@"kRowHeight: %f, %f", kRowHeight, top);
	CGFloat textHeight = kRowHeight - top + 5;
	
	
	// SpeechBubble with text
	TTStyledText* text = nil;
	if (self.description != nil && ![self.description isEqual:@""]) {
		self.descriptionFrame.frame = CGRectMake(left, top, width-20, textHeight);

		if ([self.description length] <= 160) {
			text = [TTStyledText textFromXHTML:[self indentString:[self fixupTextForStyledTextLabel:self.description]] lineBreaks:YES URLs:YES];
		}
		else {
			//TTDCONDITIONLOG([self.description length] > 50, @"text: %@", self.description);
			text = [TTStyledText textFromXHTML:
					[self indentString:
					 [self fixupTextForStyledTextLabel:
					  [[self.description substringToIndex:160]
					  stringByAppendingString:@"..."]]] lineBreaks:YES URLs:YES];
		}
	} else {
		self.descriptionFrame.frame = CGRectZero;
	}

	self.descriptionFrame.backgroundColor = [UIColor clearColor];
	TTStyle* speechBubble = [TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:5 pointLocation:55
																				   pointAngle:90
																					pointSize:CGSizeMake(20,10)] next:
							 [TTLinearGradientFillStyle styleWithColor1:RGBCOLOR(255, 255, 255)
																 color2:[UIColor colorWithWhite:0.8 alpha:0.1] next:
							  [TTSolidBorderStyle styleWithColor:black width:1 next:nil]]];
	
	//[TTSolidFillStyle styleWithColor:[UIColor lightGrayColor]
	//RGBCOLOR(216, 221, 231)
	
	 
	self.descriptionLabel.frame = self.descriptionFrame.bounds;
	self.descriptionLabel.text = text;
	self.descriptionLabel.backgroundColor = [UIColor clearColor];
	self.descriptionLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
	self.descriptionLabel.textColor = TTSTYLEVAR(linkTextColor);
	self.descriptionLabel.contentInset = UIEdgeInsetsMake(18, 14, 14, 14);

	//[self.descriptionLabel sizeToFit];
	
	[self.descriptionFrame addSubview: _descriptionLabel];

	self.descriptionFrame.style = speechBubble;		
	
	if (!self.landscapeModeOn) {
		self.descriptionFrame.frame = CGRectZero;
		self.descriptionLabel.frame = CGRectZero;
	}
}


#pragma mark -
#pragma mark TTTableViewCell

- (id)object {
	return _item;  
}

- (void)setObject:(id)object {
	if (_item != object) {
		[super setObject:object];
		
		if ([object isKindOfClass:[MyAlbumItem class]]) {
			MyAlbumItem* item = (MyAlbumItem*)object;
			self.imageWidth = item.width;
			self.imageHeight = item.height;
			self.description = item.description;
			
			if (item.title.length) {
				self.titleLabel.text = item.title;
			}
			if (item.timestamp) {
				self.timestampLabel.text = [item.timestamp formatShortTime];
			}
			if (item.imageURL) {
				self.imageView2.urlPath = item.imageURL;
			}
		} else {
			self.imageWidth = 100;
			self.imageHeight = 80;
			self.description = @"";
		}
	}
}

#pragma mark -
#pragma mark public

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)titleLabel {
	if (!_titleLabel) {
		_titleLabel = [[UILabel alloc] init];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.highlightedTextColor = [UIColor whiteColor];
		_titleLabel.font = TTSTYLEVAR(tableFont);
		_titleLabel.contentMode = UIViewContentModeLeft;
		[self.contentView addSubview:_titleLabel];
	}
	return _titleLabel;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)timestampLabel {
	if (!_timestampLabel) {
		_timestampLabel = [[UILabel alloc] init];
		_timestampLabel.font = TTSTYLEVAR(tableTimestampFont);
		_timestampLabel.textColor = TTSTYLEVAR(timestampTextColor);
		_timestampLabel.highlightedTextColor = [UIColor whiteColor];
		_timestampLabel.contentMode = UIViewContentModeLeft;
		[self.contentView addSubview:_timestampLabel];
	}
	return _timestampLabel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTImageView*)imageView2 {
	if (!_imageView2) {
		_imageView2 = [[TTImageView alloc] init];
		//    _imageView2.defaultImage = TTSTYLEVAR(personImageSmall);
		//    _imageView2.style = TTSTYLE(threadActorIcon);
		[self.contentView addSubview:_imageView2];
	}
	return _imageView2;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTView*)thumbFrame {
	if (!_thumbFrame) {
		_thumbFrame = [[TTView alloc] init];		
		[self.contentView addSubview:_thumbFrame];
		[self.contentView sendSubviewToBack:_thumbFrame];
	}
	return _thumbFrame;
}

- (TTView*)descriptionFrame {
	if (!_descriptionFrame) {
		_descriptionFrame = [[TTView alloc] init];
		[self.contentView addSubview:_descriptionFrame];
		[self.contentView sendSubviewToBack:_descriptionFrame];
	}
	return _descriptionFrame;
}

- (TTStyledTextLabel*)descriptionLabel {
	if (!_descriptionLabel) {
		_descriptionLabel = [[TTStyledTextLabel alloc] init];
	}
	return _descriptionLabel;
}

#pragma mark -
#pragma mark private

- (NSString*)fixupTextForStyledTextLabel:(NSString*)text {
	text = [text stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
	text = [text stringByReplacingOccurrencesOfString:@"*" withString:@"&#42;"];
	text = [text stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
	text = [text stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
	return text;
}

- (NSString*)indentString:(NSString*)text {
	text = [[@"<i><b>" stringByAppendingString:text] stringByAppendingString:@"</b></i>"];
	return text;
}



@end
