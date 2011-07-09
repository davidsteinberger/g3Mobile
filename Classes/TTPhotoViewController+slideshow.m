//
//  TTPhotoViewController+slideshow.m
//  g3Mobile
//
//  Created by David Steinberger on 7/9/11.
//  Copyright 2011 -. All rights reserved.
//

#import "TTPhotoViewController+slideshow.h"

// Three20
#import "Three20UI/UIToolbarAdditions.h"

// Others
#import "MySettings.h"

@interface TTScrollView (slideshow)

- (void)moveToPageAtIndex:(NSInteger)pageIndex resetEdges:(BOOL)resetEdges;
    
@end

@implementation TTPhotoViewController (slideshow)

- (void)playAction {
    if (!_slideshowTimer) {
        UIBarButtonItem* pauseButton =
        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemPause
                                                       target: self
                                                       action: @selector(pauseAction)]
         autorelease];
        pauseButton.tag = 1;
        
        [_toolbar replaceItemWithTag:1 withItem:pauseButton];
        
        _slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:GlobalSettings.slideshowTimeout
                                                           target:self
                                                         selector:@selector(slideshowTimer)
                                                         userInfo:nil
                                                          repeats:YES];
    }
}

- (void)slideshowTimer {
    unsigned currentIndex, targetIndex;
    currentIndex = _scrollView.centerPageIndex;
    if (_centerPhotoIndex != _photoSource.numberOfPhotos-1) {
        targetIndex =  currentIndex + 1;
    } else {
        targetIndex =  0;        
    }
    UIView *nextView = [_scrollView pageAtIndex:targetIndex];
    UIView *thisView = [_scrollView pageAtIndex:currentIndex];
    
    CGRect thisFrame = thisView.frame;
    CGRect previousFrame = CGRectMake(thisFrame.origin.x - thisFrame.size.width, thisFrame.origin.y, thisFrame.size.width, thisFrame.size.height);
    
    [UIView beginAnimations:@"slideshowMorph" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    nextView.frame = thisFrame;
    thisView.frame = previousFrame;
    
    [UIView commitAnimations];
    
    [_scrollView moveToPageAtIndex:targetIndex resetEdges:YES];
}

@end
