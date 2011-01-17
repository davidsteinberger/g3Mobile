//
//  MyDatabase.m
//  g3Mobile
//
//  Created by David Steinberger on 1/6/11.
//  Copyright 2011 -. All rights reserved.
//

#import "MyDatabase.h"

#import <sqlite3.h>


@implementation MyDatabase

+ (NSString *)copyDatabaseToDocuments {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"g3DB.sqlite"];
    if ( ![fileManager fileExistsAtPath:filePath] ) {
        NSString *bundleCopy = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"g3DB.sqlite"];
		[fileManager copyItemAtPath:bundleCopy toPath:filePath error:nil];
    }
    //NSLog(@"path: %@", filePath);
	return [NSString stringWithString:filePath];
}

+ (NSDictionary*) readSettingsFromDatabase {
	sqlite3 *database;
	
	NSString *filePath = [self copyDatabaseToDocuments];
	
	NSString* baseURL = @"";
	NSString* challenge = @"";
	NSString* username = @"";
	NSString* password = @"";
	
	if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
		const char *sqlStatement = "select var, value from settings";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				
				@try {
					NSString *var = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
					NSString *value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
					
					if ([var isEqual:@"baseURL"]) {
						baseURL = value;
					}
					else if ([var isEqual:@"username"]){
						username = value;
					}
					else if ([var isEqual:@"password"]){
						password = value;
					}
					else if ([var isEqual:@"challenge"]){
						challenge = value;
					}
				} @catch (NSException* e) {
					
				}
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			baseURL, @"baseURL", username, @"username", password, @"password", challenge, @"challenge",nil];
}

@end
