//
//  MyDatabase.h
//  g3Mobile
//
//  Created by David Steinberger on 1/6/11.
//  Copyright 2011 -. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyDatabase : NSObject {

}

+ (NSString *)copyDatabaseToDocuments;
+ (NSDictionary*) readSettingsFromDatabase;

@end
