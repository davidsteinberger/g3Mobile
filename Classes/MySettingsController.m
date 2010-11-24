//
//  MySettingsController.m
//  Gallery3
//
//  Created by David Steinberger on 11/21/10.
//  Copyright 2010 -. All rights reserved.
//

#import "MySettingsController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MySettingsController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
		self.tableViewStyle = UITableViewStyleGrouped;
		self.title = @"Settings";
		self.autoresizesForKeyboard = YES;
		self.variableHeightRows = YES;
		
		UITextField* website = [[[UITextField alloc] init] autorelease];
		website.placeholder = @"Website";
		website.font = TTSTYLEVAR(font);
		
		UITextField* username = [[[UITextField alloc] init] autorelease];
		username.font = TTSTYLEVAR(font);
		username.placeholder = @"Username";
		username.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		
		UITextField* password = [[[UITextField alloc] init] autorelease];
		password.font = TTSTYLEVAR(font);
		password.placeholder = @"Password";
		password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		
		self.dataSource = [TTListDataSource dataSourceWithObjects:
						   website,
						   username,
						   password,
						   nil];
	}
	return self;
}

@end
