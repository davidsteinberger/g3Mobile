//
//  TTTableViewDataSource+g3.m
//  g3Mobile
//
//  Created by David Steinberger on 2/16/11.
//  Copyright 2011 -. All rights reserved.
//

#import "TTTableViewDataSource+g3.h"
#import "MyThumbsViewController2.h"
#import "MyAlbumItemCell.h"
#import "MyMetaDataItemCell.h"
#import "Three20/Three20.h"
#import "Three20UI/UITableViewAdditions.h"
#import <objc/runtime.h>

@implementation TTTableViewDataSource (xib)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell*)tableView:(UITableView *)tableView
		cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
	
	Class cellClass = [self tableView:tableView cellClassForObject:object];
	const char* className = class_getName(cellClass);
	NSString* identifier = [[NSString alloc] initWithBytesNoCopy:(char*)className
														  length:strlen(className)
														encoding:NSASCIIStringEncoding freeWhenDone:NO];
	
	UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	// customization: loads xib if it exists!
	if (cell == nil) {		
		cell = [[self createNewCellWithClass:cellClass identifier:identifier] autorelease];
	}
	
	if (cell == nil) {
		cell = [[[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
								 reuseIdentifier:identifier] autorelease];
	}

	if ([cell class] == [MyAlbumItemCell class] || [cell class] == [MyMetaDataItemCell class]) {
		UILongPressGestureRecognizer *longPressGesture =
		[[[UILongPressGestureRecognizer alloc]
		  initWithTarget:((MyThumbsViewController2*)[((TTTableViewDelegate*)tableView.delegate) controller]) action:@selector(longPress:)] autorelease];
		[cell addGestureRecognizer:longPressGesture];
	}
	
	[cell setTag:indexPath.row];
	
	[identifier release];
	
	if ([cell isKindOfClass:[TTTableViewCell class]]) {
		[(TTTableViewCell*)cell setObject:object];
	}
	
	[self tableView:tableView cell:cell willAppearAtIndexPath:indexPath];
	
	return cell;
}

- (UITableViewCell*)createNewCellWithClass:(Class)klaz
								identifier:(NSString*)identifier {
	//TTDASSERT([[NSBundle mainBundle] pathForResource:identifier ofType:@"nib"] == nil);
	if ([[NSBundle mainBundle] pathForResource:identifier ofType:@"nib"]) {
		NSArray *tab = [[NSBundle mainBundle] loadNibNamed:identifier owner:nil options:nil];
		return [[tab objectAtIndex:0] retain];
	} else {
		return nil;
	}
}

@end
