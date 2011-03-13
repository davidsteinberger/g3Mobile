//
//  MyThumbsViewDataSource.m
//  g3Mobile
//
//  Created by David Steinberger on 2/5/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyThumbsViewDataSource2.h"
#import "MyAlbumItem.h"
#import "MyAlbumItemCell.h"
#import "MyMetaDataItem.h"
#import "MyMetaDataItemCell.h"
#import "MyThumbsViewController2.h"
#import "MySettings.h"

#import <RestKit/RestKit.h>
#import <RestKit/Three20/RKRequestTTModel.h>
#import <RestKit/Three20/RKRequestFilterableTTModel.h>
#import "RKMTree.h"

@implementation MyThumbsViewDataSource2

- (id)initWithItemID:(NSString*)itemID {
	if (self = [super init]) {
		NSString* treeResourcePath = [[[@"" 
										stringByAppendingString:@"/rest/tree/"] 
									   stringByAppendingString:itemID]
									  stringByAppendingString:@"?depth=1"];
		
		[RKRequestTTModel setDefaultRefreshRate:3600];
		RKRequestTTModel* myModel = [[RKRequestTTModel alloc] 
					   initWithResourcePath:treeResourcePath
					   params:nil objectClass:[RKMTree class]];
		self.model = myModel;
		TT_RELEASE_SAFELY(myModel);
	}
	
	return self;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_model);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
	return self->_model;
}

- (BOOL)hasOnlyPhotos:(NSString*)itemID {
	return NO;
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
	
	NSMutableArray* items = [[NSMutableArray alloc] init];
	
	RKRequestTTModel* model = (RKRequestTTModel*)self.model;
	RKMTree* response = [model.objects objectAtIndex:0];
	RKOEntity* rootElement = [response.entities objectAtIndex:0];

	BOOL hasOnlyPhotos = NO;
	int i = 0;
	
	i = 1;
	NSUInteger count = [response.entities count];
	NSString* parentID = rootElement.id;
	
	// photo-index (skips albums)
	int d = 0;
	
	for (i = 1; i < count; i++) {
		RKOEntity * item = ((RKOEntity*)[response.entities objectAtIndex:i]);

		NSString* aURL = @"";
		
		if ([item.type isEqualToString:@"album"]) {
			if (hasOnlyPhotos) {
				aURL = [@"tt://thumbs/" stringByAppendingString:item.id];
			} else {
				aURL = [@"tt://album/" stringByAppendingString:item.id];
			}			
		} else {			
				aURL = [[[@"tt://photo/" 
						stringByAppendingString:parentID]
						stringByAppendingString:@"/"]
						stringByAppendingString:[NSString stringWithFormat:@"%d",d]];
				d++;
		}

		
		NSString* thumb_url = (item.thumb_url_public != nil) ? item.thumb_url_public : item.thumb_url;
		if (thumb_url == nil) {
			thumb_url = @"bundle://empty.png";
		}
		
		NSString* resize_url = (item.resize_url_public != nil) ? item.resize_url_public : item.resize_url;
		if (resize_url == nil) {
			resize_url = @"bundle://empty.png";
		}
		
		id iWidth = item.thumb_width;
		id iHeight = item.thumb_height;
		short int width = 100;
		short int height = 100;

		if ([iWidth isKindOfClass:[NSString class]] && [iHeight isKindOfClass:[NSString class]]) {
			if ([@"" isEqualToString:iWidth] || [@"" isEqualToString:iHeight] || [@"0" isEqualToString:iWidth] || [@"0" isEqualToString:iHeight]) {
				width = 100;
				height = 100;
			}	
			else if ([iWidth length] > 0 && [iHeight length] > 0 ) {
				width = [iWidth longLongValue];
				height = [iHeight longLongValue];
			}
		}
		
		NSDate *date = [NSDate dateWithTimeIntervalSince1970: [item.created floatValue]];
		
		NSString* description = (item.description != nil) ? item.description : @"";

		[items addObject:[MyAlbumItem itemWithItemID: item.id					
											   model: item
												type: item.type					
											   title:item.title
												   caption: @"By: David"
										description: description
													  text: nil
										  timestamp: date
												  imageURL: thumb_url
											  width: width
											 height: height
													   URL: aURL]];
	}
	
	self.items = items;

	TT_RELEASE_SAFELY(items);
	return;
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id) object {
	
	if ([object isKindOfClass:[MyAlbumItem class]]) {  
		return [MyAlbumItemCell class];  
	}
	
	if ([object isKindOfClass:[MyMetaDataItem class]]) {
		return [MyMetaDataItemCell class];
	}
	
	return [super tableView:tableView
	     cellClassForObject:object];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForLoading:(BOOL)reloading {
	if (reloading) {
		return NSLocalizedString(@"Loading Gallery3 items ...", @"Loading Gallery3 items  text");
	} else {
		return NSLocalizedString(@"Loading Gallery3 items ...", @"Loading Gallery3 items text");
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForEmpty {
	UIButton *button1 = [UIButton buttonWithType: UIButtonTypeCustom];
	button1.frame = CGRectMake(10, 10, 60, 60);
	[button1 setBackgroundImage:[UIImage imageNamed:@"uploadIcon.png"] forState:UIControlStateNormal];
	[button1 addTarget:self action:@selector(uploadImage:) forControlEvents:UIControlEventTouchUpInside];
	
	self.items = [NSArray arrayWithObject:button1];
	
	return NSLocalizedString(@"No Items found.", @"Items no results");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
	return NSLocalizedString(@"Sorry, there was an error loading the Gallery3 stream.", @"");
}


@end
