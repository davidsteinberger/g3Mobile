#import "Three20/Three20.h"

#import "AppDelegate.h"
#import "CatalogController.h"
#import "PhotoTest1Controller.h"
#import "MyAlbum.h"
#import "MyThumbsViewController.h"
#import "MyCommentsViewController.h"
#import "sqlite3.h"

@implementation AppDelegate

@synthesize user = _user;
@synthesize password = _password;
@synthesize challenge = _challenge;
@synthesize baseURL = _baseURL;

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication*)application {
	NSString *filePath = [self copyDatabaseToDocuments];
	[self readSettingsFromDatabaseWithPath:filePath];
	self.baseURL = @"http://localhost/~David/gallery3/index.php";
//	self.baseURL = @"http://192.168.0.10/~David/gallery3/index.php";
//	self.baseURL = @"http://www.david-steinberger.at/gallery3";
	
	NSLog(@"user: %@", self.user);
	NSLog(@"password: %@", self.password);
	[self login];
	
  TTNavigator* navigator = [TTNavigator navigator];
  navigator.supportsShakeToReload = YES;
  navigator.persistenceMode = TTNavigatorPersistenceModeAll;

  TTURLMap* map = navigator.URLMap;
  [map from:@"*" toViewController:[TTWebController class]];
  [map from:@"tt://catalog" toViewController:[CatalogController class]];
  [map from:@"tt://photoTest1" toViewController:[PhotoTest1Controller class]];
  [map from:@"tt://photoTest2/(initWithAlbumID:)" toViewController:[MyThumbsViewController class]];
	
	[map from:@"tt://comments/(initWithItemID:)" toViewController:[MyCommentsViewController class]
	 transition:UIViewAnimationTransitionFlipFromLeft];
	[map from:@"tt://upload/(uploadImage:)" toViewController:[MyThumbsViewController class]
	 transition:UIViewAnimationTransitionFlipFromLeft];

  if (![navigator restoreViewControllers]) {
    [navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://photoTest2/1"]];
//	  [navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://upload/"]];
  }
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
  [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
  return YES;
}

#pragma mark Database Methods

- (NSString *)copyDatabaseToDocuments {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"g3DB.sqlite"];
	
    if ( ![fileManager fileExistsAtPath:filePath] ) {
        NSString *bundleCopy = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"g3DB.sqlite"];
		[fileManager copyItemAtPath:bundleCopy toPath:filePath error:nil];
    }
    return filePath;
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
				
				if ([var isEqual:@"user"]) {
					self.user = value;					
				}
				else {
					self.password = value;
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
	self.challenge = [[[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding] substringFromIndex: 1];
	self.challenge = [self.challenge substringToIndex:[self.challenge length] - 1];
	NSLog(@"response: %@", [[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding]);
}

@end
