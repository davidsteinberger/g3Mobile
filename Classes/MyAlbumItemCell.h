//
//  TTTableMessageItemCell+g3.h
//  g3Mobile
//
//  Created by David Steinberger on 2/6/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Three20/Three20.h"

//TTTableMessageItemCell
@interface MyAlbumItemCell : TTTableLinkedItemCell {
	CGFloat _imageWidth;
	CGFloat _imageHeight;
	NSString* _description;
	
	UILabel*      _titleLabel;
	UILabel*      _timestampLabel;
	TTImageView*  _imageView2;
	
	TTView* _thumbFrame;
	TTView* _descriptionFrame;
	TTStyledTextLabel* _descriptionLabel;
	BOOL _landscapeModeOn;
}

@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, retain) NSString* description;

@property (nonatomic, readonly, retain) UILabel*      titleLabel;
@property (nonatomic, readonly, retain) UILabel*      timestampLabel;
@property (nonatomic, readonly, retain) TTImageView*  imageView2;

@property (nonatomic, retain) TTView* thumbFrame;
@property (nonatomic, retain) TTView* descriptionFrame;
@property (nonatomic, retain) TTStyledTextLabel* descriptionLabel;
@property (nonatomic, assign) BOOL landscapeModeOn;

@end
