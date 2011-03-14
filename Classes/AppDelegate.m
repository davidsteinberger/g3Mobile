/*
 * AppDelegate.m
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

#import "AppDelegate.h"

// Three20
#import "Three20/Three20.h"

// RestKit
#import <RestKit/RestKit.h>
#import "RKOEntity.h"
#import "RKMItem.h"

// SQLite
#import <sqlite3.h>

// ViewControllers
#import "AddAlbumViewController.h"
#import "DBManagedObjectCache.h"
#import "MyCommentsViewController.h"
#import "MyLoginViewController.h"
#import "MyPhotoViewController.h"
#import "MyThumbsViewController.h"
#import "MyThumbsViewController2.h"
#import "MyUploadViewController.h"

#import "UIViewController+params.h"

// Reachability
#import "Reachability.h"

// Database
#import "MyDatabase.h"

// Settings
#import "MySettings.h"

// Others
#import "StyleSheet.h"

@interface AppDelegate ()

@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSString *password;

- (void)updateInterfaceWithReachability:(Reachability *)curReach;
- (void)initRestKit;
- (void)dispatchToRootController:(id)sender;
- (void)rootController:(NSNull *)null;

@end

@implementation AppDelegate

@synthesize user = _user;
@synthesize password = _password;
@synthesize challenge = _challenge;
@synthesize baseURL = _baseURL;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark LifeCycle
- (void)dealloc {
	TT_RELEASE_SAFELY(_user);
	TT_RELEASE_SAFELY(_password);
	TT_RELEASE_SAFELY(_challenge);
	TT_RELEASE_SAFELY(_baseURL);
	[super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIApplicationDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// set stylesheet
	[TTStyleSheet setGlobalStyleSheet:[[[StyleSheet alloc] init] autorelease]];
	[[TTURLRequestQueue mainQueue] setMaxContentLength:0];

	// observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
	// method "reachabilityChanged" will be called.
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(reachabilityChanged:)
	                                             name:kReachabilityChangedNotification
	                                           object:nil];
	hostReach = [[Reachability reachabilityWithHostName:@"www.apple.com"] retain];
	[hostReach startNotifier];

	// configure ttnavigator
	TTNavigator *navigator = [TTNavigator navigator];
	navigator.supportsShakeToReload = YES;
	navigator.persistenceMode = TTNavigatorPersistenceModeAll;

	// !!! IMPORTANT: create urlmaps !!!
	TTURLMap *map = navigator.URLMap;

	// dispatcher: will choose either album- or thumb-view
	[map
	             from:@"tt://root/(rootController:)"
	 toViewController:self
	       transition:UIViewAnimationTransitionFlipFromLeft];

	// album-view
	[map
	             from:@"tt://album/(initWithItemID:)"
	 toViewController:[MyThumbsViewController2 class]];

	// thumbnail-view
	[map
	             from:@"tt://thumbs/(initWithAlbumID:)"
	 toViewController:[MyThumbsViewController class]
	       transition:UIViewAnimationTransitionCurlDown];

	// photo-view
	[map
	             from:@ "tt://photo/(initWithItemID:)"
	 toViewController:[MyPhotoViewController class]
	       transition:UIViewAnimationTransitionCurlUp];
	[map
	             from:@ "tt://photo/(initWithItemID:)/(atIndex:)"
	 toViewController:[MyPhotoViewController class]
	       transition:UIViewAnimationTransitionCurlUp];
	[map
	             from:@ "tt://photo"
	 toViewController:[MyPhotoViewController class]
	       transition:UIViewAnimationTransitionCurlUp];

	// comments-view
	[map
	             from:@ "tt://comments/(initWithItemID:)"
	 toViewController:[MyCommentsViewController
	                   class]
	       transition:UIViewAnimationTransitionFlipFromLeft];

	// login-view
	[map
	             from:@ "tt://login"
	 toViewController:[MyLoginViewController class]
	       transition:UIViewAnimationTransitionFlipFromLeft];

	// load custom view with query (may have associated nib-file)
	[map
	       from:@ "tt://loadFromVC/(loadFromVC:)" toViewController:self
	 transition:UIViewAnimationTransitionFlipFromLeft];

	// load custom view from nib-file (with controller that has same name)
	[map
	       from:@ "tt://nib/(loadFromNib:)" toViewController:self
	 transition:UIViewAnimationTransitionFlipFromLeft];

	// setup database
	[MyDatabase copyDatabaseToDocuments];

	// temporary until everything is changed to GlobalSettings approach
	self.baseURL = nil;
	self.challenge = nil;
	self.baseURL = GlobalSettings.baseURL;
	self.challenge = GlobalSettings.challenge;

	// restore view-controllers otherwise login
	if (![navigator restoreViewControllers]) {
		if ([GlobalSettings.baseURL isEqual:@ ""] || GlobalSettings.baseURL == nil ||
		    GlobalSettings.challenge == nil) {
			[navigator openURLAction:[[TTURLAction actionWithURLPath:@ "tt://login"]
			                          applyAnimated:YES]];
		}
		else {
			[navigator openURLAction:[[TTURLAction actionWithURLPath:@ "tt://root/1"]
			                          applyAnimated:YES]];
		}
	}
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)URL {
	[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
	return YES;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MyLoginDelegate

// Login finished, re-init
- (void)finishedLogin {
	// temporary until everything is changed to GlobalSettings
	self.baseURL = nil;
	self.challenge = nil;
	self.baseURL = GlobalSettings.baseURL;
	self.challenge = GlobalSettings.challenge;
	TTNavigator *navigator = [TTNavigator navigator];
	[navigator removeAllViewControllers];
	[navigator openURLAction:[TTURLAction actionWithURLPath:@ "tt://root/1"]];
}


- (void)dispatchToRootController:(id)sender {
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	if (segmentedControl.selectedSegmentIndex == 0) {
		GlobalSettings.viewStyle = kAlbumView;
	}
	if (segmentedControl.selectedSegmentIndex == 1) {
		GlobalSettings.viewStyle = kThumbView;
	}
	return [self rootController:nil];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark private

// Loads the given viewcontroller from the nib
- (UIViewController *)loadFromNib:(NSString *)nibName withClass:className withQuery:(NSDictionary *)
       query {
	UIViewController *newController = [[NSClassFromString (className)alloc]
	                                   initWithNibName:nibName bundle:nil];
	[newController autorelease];
	[newController setParams:query];
	return newController;
}


// Loads the given viewcontroller from the the nib with the same name as the class
- (UIViewController *)loadFromNib:(NSString *)className query:(NSDictionary *)query {
	return [self loadFromNib:className withClass:className withQuery:query];
}


// Loads the given viewcontroller by name
- (UIViewController *)loadFromVC:(NSString *)className query:(NSDictionary *)query {
	UIViewController *newController = [[NSClassFromString (className)alloc] init];
	[newController autorelease];
	[newController setParams:query];
	return newController;
}


// Removes all viewcontrollers and redirects to album- or thumb-view
- (void)rootController:(NSNull *)null {
	// setup RestKit
	[self initRestKit];
	TTNavigator *navigator = [TTNavigator navigator];
	[navigator.rootViewController.navigationController popToViewController:navigator.
	 rootViewController                                           animated:YES];
	if (GlobalSettings.viewStyle == kAlbumView) {
		[navigator openURLAction:[[TTURLAction actionWithURLPath:@ "tt://album/1"]
		                          applyAnimated:YES]];
	}
	if (GlobalSettings.viewStyle == kThumbView) {
		[navigator removeAllViewControllers];
		[navigator openURLAction:[[TTURLAction actionWithURLPath:@ "tt://thumbs/1"]
		                          applyAnimated:YES]];
	}
}


// Initializes RestKit
- (void)initRestKit {
	RKObjectManager *objectManager =
	        [RKObjectManager objectManagerWithBaseURL:GlobalSettings.baseURL];
	RKObjectMapper *mapper = objectManager.mapper;

	// Initialize object store
	objectManager.objectStore =
	        [[[RKManagedObjectStore alloc] initWithStoreFilename:@ "g3CoreData.sqlite"]
	         autorelease];
	objectManager.objectStore.managedObjectCache = [[DBManagedObjectCache new] autorelease];

	// Set nil for any attributes we expect to appear in the payload, but do not
	objectManager.mapper.missingElementMappingPolicy = RKSetNilForMissingElementMappingPolicy;

	// Add our element to object mappings
	[mapper registerClass:[RKOEntity class] forElementNamed:@ "entity"];
	[mapper registerClass:[RKOTags class] forElementNamed:@ "tags"];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Reachability

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification *)note {
	Reachability *curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:curReach];
}


// Notifies user with alert message if connection is gone
- (void)updateInterfaceWithReachability:(Reachability *)curReach {
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	switch (netStatus) {
	case NotReachable: {
		UIAlertView *dialog = [[[UIAlertView alloc] init] autorelease];
		[dialog setDelegate:self];
		[dialog setTitle:@ "Network Lost"];
		dialog.message = @ "Internet connection required \nto browse new content!";
		[dialog addButtonWithTitle:@ "OK"];
		[dialog show];
		break;
	}

	case ReachableViaWiFi:
		break;

	case ReachableViaWWAN:
		break;
	}
}


@end