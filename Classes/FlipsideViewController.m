//
//  FlipsideViewController.m
//  Weather
//
//  Created by Alasdair Allan on 29/08/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "FlipsideViewController.h"
#import "AppDelegate.h";

@implementation FlipsideViewController

@synthesize delegate;

@synthesize website = _website;
@synthesize username = _username;
@synthesize password = _password;

- (void)viewDidLoad {
    [super viewDidLoad];	
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];      

	appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
}


- (IBAction)done {
	//appDelegate.updateLocation = toggleSwitch.on;	
	[self.delegate flipsideViewControllerDidFinish:self];	
}

-(IBAction)login {
	//NSLog(@"save");
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
