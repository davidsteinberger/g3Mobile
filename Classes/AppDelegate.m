#import "Three20/Three20.h"

#import "AppDelegate.h"
//#import "PhotoTest1Controller.h"
#import "MyAlbum.h"
#import "MyThumbsViewController.h"
#import "MyCommentsViewController.h"
#import "MySettingsController.h"
#import "MyLoginViewController.h"
#import <sqlite3.h>



@implementation AppDelegate

@synthesize user = _user;
@synthesize password = _password;
@synthesize challenge = _challenge;
@synthesize baseURL = _baseURL;

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication*)application {

	
//	self.baseURL = @"http://localhost/~David/gallery3/index.php";
//	self.baseURL = @"http://192.168.0.4/~David/gallery3/index.php";
//	self.baseURL = @"http://www.david-steinberger.at/gallery3";
	
//	NSLog(@"user: %@", self.user);
//	NSLog(@"password: %@", self.password);
//	[self login];
	
	TTNavigator* navigator = [TTNavigator navigator];
	navigator.supportsShakeToReload = YES;
	navigator.persistenceMode = TTNavigatorPersistenceModeAll;

	TTURLMap* map = navigator.URLMap;
	
	[map from:@"tt://thumbs/(initWithAlbumID:)" toViewController:[MyThumbsViewController class]];
	[map from:@"tt://comments/(initWithItemID:)" toViewController:[MyCommentsViewController class]
	transition:UIViewAnimationTransitionFlipFromLeft];
	[map from:@"tt://upload/(uploadImage:)" toViewController:[MyThumbsViewController class]
	transition:UIViewAnimationTransitionFlipFromLeft];
	[map from:@"tt://login" toModalViewController:[MyLoginViewController class]
	transition:UIViewAnimationTransitionFlipFromLeft];
	
	NSString* dbFilePath = [self copyDatabaseToDocuments];
	[self readSettingsFromDatabaseWithPath:dbFilePath];
	
	if (![navigator restoreViewControllers]) {
		if (self.baseURL == nil || self.challenge == nil) {
			[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://login"]];
		}
		else {
			[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://thumbs/1"]];
		}

	}
}

- (void)finishedLogin {
	
	//NSLog(@"baseURL: %@", self.baseURL);
	//NSLog(@"user: %@", self.user);
	//NSLog(@"password: %@", self.password);
	//NSLog(@"challenge: %@", self.challenge);
	
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator removeAllViewControllers];
	[navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://thumbs/1"]];
}
/*
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
  return YES;
}
*/
#pragma mark Database Methods

- (NSString *)copyDatabaseToDocuments {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"g3DB.sqlite"];
	//NSLog(@"filePath: %@", filePath);
    if ( ![fileManager fileExistsAtPath:filePath] ) {
        NSString *bundleCopy = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"g3DB.sqlite"];
		[fileManager copyItemAtPath:bundleCopy toPath:filePath error:nil];
    }
    return [filePath retain];
}

-(void) readSettingsFromDatabaseWithPath:(NSString *)filePath {
	sqlite3 *database;
	
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		const char *sqlStatement = "select var, value from settings";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				
				NSString *var = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				NSString *value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
				
				if ([var isEqual:@"baseURL"]) {
					self.baseURL = value;					
				}
				else if ([var isEqual:@"username"]){
					self.user = value;
				}
				else if ([var isEqual:@"password"]){
					self.password = value;
				}
				else if ([var isEqual:@"challenge"]){
					self.challenge = value;
				}
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
}

-(void)login {
	NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self.baseURL stringByAppendingString:@"/rest"]]];
	
	//set HTTP Method
	[request1 setHTTPMethod:@"POST"];
	
	//Implement request_body for send request here username and password set into the body.
	NSString *request_body = [NSString 
							  stringWithFormat:@"user=%@&password=%@",
							  [self.user        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							  [self.password    stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
							  ];
	//set request body into HTTPBody.
	[request1 setHTTPBody:[request_body dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	//set request url to the NSURLConnection
	NSData *returnedData = [NSURLConnection sendSynchronousRequest:request1
												 returningResponse:&response error:&error];	
	[request1 release];
	NSString* returnString = [[[[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding] substringFromIndex: 1] substringToIndex:[self.challenge length] - 1];

	self.challenge = returnString;
	TT_RELEASE_SAFELY(returnString);

	//[returnString release];
	//NSLog(@"response: %@", [[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding]);
}

@end
