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
	AppDelegate *appDelegate;	
	
	UITextField* _website;
	UITextField* _username;
	UITextField* _password;
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITextField* website;
@property (nonatomic, retain) IBOutlet UITextField* username;
@property (nonatomic, retain) IBOutlet UITextField* password;

- (IBAction)done;
- (IBAction)login;

@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

