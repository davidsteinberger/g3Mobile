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
#import <RestKit/CoreData/CoreData.h>
#import "RKMEntity.h"
#import "RKMItem.h"
#import "RKMTree.h"
#import "RKMSites.h"

// ViewControllers
#import "AddAlbumViewController.h"
#import "DBManagedObjectCache.h"
#import "MyCommentsViewController.h"
#import "MyLoginViewController.h"
#import "MyPhotoViewController.h"
#import "MyThumbsViewController.h"
#import "MyThumbsViewController2.h"
#import "MyUploadViewController.h"

#import "UIViewController+query.h"

// Reachability
#import "Reachability.h"

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

	// observe the kNetworkReachabilityChangedNotification. When that notification is posted,
	// the
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

	[self initRestKit];

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
	if ([URL.scheme isEqualToString:[@"fb" stringByAppendingString:kAppId]])
		return [[Facebook sharedFacebook] handleOpenURL:URL];
	else {
		[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.
		                                        absoluteString]];
		return YES;
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MyLoginDelegate

// Login finished, re-init
- (void)finishedLogin {
	[self initRestKit];

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
	[newController setQuery:query];
	return [newController autorelease];
}


// Loads the given viewcontroller from the the nib with the same name as the class
- (UIViewController *)loadFromNib:(NSString *)className query:(NSDictionary *)query {
	return [self loadFromNib:className withClass:className withQuery:query];
}


// Loads the given viewcontroller by name
- (UIViewController *)loadFromVC:(NSString *)className query:(NSDictionary *)query {
	UIViewController *newController = [[NSClassFromString (className)alloc] init];
	[newController setQuery:query];
	return [newController autorelease];
}


// Removes all viewcontrollers and redirects to album- or thumb-view
- (void)rootController:(NSNull *)null {
	TTNavigator *navigator = [TTNavigator navigator];
	[navigator removeAllViewControllers];
	if (GlobalSettings.viewStyle == kAlbumView) {
		[navigator openURLAction:[[TTURLAction actionWithURLPath:@ "tt://album/1"]
		                          applyAnimated:YES]];
	}
	if (GlobalSettings.viewStyle == kThumbView) {
		[navigator openURLAction:[[TTURLAction actionWithURLPath:@ "tt://thumbs/1"]
		                          applyAnimated:YES]];
	}
}


// Initializes RestKit
- (void)initRestKit {
	/*
	 * If RestKit hasn't been loaded before
	 *   -> full init of the library
	 * Else:
	 *   -> Only update the BaseURL and the new HTTP-Headers
	 *      (because those might have changed with the login)
	 *      see:
	 *****http://groups.google.com/group/restkit/browse_thread/thread/0566b4a670b5355b/79cc36f28c4d63ea#79cc36f28c4d63ea
	 */
	if (!_isRestKitLoad) {
		_isRestKitLoad = YES;

		//RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);

		NSString *baseURL =
		        ([GlobalSettings.baseURL isEqualToString:@""]) ? @"http://www.google.com" :
		        GlobalSettings.baseURL;
		RKObjectManager *objectManager = [RKObjectManager objectManagerWithBaseURL:baseURL];

		// Initialize object store
		objectManager.objectStore =
		        [[[RKManagedObjectStore alloc] initWithStoreFilename:@ "g3CoreData.sqlite"]
		         autorelease];
		objectManager.objectStore.managedObjectCache =
		        [[DBManagedObjectCache new] autorelease];

		[RKObjectManager sharedManager].client.cachePolicy = RKRequestCachePolicyNone;

		// even strange mime types should be parsed with JSONKit
		[[RKParserRegistry sharedRegistry] setParserClass:NSClassFromString(
		         @"RKJSONParserJSONKit")
		                                      forMIMEType:@"text/html"];
		[[RKParserRegistry sharedRegistry] setParserClass:NSClassFromString(
		         @"RKJSONParserJSONKit")
		                                      forMIMEType:@"text/plain"];

		// Set Gallery3 specific HTTP headers
		[[objectManager client] setValue:GlobalSettings.challenge forHTTPHeaderField:
		 @"X-Gallery-Request-Key"];
		[[objectManager client] setValue:@"application/x-www-form-urlencoded"
		              forHTTPHeaderField:@"Content-Type"];

		// Create the mappings
		RKObjectMappingProvider *mappingProvider =
		        [[RKObjectMappingProvider new] autorelease];

		RKManagedObjectMapping *tagMemberMapping =
		        [RKManagedObjectMapping mappingForClass:[RKMTag_Member class]];
		tagMemberMapping.setNilForMissingRelationships = YES;
		tagMemberMapping.primaryKeyAttribute = @"url";
		[tagMemberMapping mapKeyPathsToAttributes:
		 @"entity.tag.url", @"url",
		 @"entity.tag.entity.name", @"name",
		 @"entity.tag.entity.count", @"count",
		 nil];

		RKManagedObjectMapping *entityMapping =
		        [RKManagedObjectMapping mappingForClass:[RKMEntity class]];
		entityMapping.setNilForMissingRelationships = YES;
		entityMapping.primaryKeyAttribute = @"created";
		[entityMapping mapKeyPath:@"id" toAttribute:@"itemID"];
		[entityMapping mapKeyPath:@"description" toAttribute:@"desc"];
		[entityMapping mapAttributes:@"title", @"name", @"type", @"thumb_url_public",
		 @"thumb_url", @"resize_url_public", @"resize_url", @"file_url", @"file_url_public",
		 @"thumb_width", @"thumb_height", @"created", @"positionInAlbum", @"parent",
		 @"slug", @"web_url",
		 nil];

		RKManagedObjectMapping *itemMapping =
		        [RKManagedObjectMapping mappingForClass:[RKMItem class]];
		itemMapping.primaryKeyAttribute = @"url";
		[itemMapping mapAttributes:@"url", @"members", nil];
		[itemMapping mapKeyPath:@"entity" toRelationship:@"rEntity" withMapping:
		 entityMapping];
		[itemMapping mapKeyPath:@"relationships.tags.members" toRelationship:@"rTags"
		            withMapping:tagMemberMapping];

		RKManagedObjectMapping *treeMapping =
		        [RKManagedObjectMapping mappingForClass:[RKMTree class]];
		treeMapping.primaryKeyAttribute = @"url";
		[treeMapping mapKeyPathsToAttributes:@"url", @"url", nil];
		[treeMapping mapKeyPath:@"entity.entity" toRelationship:@"rEntity" withMapping:
		 entityMapping];

		RKManagedObjectMapping *siteMapping =
		        [RKManagedObjectMapping mappingForClass:[RKMSite class]];
		siteMapping.primaryKeyAttribute = @"url";
		[siteMapping mapAttributes:@"title", @"url", nil];

		RKManagedObjectMapping *sitesMapping =
		        [RKManagedObjectMapping mappingForClass:[RKMSites class]];
		sitesMapping.primaryKeyAttribute = @"type";
		[sitesMapping mapAttributes:@"type", nil];
		[sitesMapping mapKeyPath:@"sites" toRelationship:@"rSite" withMapping:siteMapping];

		[mappingProvider addObjectMapping:sitesMapping];
		[mappingProvider addObjectMapping:itemMapping];
		[mappingProvider addObjectMapping:treeMapping];

		objectManager.mappingProvider = mappingProvider;
	}
	else if (_isRestKitLoad) {
		[RKObjectManager sharedManager].client.baseURL = GlobalSettings.baseURL;
		[[RKObjectManager sharedManager].client
		 setValue:GlobalSettings.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
		[[RKObjectManager sharedManager].client
		 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	}
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