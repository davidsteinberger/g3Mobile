//
//  MyThumbsViewDataSource.m
//  g3Mobile
//
//  Created by David Steinberger on 2/5/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyThumbsViewDataSource2.h"
#import "MyThumbsViewModel2.h"
#import "MyAlbumItem.h"
#import "MyAlbumItemCell.h"
#import "MyMetaDataItem.h"
#import "MyMetaDataItemCell.h"
#import "MyThumbsViewController2.h"

@implementation MyThumbsViewDataSource2

@synthesize hasOnlyPhotos = _hasOnlyPhotos;

- (id)initWithItemID:(NSString*)itemID {
	if (self = [super init]) {
		_thumbsViewModel = [[MyThumbsViewModel2 alloc] initWithItemID:itemID];
	}
	
	return self;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_thumbsViewModel);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
	return _thumbsViewModel;
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
	NSMutableArray* items = [[NSMutableArray alloc] init];

	/*
	NSUInteger i = 0;
	self.hasOnlyPhotos = YES;
	for (NSDictionary* item in _thumbsViewModel.restResource) {
		if (i++ == 0) continue;
		NSDictionary* fields = [item objectForKey:@"entity"];
		self.hasOnlyPhotos = ([[fields objectForKey:@"type"] isEqualToString:@"album"]) ? NO : self.hasOnlyPhotos;		
	}
	//NSLog(@"self.hasOnlyPhotos: %i", self.hasOnlyPhotos);
	*/
	
	int i = 1;
	NSUInteger count = [_thumbsViewModel.restResource count];
	NSString* parentID = [((NSDictionary*)[_thumbsViewModel.restResource objectAtIndex:0]) valueForKeyPath:@"entity.id"];
	
	// photo-index (skips albums)
	int d = 0;
	
	for (i = 1; i < count; i++) {
		NSDictionary * item = ((NSDictionary*)[_thumbsViewModel.restResource objectAtIndex:i]);

		NSString* aURL = @"";
		if ([[item valueForKeyPath:@"entity.type"] isEqualToString:@"album"]) {
			aURL = [@"tt://album/" stringByAppendingString:[item valueForKeyPath:@"entity.id"]];
		} else {			
				aURL = [[[@"tt://photo/" 
						stringByAppendingString:parentID]
						stringByAppendingString:@"/"]
						stringByAppendingString:[NSString stringWithFormat:@"%d",d]];
				d++;
				//NSLog(@"aURL: %@", aURL);
		}

		
		NSString* thumb_url = [item valueForKeyPath:@"entity.thumb_url_public"];
		if (thumb_url == nil) {
			thumb_url = [item valueForKeyPath:@"entity.thumb_url"];
			if (thumb_url == nil) {
				thumb_url = @"bundle://empty.png";
			}
		}
		
		NSString* resize_url = [item valueForKeyPath:@"entity.resize_url_public"];
		if (resize_url == nil) {
			resize_url = [item valueForKeyPath:@"entity.resize_url"];
			if (resize_url == nil) {
				resize_url = thumb_url;
				if (resize_url == nil) {
					resize_url = @"bundle://empty.png";
				}
			}
		}
		
		id iWidth = [item valueForKeyPath:@"entity.thumb_width"];
		id iHeight = [item valueForKeyPath:@"entity.thumb_height"];
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
		
		NSDate *date = [NSDate dateWithTimeIntervalSince1970: [[item valueForKeyPath:@"entity.created"] floatValue]];
		
		NSString* description = [item valueForKeyPath:@"entity.description"];
		if ((NSNull*)description == [NSNull null]) {
			description = @"";
		}
		
		MyRestResource* rr = [[MyRestResource alloc] init];
		rr.entity = item;

		[items addObject:[MyAlbumItem itemWithItemID: [item valueForKeyPath:@"entity.id"]					
											   model: rr
												type: [item valueForKeyPath:@"entity.type"]					
											   title:[item valueForKeyPath:@"entity.title"]						  
												   caption: @"By: David"
										description: description
													  text: nil
										  timestamp: date
												  imageURL: thumb_url
											  width: width
											 height: height
													   URL: aURL]];
		TT_RELEASE_SAFELY(rr);
	}
	
	self.items = items;
	
	TT_RELEASE_SAFELY(items);
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
