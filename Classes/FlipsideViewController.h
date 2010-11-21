//
//  FlipsideViewController.h
//  Weather
//
//  Created by Alasdair Allan on 29/08/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

@class AppDelegate;

@protocol FlipsideViewControllerDelegate;

@interface FlipsideViewController : UIViewController {
	id <FlipsideViewControllerDelegate> delegate;
	IBOutlet UISwitch *toggleSwitch;
	AppDelegate *appDelegate;	
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
- (IBAction)done;
- (IBAction)save;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

