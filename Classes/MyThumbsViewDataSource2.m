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
#import <RestKit/Three20/RKObjectLoaderTTModel.h>
#import "RKMTree.h"
#import "RKMItem.h"

@interface NSMutableArray (MoveArray)

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;

@end

@implementation NSMutableArray (MoveArray)

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    if (to != from) {
        id obj = [self objectAtIndex:from];
        [obj retain];
        [self removeObjectAtIndex:from];
        if (to >= [self count]) {
            [self addObject:obj];
        } else {
            [self insertObject:obj atIndex:to];
        }
        [obj release];
    }
}
@end

@implementation TTTableViewDelegate (my)

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
} 

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {  
    return proposedDestinationIndexPath;
}

@end

@implementation MyThumbsViewDataSource2

@synthesize itemID = _itemID;
@synthesize itemModel = _itemModel;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

// Initializes Datasource with a given item-id (album-id)
- (id)initWithItemID:(NSString *)itemID {
	if ((self = [super init])) {
        self.itemID = itemID;
		NSString *treeResourcePath = [[[@""
		                                stringByAppendingString:@"/rest/tree/"]
		                               stringByAppendingString:itemID]
		                              stringByAppendingString:@"?depth=1"];
        
        NSString *itemResourcePath = [[[@""
                                        stringByAppendingString:@"/rest/item/"]
                                       stringByAppendingString:itemID]
                                      stringByAppendingString:@"?fields=tag_item.tag"];

        RKObjectLoader* objectLoader = [[RKObjectManager sharedManager] objectLoaderWithResourcePath:treeResourcePath delegate:nil];
        objectLoader.objectMapping = [[RKObjectManager sharedManager].mappingProvider objectMappingForKeyPath:@"_tree"];
        RKObjectLoaderTTModel* model = [RKObjectLoaderTTModel modelWithObjectLoader:objectLoader];
        self.model = model;
        
        objectLoader = [[RKObjectManager sharedManager] objectLoaderWithResourcePath:itemResourcePath delegate:nil];
        objectLoader.objectMapping = [[RKObjectManager sharedManager].mappingProvider objectMappingForKeyPath:@"_item"];

        self.itemModel = [RKObjectLoaderTTModel modelWithObjectLoader:objectLoader];
        [self.itemModel load];
	}

	return self;
}

- (void)dealloc {
    TT_RELEASE_SAFELY(_itemID);
    TT_RELEASE_SAFELY(_itemModel);
    [super dealloc];
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
    [super tableViewDidLoadModel:tableView];
    
    // removing all items from the datasource ... as we never know what happened
    if ([self.items respondsToSelector:@selector(removeAllObjects)]) {
        [self.items removeAllObjects];
    }
    
	NSMutableArray *items = [[NSMutableArray alloc] init];

	RKObjectLoaderTTModel *model = (RKObjectLoaderTTModel *)self.model;
	RKMTree *tree = [model.objects objectAtIndex:0];
	RKMEntity *rootElement = [tree root];

	NSString *parentID = rootElement.itemID;

	// photo-index (skips albums)
	int d = 0;

    for (RKMEntity* item in [tree children]) {
		NSString *aURL = @"";

		if ([item.type isEqualToString:@"album"]) {
			aURL = [@"tt://album/" stringByAppendingString:item.itemID];
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

		NSString *description = (item.desc != nil) ? item.desc : @"";

		[items addObject:[MyAlbumItem itemWithItemID:item.itemID
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self.items objectAtIndex:indexPath.row];
    if ([item isKindOfClass:[MyAlbumItem class]]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

    NSMutableArray* members = [NSMutableArray array];
    NSMutableDictionary* entity = [NSMutableDictionary dictionary];
    
    [self.items moveObjectFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    
    for (MyAlbumItem* albumItem in self.items) {
        if ([albumItem isKindOfClass:[MyAlbumItem class]]) {
            NSString* itemID = albumItem.model.itemID;         
            [members addObject:[[GlobalSettings.baseURL stringByAppendingString:@"/rest/item/"] stringByAppendingString:itemID]];
        }
    }

    [entity setValue:@"weight" forKey:@"sort_column"];

    RKClient* client = [RKObjectManager sharedManager].client;
    [client setValue:@"put" forHTTPHeaderField:@"X-Gallery-Request-Method"];
    RKParams* params = [RKParams params];
    
    NSError* error = nil;
    id<RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
    NSString* membersString = [parser stringFromObject:members error:&error];
    NSString* entityString = [parser stringFromObject:entity error:&error];

    [params setValue:membersString forParam:@"members"];
    [params setValue:entityString forParam:@"entity"];

    NSString* resourcePath = [@"/rest/item/" stringByAppendingString:self.itemID];
    [client post:resourcePath params:params delegate:self];
    
    [client setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
}

@end