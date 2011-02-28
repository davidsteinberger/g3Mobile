#import "Three20/Three20.h"

#import "AppDelegate.h"

#import "MyThumbsViewController.h"
#import "MyCommentsViewController.h"
#import "MySettingsController.h"
#import "MyLoginViewController.h"
#import "AddAlbumViewController.h"

#import "MyDatabase.h"

#import "MyAlbum.h"
#import <sqlite3.h>

#import "Reachability.h"

#import "MyUploadViewController.h"
#import "StyleSheet.h"

#import "UIViewController+params.h"
#import "MyPostController.h"

#import "MySettings.h"

#import "MyRestTest.h"
#import "MyRestResource.h"
#import "MyThumbsViewController2.h"
#import "MyPhotoViewController.h"

@implementation AppDelegate

@synthesize user = _user;
@synthesize password = _password;
@synthesize challenge = _challenge;
@synthesize baseURL = _baseURL;


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIApplicationDelegate


- (void)dealloc {
	TT_RELEASE_SAFELY(self->_user);
	TT_RELEASE_SAFELY(self->_password);
	TT_RELEASE_SAFELY(self->_challenge);
	TT_RELEASE_SAFELY(self->_baseURL);
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication*)application {
	// set stylesheet
	[TTStyleSheet setGlobalStyleSheet:[[[StyleSheet alloc] init] autorelease]];
	[[TTURLRequestQueue mainQueue] setMaxContentLength:0];
	 
	// observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	hostReach = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
	[hostReach startNotifier];

	// configure ttnavigator
	TTNavigator* navigator = [TTNavigator navigator];
	navigator.supportsShakeToReload = YES;
	navigator.persistenceMode = TTNavigatorPersistenceModeAll;

	// !!! IMPORTANT: create urlmaps !!!
	TTURLMap* map = navigator.URLMap;
	// dispatcher: will choose either album- or thumb-view
	[map from:@"tt://root/(rootController:)" toViewController:self
     transition:UIViewAnimationTransitionFlipFromLeft];
	// album-view
	[map from:@"tt://album/(initWithItemID:)" toViewController:[MyThumbsViewController2 class]];
	// thumbnails-view
	[map from:@"tt://thumbs/(initWithAlbumID:)" toViewController:[MyThumbsViewController class]
     transition:UIViewAnimationTransitionCurlDown];
	// photo-view
	[map from:@"tt://photo/(initWithItemID:)" toViewController:[MyPhotoViewController class]
	 transition:UIViewAnimationTransitionCurlUp];
	[map from:@"tt://photo/(initWithItemID:)/(atIndex:)" toViewController:[MyPhotoViewController class]
	 transition:UIViewAnimationTransitionCurlUp];
	[map from:@"tt://photo" toViewController:[MyPhotoViewController class]
	 transition:UIViewAnimationTransitionCurlUp];
    // comments-view
	[map from:@"tt://comments/(initWithItemID:)" toViewController:[MyCommentsViewController class]
	transition:UIViewAnimationTransitionFlipFromLeft];
	// login-view
	[map from:@"tt://login" toViewController:[MyLoginViewController class]
	transition:UIViewAnimationTransitionFlipFromLeft];
	// load custom view with query (may have associated nib-file)
	[map from:@"tt://loadFromVC/(loadFromVC:)" toViewController:self
	transition:UIViewAnimationTransitionFlipFromLeft]; 
	// load custom view from nib-file (with controller that has same name)
	[map from:@"tt://nib/(loadFromNib:)" toViewController:self
	transition:UIViewAnimationTransitionFlipFromLeft];
	
	// setup database
	[MyDatabase copyDatabaseToDocuments];
	
	// temporary until everything is changed to GlobalSettings
	self.baseURL = nil;
	self.challenge = nil;
	self.baseURL = GlobalSettings.baseURL;
	self.challenge = GlobalSettings.challenge;
	
	// restore view-controllers otherwise login
	if (![navigator restoreViewControllers]) {
		if (GlobalSettings.baseURL == nil || GlobalSettings.challenge == nil) {
			[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://login"] applyAnimated:YES]];
		}
		else {			
			[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://root/1"] applyAnimated:YES]];
		}
	}
}

- (void)finishedLogin {	
	// temporary until everything is changed to GlobalSettings
	self.baseURL = nil;
	self.challenge = nil;
	self.baseURL = GlobalSettings.baseURL;
	self.challenge = GlobalSettings.challenge;
	
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator removeAllViewControllers];
	[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://root/1"]];
}

/*
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
  return YES;
}
*/

///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Loads the given viewcontroller from the nib
 */
- (UIViewController*)loadFromNib:(NSString *)nibName withClass:className withQuery:(NSDictionary*)query {
	UIViewController* newController = [[NSClassFromString(className) alloc]
									   initWithNibName:nibName bundle:nil];
	[newController autorelease];
	
	[newController setParams:query];
	
	return newController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Loads the given viewcontroller from the the nib with the same name as the
 * class
 */
- (UIViewController*)loadFromNib:(NSString*)className query:(NSDictionary*)query {
	//NSLog(@"query: %@", query);
	return [self loadFromNib:className withClass:className withQuery:query];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Loads the given viewcontroller by name
 */
- (UIViewController *)loadFromVC:(NSString *)className query:(NSDictionary*)query {
	UIViewController * newController = [[ NSClassFromString(className) alloc] init];
	[newController autorelease];
	
	[newController setParams:query];
	
	return newController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
	[[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
	return YES;
}

- (void)rootController:(NSNull*)null {
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator.rootViewController.navigationController popToViewController:navigator.rootViewController animated:YES];
	
	if ( GlobalSettings.viewStyle == kAlbumView) {
		[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://album/1"] applyAnimated:YES]];
	} 
	if ( GlobalSettings.viewStyle == kThumbView) {
		[navigator openURLAction:[[TTURLAction actionWithURLPath:@"tt://thumbs/1"] applyAnimated:YES]];
	}
}

// Dispatcher
- (void)dispatchToRootController:(id)sender {
	UISegmentedControl* segmentedControl = (UISegmentedControl*)sender;
	
	if ( segmentedControl.selectedSegmentIndex == 0) {
		GlobalSettings.viewStyle = kAlbumView;
	} 
	if ( segmentedControl.selectedSegmentIndex == 1) {
		GlobalSettings.viewStyle = kThumbView;
	}
	return [self rootController:nil];
}


#pragma mark -
#pragma mark Reachability

///////////////////////////////////////////////////////////////////////////////////////////////////
// Reachability

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note {
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach {
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	switch (netStatus)
	{
		case NotReachable:
		{
			UIAlertView *dialog = [[[UIAlertView alloc] init] autorelease];
			[dialog setDelegate:self];
			[dialog setTitle:@"Network Lost"];
			dialog.message = @"Internet connection required \nto browse new content!";
			[dialog addButtonWithTitle:@"OK"];
			[dialog show];
			break;
		}
		case ReachableViaWiFi:
		case ReachableViaWWAN:
		{
			break;
		}
	}
}

@end
