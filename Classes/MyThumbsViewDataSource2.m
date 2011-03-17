/*
 * MyThumbsViewDataSource2.m
 * #g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 15/3/2011.
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

#import "MyThumbsViewDataSource2.h"

// Datasource and custom cells (three20)
#import "MyMetaDataItem.h"
#import "MyMetaDataItemCell.h"
#import "MyAlbumItem.h"
#import "MyAlbumItemCell.h"

// Settings
#import "MySettings.h"

// RestKit
#import <RestKit/RestKit.h>
#import <RestKit/Three20/RKRequestTTModel.h>
#import "RKMTree.h"

@implementation MyThumbsViewDataSource2

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

// Initializes Datasource with a given item-id (album-id)
- (id)initWithItemID:(NSString *)itemID {
	if (self = [super init]) {
		NSString *treeResourcePath = [[[@""
		                                stringByAppendingString:@"/rest/tree/"]
		                               stringByAppendingString:itemID]
		                              stringByAppendingString:@"?depth=1"];

		[RKRequestTTModel setDefaultRefreshRate:3600];
		RKRequestTTModel *myModel = [[RKRequestTTModel alloc]
		                             initWithResourcePath:treeResourcePath
		                                           params:nil objectClass:[RKMTree class]];
		self.model = myModel;
		TT_RELEASE_SAFELY(myModel);
	}

	return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewDataSource

/*
 * Inform the datasource that the model got loaded --> start to build the tablecells
 * that will be displayed.
 */
- (void)tableViewDidLoadModel:(UITableView *)tableView {
	NSMutableArray *items = [[NSMutableArray alloc] init];

	RKRequestTTModel *model = (RKRequestTTModel *)self.model;
	RKMTree *response = [model.objects objectAtIndex:0];
	RKOEntity *rootElement = [response.entities objectAtIndex:0];

	NSUInteger count = [response.entities count];
	NSString *parentID = rootElement.id;

	// photo-index (skips albums)
	int d = 0;

	for (int i = 1; i < count; i++) {
		RKOEntity *item = ( (RKOEntity *)[response.entities objectAtIndex:i] );

		NSString *aURL = @"";

		if ([item.type isEqualToString:@"album"]) {
			aURL = [@"tt://album/" stringByAppendingString:item.id];
		}
		else {
			aURL = [[[@"tt://photo/"
			          stringByAppendingString:parentID]
			         stringByAppendingString:@"/"]
			        stringByAppendingString:[NSString stringWithFormat:@"%d", d]];
			d++;
		}

		NSString *thumb_url =
		        (item.thumb_url_public != nil) ? item.thumb_url_public : item.thumb_url;
		if (thumb_url == nil) {
			thumb_url = @"bundle://empty.png";
		}

		NSString *resize_url =
		        (item.resize_url_public != nil) ? item.resize_url_public : item.resize_url;
		if (resize_url == nil) {
			resize_url = @"bundle://empty.png";
		}

		id iWidth = item.thumb_width;
		id iHeight = item.thumb_height;
		short int width = 100;
		short int height = 100;

		if ([iWidth isKindOfClass:[NSString class]] &&
		    [iHeight isKindOfClass:[NSString class]]) {
			if ([@"" isEqualToString:iWidth] || [@"" isEqualToString:iHeight] ||
			    [@"0" isEqualToString:iWidth] || [@"0" isEqualToString:iHeight]) {
				width = 100;
				height = 100;
			}
			else if ([iWidth length] > 0 && [iHeight length] > 0) {
				width = [iWidth longLongValue];
				height = [iHeight longLongValue];
			}
		}

		NSDate *date = [NSDate dateWithTimeIntervalSince1970:[item.created floatValue]];

		NSString *description = (item.description != nil) ? item.description : @"";

		[items addObject:[MyAlbumItem itemWithItemID:item.id
		                                       model:item
		                                        type:item.type
		                                       title:item.title
		                                     caption:@"By: David"
		                                 description:description
		                                        text:nil
		                                   timestamp:date
		                                    imageURL:thumb_url
		                                       width:width
		                                      height:height
		                                         URL:aURL]];
	}

	self.items = items;

	TT_RELEASE_SAFELY(items);
	return;
}


/*
 * This datasource builds custom cells that are not part of the Three20 package.
 * So here the datasource gets told which cell it should display for the given item.
 *
 * - MyAlbumItemCell:    This custom cell is used to display albums and photos.
 * - MyMetaDataItemCell: This custom cell is used to display the metadata info.
 *
 * See http://three20.pypt.lt/custom-cells-in-tttableviewcontroller and
 * checkout MyMetaDataItem/MyMetaDataItemCell or MyAlbumItem/MyAlbumItemCell
 */
- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
	if ([object isKindOfClass:[MyAlbumItem class]]) {
		return [MyAlbumItemCell class];
	}

	if ([object isKindOfClass:[MyMetaDataItem class]]) {
		return [MyMetaDataItemCell class];
	}

	return [super    tableView:tableView
	        cellClassForObject:object];
}


// Defines text that is displayed during the loading of items
- (NSString *)titleForLoading:(BOOL)reloading {
	if (reloading) {
		return NSLocalizedString(@"Loading Gallery3 items ...",
		                         @"Loading Gallery3 items  text");
	}
	else {
		return NSLocalizedString(@"Loading Gallery3 items ...",
		                         @"Loading Gallery3 items text");
	}
}


/*
 * Defines the text that is shown if the item is empty.
 * This method is used to render a button for image upload.
 */
- (NSString *)titleForEmpty {
	UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
	button1.frame = CGRectMake(10, 10, 60, 60);
	[button1 setBackgroundImage:[UIImage imageNamed:@"uploadIcon.png"] forState:
	 UIControlStateNormal];
	[button1 addTarget:self action:@selector(uploadImage:) forControlEvents:
	 UIControlEventTouchUpInside];

	self.items = [NSArray arrayWithObject:button1];

	return NSLocalizedString(@"No Items found.", @"Items no results");
}


// If something goes wrong ...
- (NSString *)subtitleForError:(NSError *)error {
	return NSLocalizedString(@"Sorry, there was an error loading the Gallery3 stream.", @"");
}


@end