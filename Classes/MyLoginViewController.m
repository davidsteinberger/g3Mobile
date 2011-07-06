/*
 * MyLoginViewController.m
 * g3Mobile - an iPhone client for gallery3
 *
 * Created by David Steinberger on 14/3/2011.
 * Copyright (c) 2011 David Steinberger
 *
 * This file is part of g3Mobile.
 *
 * g3Mobile is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * g3Mobile is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with g3Mobile.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "MyLoginViewController.h"
#import "AppDelegate.h"

// Others
#import <CoreData/CoreData.h>
#import "MyLoginModel.h"
#import "MyLogin.h"
#import "MySettings.h"

// RestKit
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "RKManagedObjectSeeder+persist.h"
#import "RKMItem.h"
#import "RKMSites.h"

@interface MyLoginViewController ()

@property (nonatomic, retain) TTSectionedDataSource *dataSource;

@property (nonatomic, retain) UISwitch *viewOnly;
@property (nonatomic, readonly) UITextField *baseURL;
@property (nonatomic, readonly) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UISlider *imageQualityField;
@property (nonatomic, retain) TTView *segmentedControlFrame;

@property (nonatomic, retain) NSMutableArray *autocompleteUrls;
@property (nonatomic, retain) NSMutableArray *autocompleteTitles;
@property (nonatomic, assign) UITableView *autocompleteTableView;

- (void)createDataSource;
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring;
- (BOOL)deleteFromCoreData:(NSString *)entityName;
- (void)seedGalleryNames;

@end

@implementation MyLoginViewController

@dynamic dataSource;

@synthesize viewOnly = _viewOnly;
@synthesize baseURL = _baseURL;
@synthesize passwordField = _passwordField;
@synthesize usernameField = _usernameField;
@synthesize imageQualityField = _imageQualityField;
@synthesize segmentedControlFrame = _segmentedControlFrame;

@synthesize autocompleteUrls = _autocompleteUrls;
@synthesize autocompleteTitles = _autocompleteTitles;
@synthesize autocompleteTableView = _autocompleteTableView;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle

- (void)dealloc {
	[[TTNavigator navigator].URLMap removeURL:@"tt://removeAllCache"];
	TT_RELEASE_SAFELY(_autocompleteUrls);
	TT_RELEASE_SAFELY(_autocompleteTitles);
	TT_RELEASE_SAFELY(_autocompleteTableView);
	TT_RELEASE_SAFELY(_model);
	TT_RELEASE_SAFELY(_viewOnly);
	TT_RELEASE_SAFELY(_baseURL);
	TT_RELEASE_SAFELY(_usernameField);
	TT_RELEASE_SAFELY(_passwordField);
	TT_RELEASE_SAFELY(_segmentedControlFrame);
	TT_RELEASE_SAFELY(_buildDateField);
	TT_RELEASE_SAFELY(_buildVersionField);
	[super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

// UIViewController standard init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ( (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) ) {
		self.title = @"Settings";
		self.variableHeightRows = YES;
		self.autoresizesForKeyboard = YES;
		self.tableViewStyle = UITableViewStyleGrouped;

		[[TTNavigator navigator].URLMap from:@"tt://removeAllCache"
		                            toObject:self selector:@selector(removeAllCache)];

		[self seedGalleryNames];
	}

	return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelViewController

- (void)createModel {
	[self createDataSource];
	self.model = [[[MyLoginModel alloc] init] autorelease];
}


- (void)toggleViewOnly:(UISwitch *)control {
	NSIndexPath *switchPath = [NSIndexPath indexPathForRow:0 inSection:0];

	if (control.on) {
		[self     tableView:self.tableView
		 commitEditingStyle:UITableViewCellEditingStyleDelete
		  forRowAtIndexPath:switchPath];
	}
	else {
		[self     tableView:self.tableView
		 commitEditingStyle:UITableViewCellEditingStyleInsert
		  forRowAtIndexPath:switchPath];
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelDelegate

- (void)model:(id <TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
	NSString *baseURL = ( (MyLogin *)object ).baseURL;
	RKObjectManager *objectManager = [RKObjectManager sharedManager];
	RKMSite *newSite =
	        ( (RKMSite *)[objectManager.objectStore
	                      findOrCreateInstanceOfEntity:[RKMSite entityDescription]
	                           withPrimaryKeyAttribute:@"url" andValue:baseURL] );
	newSite.url = baseURL;
	newSite.title = baseURL;

	RKMSites *localSites =
	        ( (RKMSites *)[objectManager.objectStore
	                       findOrCreateInstanceOfEntity:[RKMSites entityDescription]
	                            withPrimaryKeyAttribute:@"type" andValue:@"local"] );
	localSites.type = @"local";

	NSSet *sites = [localSites.rSite setByAddingObject:newSite];
	localSites.rSite = sites;
	[objectManager.objectStore save];

	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate finishedLogin];
}


- (void)model:(id <TTModel>)model didFailLoadWithError:(NSError *)error {
	TTAlertViewController *alert =
	        [[[TTAlertViewController alloc] initWithTitle:@"Login" message:
	          TTDescriptionForError(error)]
	         autorelease];
	[alert addCancelButtonWithTitle:@"OK" URL:nil];
	[alert showInView:self.view animated:YES];

	[self showLoading:NO];
	[super model:model didFailLoadWithError:error];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self deleteFromCoreData:@"RKMTree"];
		[self deleteFromCoreData:@"RKMItem"];

		TTNavigator *navigator = [TTNavigator navigator];
		[navigator removeAllViewControllers];
		[[TTURLCache sharedCache] removeAll:YES];
		[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://root/1"]
		                          applyAnimated:YES]];
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	self.autocompleteTableView.hidden = YES;
	if (textField == _baseURL && !self.viewOnly.on) {
		[_usernameField becomeFirstResponder];
	}
	else {
		if (textField == _usernameField) {
			[_passwordField becomeFirstResponder];
		}
		else {
			[_passwordField resignFirstResponder];

			NSString *url = nil;
			if ([[_baseURL.text substringToIndex:7] isEqualToString:@"http://"]) {
				url = _baseURL.text;
			}
			else {
				url = [@"http://" stringByAppendingString:_baseURL.text];
			}

			NSString *ending = @"/index.php";
			NSRange substringRange = [url rangeOfString:ending];
			if (substringRange.length == 0) {
				url = [url stringByAppendingString:ending];
			}

			MyLogin *settings = [[MyLogin alloc] init];
			settings.viewOnly = _viewOnly.on;
			settings.baseURL = url;
			settings.username = _usernameField.text;
			settings.password = _passwordField.text;
			settings.imageQuality = _imageQualityField.value;

			// login
			[(MyLoginModel *)self.model login:[settings autorelease]];
		}
	}
	return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
	// whenever user starts to enter -> hide the autocomplete view
	self.autocompleteTableView.hidden = YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
       replacementString:(NSString *)string {
	if (textField == _baseURL && range.location >= 2) {
		self.autocompleteTableView.hidden = NO;

		NSString *substring = [NSString stringWithString:textField.text];
		substring = [substring
		             stringByReplacingCharactersInRange:range withString:string];
		[self searchAutocompleteEntriesWithSubstring:substring];
	}
	else {
		self.autocompleteTableView.hidden = YES;
	}
	return YES;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)
       indexPath {
	UITableViewCell *cell = nil;
	static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
	cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc]
		         initWithStyle:UITableViewCellStyleDefault reuseIdentifier:
		         AutoCompleteRowIdentifier] autorelease];
	}

	cell.textLabel.text = [self.autocompleteTitles objectAtIndex:indexPath.row];
	return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.autocompleteTitles count];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)
       editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		GlobalSettings.viewOnly = YES;

		NSIndexPath *userPath = [NSIndexPath indexPathForRow:1 inSection:1];
		NSIndexPath *passwordPath = [NSIndexPath indexPathForRow:2 inSection:1];

		[[self.dataSource.items objectAtIndex:userPath.section]
		 removeObjectAtIndex:userPath.row];
		[[self.dataSource.items objectAtIndex:userPath.section]
		 removeObjectAtIndex:userPath.row];

		_baseURL.returnKeyType = UIReturnKeyGo;
		_usernameField.text = @"";
		_passwordField.text = @"";

		[tableView deleteRowsAtIndexPaths:[NSArray
		                                   arrayWithObjects:userPath, passwordPath, nil]
		                 withRowAnimation:UITableViewRowAnimationFade];

		[tableView endUpdates];

		[_baseURL becomeFirstResponder];
	}
	if (editingStyle == UITableViewCellEditingStyleInsert) {
		GlobalSettings.viewOnly = NO;

		[tableView beginUpdates];

		NSIndexPath *userPath = [NSIndexPath indexPathForRow:1 inSection:1];
		NSIndexPath *passwordPath = [NSIndexPath indexPathForRow:2 inSection:1];

		TTTableControlItem *cUsernameField =
		        [TTTableControlItem itemWithCaption:@"Username"
		                                    control:_usernameField];
		TTTableControlItem *cPasswordField =
		        [TTTableControlItem itemWithCaption:@"Password"
		                                    control:_passwordField];

		_usernameField.enabled = YES;
		_passwordField.enabled = YES;

		[[self.dataSource.items objectAtIndex:userPath.section]
		 insertObject:cUsernameField
		      atIndex:userPath.row];
		[[self.dataSource.items objectAtIndex:passwordPath.section]
		 insertObject:cPasswordField
		      atIndex:passwordPath.row];
		[tableView
		 insertRowsAtIndexPaths:[NSArray arrayWithObjects:userPath, passwordPath, nil]
		       withRowAnimation:UITableViewRowAnimationFade];

		[tableView endUpdates];

		[_usernameField becomeFirstResponder];
	}
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.autocompleteTableView.hidden = YES;
	self.baseURL.text = ( (NSString *)[self.autocompleteUrls objectAtIndex:indexPath.row] );
	[_usernameField becomeFirstResponder];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark private

- (void)seedGalleryNames {
	RKObjectManager *objectManager = [RKObjectManager sharedManager];

	RKManagedObjectSeeder *seeder =
	        [RKManagedObjectSeeder
	         ObjectSeederByKeepingPersistantStoreWithObjectManager:objectManager];
	[seeder
	 seedObjectsFromFile:@"sites.json"
	   withObjectMapping:[objectManager.mappingProvider objectMappingForClass:[RKMSites class]]
	];
	[objectManager.objectStore save];
}


- (void)removeAllCache {
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
	                                                          delegate:self
	                                                 cancelButtonTitle:@"Cancel"
	                                            destructiveButtonTitle:nil
	                                                 otherButtonTitles:
	                               @"Really delete all cache?!", nil] autorelease];

	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;

	[actionSheet showInView:self.view];
}


- (BOOL)deleteFromCoreData:(NSString *)entityName {
	RKManagedObjectStore *objectStore = [RKObjectManager sharedManager].objectStore;
	NSManagedObjectContext *context = objectStore.managedObjectContext;
	NSError *error;

	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
	                                          inManagedObjectContext:context];

	if (entity) {
		[fetchRequest setEntity:entity];

		NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
		if ([fetchedObjects count] > 0) {
			for (NSManagedObject *object in fetchedObjects) {
				[context deleteObject:object];
			}
		}
	}

	if (![context save:&error]) {
		NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
		return YES;
	}
	else {
		return NO;
	}
}


- (void)imageQualityChanged:(UISlider *)control {
	NSNumber *number = [NSNumber numberWithFloat:control.value];
	GlobalSettings.imageQuality = [number floatValue];
}


- (void)createDataSource {
	_autocompleteUrls = [[NSMutableArray alloc] init];
	_autocompleteTitles = [[NSMutableArray alloc] init];

	// view-only switch
	_viewOnly = [[UISwitch alloc] init];

	// url for website
	_baseURL = [[UITextField alloc] init];
	_baseURL.placeholder = @"http://example.com";
	_baseURL.keyboardType = UIKeyboardTypeURL;
	_baseURL.returnKeyType = UIReturnKeyNext;
	_baseURL.autocorrectionType = UITextAutocorrectionTypeNo;
	_baseURL.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_baseURL.clearButtonMode = UITextFieldViewModeWhileEditing;
	_baseURL.clearsOnBeginEditing = NO;
	_baseURL.delegate = self;

	// username field
	_usernameField = [[UITextField alloc] init];
	_usernameField.placeholder = @"*****";
	_usernameField.keyboardType = UIKeyboardTypeDefault;
	_usernameField.returnKeyType = UIReturnKeyNext;
	_usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
	_usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_usernameField.clearsOnBeginEditing = NO;
	_usernameField.delegate = self;

	// password field
	_passwordField = [[UITextField alloc] init];
	_passwordField.placeholder = @"*****";
	_passwordField.returnKeyType = UIReturnKeyGo;
	_passwordField.secureTextEntry = YES;
	_passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
	_passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_passwordField.clearsOnBeginEditing = NO;
	_passwordField.delegate = self;

	// layout switcher
	_segmentedControlFrame =
	        [[TTView alloc] initWithFrame:CGRectMake(-1.0f, -1.0f, 302.0f, 46.0f)];

	_baseURL.text = GlobalSettings.baseURL;

	_buildDateField = [[UITextField alloc] init];
	_buildDateField.text = @"";
	_buildDateField.textAlignment = UITextAlignmentRight;
	_buildDateField.enabled = NO;

	_buildVersionField = [[UITextField alloc] init];
	_buildVersionField.text = @"";
	_buildVersionField.textAlignment = UITextAlignmentRight;
	_buildVersionField.enabled = NO;

	_autocompleteTableView = [[UITableView alloc]  initWithFrame:
	                          CGRectMake(0, 160, 320, 120) style:UITableViewStylePlain];
	self.autocompleteTableView.delegate = self;
	self.autocompleteTableView.dataSource = self;
	self.autocompleteTableView.scrollEnabled = YES;
	self.autocompleteTableView.hidden = YES;
	[self.tableView addSubview:self.autocompleteTableView];

	// create ui-elements
	if (!GlobalSettings.viewOnly) {
		_viewOnly.on = NO;
	}
	else {
		_viewOnly.on = YES;
		_usernameField.text = @"";
		_passwordField.text = @"";
	}

	TTTableControlItem *cViewOnly =
	        [TTTableControlItem itemWithCaption:@"View Only" control:_viewOnly];

	[_viewOnly addTarget:self.tableView.delegate action:@selector(toggleViewOnly:)
	    forControlEvents:UIControlEventValueChanged];

	TTTableControlItem *cBaseURL = [TTTableControlItem itemWithCaption:@"Website"
	                                                           control:_baseURL];

	TTTableControlItem *cUsernameField = [TTTableControlItem itemWithCaption:@"Username"
	                                                                 control:_usernameField];

	TTTableControlItem *cPasswordField = [TTTableControlItem itemWithCaption:@"Password"
	                                                                 control:_passwordField];

	// image quality field
	_imageQualityField = [[[UISlider alloc] init] autorelease];
	_imageQualityField.minimumValue = 0;
	_imageQualityField.maximumValue = 1;

	_imageQualityField.value = GlobalSettings.imageQuality ? GlobalSettings.imageQuality : 0.5;

	[_imageQualityField addTarget:self
	                       action:@selector(imageQualityChanged:)
	             forControlEvents:UIControlEventTouchUpInside];

	TTTableControlItem *cImageQuality =
	        [TTTableControlItem itemWithCaption:@"Image Quality" control:_imageQualityField];

	// a button to clear all cache
	CGRect appFrame = [UIScreen mainScreen].applicationFrame;
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
	[button setTitle:@"Delete all Cache" forState:UIControlStateNormal];
	[button addTarget:@"tt://removeAllCache" action:@selector(openURL)
	 forControlEvents:UIControlEventTouchUpInside];
	button.frame = CGRectMake(20, 20, appFrame.size.width - 40, 50);

	_segmentedControlFrame.backgroundColor = [UIColor clearColor];
	UISegmentedControl *segmentedControl =
	        [[UISegmentedControl alloc] initWithFrame:_segmentedControlFrame.bounds];
	[segmentedControl insertSegmentWithTitle:@"Album" atIndex:0 animated:NO];
	[segmentedControl insertSegmentWithTitle:@"Thumbs" atIndex:1 animated:NO];
	segmentedControl.selectedSegmentIndex = (GlobalSettings.viewStyle == kAlbumView) ? 0 : 1;
	[segmentedControl addTarget:(AppDelegate *)[[UIApplication sharedApplication] delegate]
	                     action:@selector(dispatchToRootController:)
	           forControlEvents:UIControlEventValueChanged];
	[_segmentedControlFrame addSubview:segmentedControl];
	TT_RELEASE_SAFELY(segmentedControl);

	// build version
	TTTableControlItem *cBuildDate =
	        [TTTableControlItem itemWithCaption:@"Build-Date" control:_buildDateField];
	TTTableControlItem *cBuildVersion =
	        [TTTableControlItem itemWithCaption:@"Build-Version" control:_buildVersionField];

	// put everything together (for the ttsectioneddatasource)
	// create sections
	NSMutableArray *sections = [[NSMutableArray alloc] init];
	[sections addObject:@""];
	[sections addObject:@"Global"];
	[sections addObject:@"Other"];
	[sections addObject:@"Cache Settings"];
	[sections addObject:@"View Settings"];
	[sections addObject:@"Version Info"];

	NSMutableArray *section0 = [[NSMutableArray alloc] init];
	[section0 addObject:cViewOnly];

	// create section items
	// section 1 will hold items for login details
	NSMutableArray *section1 = [[NSMutableArray alloc] init];
	[section1 addObject:cBaseURL];

	if (!GlobalSettings.viewOnly) {
		[section1 addObject:cUsernameField];
		[section1 addObject:cPasswordField];
	}

	// section 2 will hold the image quality slider
	NSMutableArray *section2 = [[NSMutableArray alloc] init];
	[section2 addObject:cImageQuality];

	// section 3 will hold button for clearing the cache
	NSMutableArray *section3 = [[NSMutableArray alloc] init];
	[section3 addObject:button];

	// section 4 will hold button for chossing the view-style
	NSMutableArray *section4 = [[NSMutableArray alloc] init];
	[section4 addObject:_segmentedControlFrame];

	// section 5 will hold version info
	NSMutableArray *section5 = [[NSMutableArray alloc] init];
	[section5 addObject:cBuildDate];
	[section5 addObject:cBuildVersion];

	// create array for ttsectioneddatasource
	NSMutableArray *items = [[NSMutableArray alloc] init];
	[items addObject:section0];
	[items addObject:section1];
	[items addObject:section2];
	[items addObject:section3];
	[items addObject:section4];
	[items addObject:section5];
	TT_RELEASE_SAFELY(section0);
	TT_RELEASE_SAFELY(section1);
	TT_RELEASE_SAFELY(section2);
	TT_RELEASE_SAFELY(section3);
	TT_RELEASE_SAFELY(section4);
	TT_RELEASE_SAFELY(section5);

	TTSectionedDataSource *ds =
	        [[TTSectionedDataSource alloc] initWithItems:items sections:sections];
	self.dataSource = ds;
	TT_RELEASE_SAFELY(ds);

	TT_RELEASE_SAFELY(sections);
	TT_RELEASE_SAFELY(items);
}


- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
	RKObjectManager *objectManager = [RKObjectManager sharedManager];
	RKMSites *seededSites = ( (RKMSites *)[objectManager.objectStore
	                                       findOrCreateInstanceOfEntity:[RKMSites
	                                                                     entityDescription]
	                                            withPrimaryKeyAttribute:@"type"
	                                                           andValue:@"seeded"] );
	RKMSites *localSites = ( (RKMSites *)[objectManager.objectStore
	                                      findOrCreateInstanceOfEntity:[RKMSites
	                                                                    entityDescription]
	                                           withPrimaryKeyAttribute:@"type"
	                                                          andValue:@"local"] );
	NSSet *sites = [seededSites.rSite setByAddingObjectsFromSet:localSites.rSite];

	// Put anything that starts with this substring into the autocompleteUrls array
	// The items in this array is what will show up in the table view
	[self.autocompleteTitles removeAllObjects];
	[self.autocompleteUrls removeAllObjects];
	for (RKMSite *site in sites) {
		NSString *curString = site.url;
		NSRange substringRange =
		        [curString rangeOfString:substring options:NSCaseInsensitiveSearch];
		if (substringRange.location != NSNotFound) {
			[self.autocompleteUrls addObject:curString];
			[self.autocompleteTitles addObject:site.title];
		}
	}

	[self.autocompleteTableView reloadData];
	if ([self.autocompleteTitles count] == 0) {
		self.autocompleteTableView.hidden = YES;
	}
}


@end