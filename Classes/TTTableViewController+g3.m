//
//  TTTableViewController+g3.m
//  g3Mobile
//
//  Created by David Steinberger on 2/19/11.
//  Copyright 2011 -. All rights reserved.
//

#import "TTTableViewController+g3.h"
#import "RestKit/Three20/RKRequestTTModel.h"
#import "RKMTree.h"
#import "RKOEntity.h"


@implementation TTTableViewController (empty)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showEmpty:(BOOL)show {
	if (show) {
		NSString* title = [_dataSource titleForEmpty];
		NSString* subtitle = [_dataSource subtitleForEmpty];
		UIImage* image = [_dataSource imageForEmpty];
		if (title.length || subtitle.length || image) {
			TTErrorView* errorView = [[[TTErrorView alloc] initWithTitle:title
																subtitle:subtitle
																   image:nil] autorelease];
			errorView.backgroundColor = _tableView.backgroundColor;
			
			TTView* buttonMenu = [self buildOverlayMenu];
			[errorView addSubview:buttonMenu];
			[errorView bringSubviewToFront:buttonMenu];

			self.emptyView = errorView;
		} else {
			self.emptyView = nil;
		}
		_tableView.dataSource = nil;
		[_tableView reloadData];
	} else {
		self.emptyView = nil;
	}
}

- (TTView*)buildOverlayMenu {
	// create buttons
	TTView* backView = [[TTView alloc]
						initWithFrame:CGRectMake(320 / 2 - 160 / 2, 250, 160, 80)];
	
	// style overlay-view
	UIColor* black = RGBCOLOR(158, 163, 172);
	backView.hidden = NO;
	backView.backgroundColor = [UIColor clearColor];
	backView.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
					  [TTSolidFillStyle styleWithColor:[UIColor colorWithWhite:0 alpha:0.8] next:
					   [TTSolidBorderStyle styleWithColor:black width:1 next:nil]]];
	
	// create buttons
	int buttonHeight = 60;
	int buttonWidth = 60;
	int buttonY = backView.frame.size.height / 2 - (buttonWidth / 2);
	
	int cntButtons = 2;
	int xDist = backView.frame.size.width / (cntButtons);
	int buttonX = xDist / 2 - (buttonHeight / 2);
	
	UIButton *button1 = [UIButton buttonWithType: UIButtonTypeCustom];
	button1.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
	[button1 setBackgroundImage:[UIImage imageNamed:@"uploadIcon.png"] forState:UIControlStateNormal];
	[button1 addTarget:self action:@selector(uploadImage:) forControlEvents:UIControlEventTouchUpInside];
		
	buttonX += xDist;
	UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
	button2.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
	[button2 setBackgroundImage:[UIImage imageNamed:@"trashIcon.png"] forState:UIControlStateNormal];
	[button2 addTarget:self action:@selector(deleteCurrentItem:) forControlEvents:UIControlEventTouchUpInside];
	
	[backView addSubview:button1];
	[backView addSubview:button2];
	
	return [backView autorelease];
}

@end
