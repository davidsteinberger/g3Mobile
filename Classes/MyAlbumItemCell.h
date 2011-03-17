/*
 * MyAlbumItemCell.h
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

#import "Three20/Three20.h"

@interface MyAlbumItemCell : TTTableLinkedItemCell {
	CGFloat _imageWidth;
	CGFloat _imageHeight;
	NSString *_description;

	UILabel *_titleLabel;
	UILabel *_timestampLabel;
	TTImageView *_imageView2;

	TTView *_thumbFrame;
	TTView *_descriptionFrame;
	TTStyledTextLabel *_descriptionLabel;
	BOOL _landscapeModeOn;
}

@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, retain) NSString *description;

@property (nonatomic, readonly, retain) UILabel *titleLabel;
@property (nonatomic, readonly, retain) UILabel *timestampLabel;
@property (nonatomic, readonly, retain) TTImageView *imageView2;

@property (nonatomic, retain) TTView *thumbFrame;
@property (nonatomic, retain) TTView *descriptionFrame;
@property (nonatomic, retain) TTStyledTextLabel *descriptionLabel;
@property (nonatomic, assign) BOOL landscapeModeOn;

@end