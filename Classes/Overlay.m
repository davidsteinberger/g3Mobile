//
//  Overlay.m
//  g3Mobile
//
//  Created by David Steinberger on 6/13/11.
//  Copyright 2011 -. All rights reserved.
//

#import "Overlay.h"
#import "UIImage+resizing.h"


@implementation Overlay

/*
 * Build overlay menu within given Frame
 * Via the type parameter we can choose between a menu for an album or a photo
 */
+ (TTView *)buildOverlayMenuWithFrame:(CGRect)frame type:(BOOL)album withDelegate:(id)delegate {
	// create overlay-view
	TTView *backView = [[TTView alloc]
	                    initWithFrame:frame];
    
	// style overlay-view
	UIColor *black = RGBCOLOR(158, 163, 172);
	backView.hidden = YES;
	backView.backgroundColor = [UIColor clearColor];
	backView.style =
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:10] next:
     [TTSolidFillStyle styleWithColor:[UIColor colorWithWhite:0 alpha:0.8] next:
      [TTSolidBorderStyle styleWithColor:black width:1 next:nil]]];
    
	// create buttons
	int buttonHeight = 50;
	int buttonWidth = 50;
	int buttonY = backView.frame.size.height / 2 - (buttonWidth / 2);
    
	if (album) {
		int cntButtons = 6;
		int xDist = (backView.frame.size.width - 14) / (cntButtons);
		int buttonX = (xDist / 2 - (buttonHeight / 2) ) + 7;
        
		UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
		button1.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button1 setBackgroundImage:[UIImage imageNamed:@"uploadIcon.png"]
		                   forState:UIControlStateNormal];
		[button1 setBackgroundImage:[UIImage imageNamed:@"uploadIcon_selected.png"]
		                   forState:UIControlStateSelected];
		[button1 setShowsTouchWhenHighlighted:YES];
		[button1 addTarget:delegate action:@selector(uploadImage:)
		  forControlEvents:UIControlEventTouchUpInside];
        
		buttonX += xDist;
		UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
		button2.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button2 setBackgroundImage:[UIImage imageNamed:@"addIcon.png"]
		                   forState:UIControlStateNormal];
		[button2 setBackgroundImage:[UIImage imageNamed:@"addIcon_selected.png"]
		                   forState:UIControlStateSelected];
		[button2 setShowsTouchWhenHighlighted:YES];
		[button2 addTarget:delegate action:@selector(createAlbum:)
		  forControlEvents:UIControlEventTouchUpInside];
        
		buttonX += xDist;
		UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
		button3.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button3 setBackgroundImage:[UIImage imageNamed:@"editIcon.png"]
		                   forState:UIControlStateNormal];
		[button3 setBackgroundImage:[UIImage imageNamed:@"editIcon_selected.png"]
		                   forState:UIControlStateSelected];
		[button3 setShowsTouchWhenHighlighted:YES];
		[button3 addTarget:delegate action:@selector(editAlbum:)
		  forControlEvents:UIControlEventTouchUpInside];
        
		buttonX += xDist;
		UIButton *button5 = [UIButton buttonWithType:UIButtonTypeCustom];
		button5.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button5 setBackgroundImage:[UIImage imageNamed:@"makeCoverIcon.png"]
		                   forState:UIControlStateNormal];
		[button5 setBackgroundImage:[UIImage imageNamed:@"makeCoverIcon_selected.png"]
		                   forState:UIControlStateSelected];
		[button5 setShowsTouchWhenHighlighted:YES];
		[button5 addTarget:delegate action:@selector(makeCover:)
		  forControlEvents:UIControlEventTouchUpInside];
        
		buttonX += xDist;
		UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
		button4.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button4 setBackgroundImage:[UIImage imageNamed:@"trashIcon.png"]
		                   forState:UIControlStateNormal];
		[button4 setBackgroundImage:[UIImage imageNamed:@"trashIcon_selected.png"]
		                   forState:UIControlStateSelected];
		[button4 setShowsTouchWhenHighlighted:YES];
		[button4 addTarget:delegate action:@selector(deleteCurrentItem:)
		  forControlEvents:UIControlEventTouchUpInside];
        
        buttonX += xDist;
		UIButton *button6 = [UIButton buttonWithType:UIButtonTypeCustom];
		button6.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button6 setBackgroundImage:[UIImage imageNamed:@"fbIcon.png"]
		                   forState:UIControlStateNormal];
		[button6 setBackgroundImage:[UIImage imageNamed:@"fbIcon_selected.png"]
		                   forState:UIControlStateSelected];
		[button6 setShowsTouchWhenHighlighted:YES];
		[button6 addTarget:delegate action:@selector(postToFB:)
		  forControlEvents:UIControlEventTouchUpInside];
        
		[backView addSubview:button1];
		[backView addSubview:button2];
		[backView addSubview:button3];
		[backView addSubview:button4];
		[backView addSubview:button5];
        [backView addSubview:button6];
	}
	else {
		int cntButtons = 5;
		int xDist = backView.frame.size.width / (cntButtons);
		int buttonX = xDist / 2 - (buttonHeight / 2);
        
		UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
		button1.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button1 setBackgroundImage:[UIImage imageNamed:@"commentIcon.png"]
		                   forState:UIControlStateNormal];
		[button1 setBackgroundImage:[UIImage imageNamed:@"commentIcon_selected.png"]
		                   forState:UIControlStateSelected];
		[button1 setShowsTouchWhenHighlighted:YES];
		[button1 addTarget:delegate action:@selector(comment:)
		  forControlEvents:UIControlEventTouchUpInside];
        
		buttonX += xDist;
		UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
		button2.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button2 setBackgroundImage:[UIImage imageNamed:@"makeCoverIcon.png"]
		                   forState:UIControlStateNormal];
		[button2 setBackgroundImage:[UIImage imageNamed:@"makeCoverIcon_selected.png"]
		                   forState:UIControlStateSelected];
		[button2 setShowsTouchWhenHighlighted:YES];
		[button2 addTarget:delegate action:@selector(makeCover:)
		  forControlEvents:UIControlEventTouchUpInside];
        
		buttonX += xDist;
		UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
		button3.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button3 setBackgroundImage:[UIImage imageNamed:@"saveIcon.png"]
		                   forState:UIControlStateNormal];
		[button3 setBackgroundImage:[UIImage imageNamed:@"saveIcon_selected.png"]
		                   forState:UIControlStateSelected];
		[button3 setShowsTouchWhenHighlighted:YES];
		[button3 addTarget:delegate action:@selector(save:)
		  forControlEvents:UIControlEventTouchUpInside];
        
		buttonX += xDist;
		UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
		button4.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button4 setBackgroundImage:[UIImage imageNamed:@"trashIcon.png"]
		                   forState:UIControlStateNormal];
		[button4 setBackgroundImage:[UIImage imageNamed:@"trashIcon_selected.png"]
		                   forState:UIControlStateSelected];
		[button4 setShowsTouchWhenHighlighted:YES];
		[button4 addTarget:delegate action:@selector(deleteCurrentItem:)
		  forControlEvents:UIControlEventTouchUpInside];
        
        buttonX += xDist;
		UIButton *button5 = [UIButton buttonWithType:UIButtonTypeCustom];
		button5.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
		[button5 setBackgroundImage:[UIImage imageNamed:@"fbIcon.png"]
		                   forState:UIControlStateNormal];
		[button5 setBackgroundImage:[UIImage imageNamed:@"fbIcon_selected.png"]
		                   forState:UIControlStateSelected];
		[button5 setShowsTouchWhenHighlighted:YES];
		[button5 addTarget:delegate action:@selector(postToFB:)
		  forControlEvents:UIControlEventTouchUpInside];
        
		[backView addSubview:button1];
		[backView addSubview:button2];
		[backView addSubview:button3];
		[backView addSubview:button4];
        [backView addSubview:button5];
	}
    
	return [backView autorelease];
}

+ (UIBarButtonItem*)makeToolbarButtonWithImageNamed:(NSString*)imageName target:(id)delegate action:(NSString*)action {
    UIImage* icon = [[UIImage imageNamed:imageName] scaleToSize:CGSizeMake(40, 40)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, icon.size.width, icon.size.height);
    [button setBackgroundImage:icon forState:UIControlStateNormal];
    [button setShowsTouchWhenHighlighted:YES];
    [button addTarget:delegate action:NSSelectorFromString(action)
      forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* bbiButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    return bbiButton;
}

+ (NSArray*)buildToolbarWithDelegate:(id)delegate {
    UIBarButtonItem* bbiButton1 = [self makeToolbarButtonWithImageNamed:@"uploadIcon.png" target:delegate action:@"uploadImage:"];
    UIBarButtonItem* bbiButton2 = [self makeToolbarButtonWithImageNamed:@"addIcon.png" target:delegate action:@"createAlbum:"];
    UIBarButtonItem* bbiButton3 = [self makeToolbarButtonWithImageNamed:@"editIcon.png" target:delegate action:@"editAlbum:"];                
    UIBarButtonItem* bbiButton4 = [self makeToolbarButtonWithImageNamed:@"reorderIcon.png" target:delegate action:@"reorder:"];
    UIBarButtonItem* bbiButton5 = [self makeToolbarButtonWithImageNamed:@"trashIcon.png" target:delegate action:@"deleteCurrentItem:"];
    UIBarButtonItem* bbiButton6 = [self makeToolbarButtonWithImageNamed:@"fbIcon.png" target:delegate action:@"postToFB:"];
    
    UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
						 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        
    NSArray* array = [NSArray arrayWithObjects:bbiButton1, space, bbiButton2, space, bbiButton3, space, bbiButton4, space, bbiButton5, space, bbiButton6, nil];
    
    return array;
}

+ (NSArray*)buildThumbViewToolbarWithDelegate:(id)delegate {
    UIBarButtonItem* bbiButton1 = [self makeToolbarButtonWithImageNamed:@"uploadIcon.png" target:delegate action:@"uploadImage:"];
    UIBarButtonItem* bbiButton2 = [self makeToolbarButtonWithImageNamed:@"addIcon.png" target:delegate action:@"createAlbum:"];
    UIBarButtonItem* bbiButton3 = [self makeToolbarButtonWithImageNamed:@"editIcon.png" target:delegate action:@"editAlbum:"];                
    UIBarButtonItem* bbiButton5 = [self makeToolbarButtonWithImageNamed:@"trashIcon.png" target:delegate action:@"deleteCurrentItem:"];
    UIBarButtonItem* bbiButton6 = [self makeToolbarButtonWithImageNamed:@"fbIcon.png" target:delegate action:@"postToFB:"];
    
    UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
						 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    NSArray* array = [NSArray arrayWithObjects:bbiButton1, space, bbiButton2, space, bbiButton3, space, bbiButton5, space, 
                      bbiButton6, nil];
    
    return array;
}

@end
