//
//  MyCredentials.h
//  g3Mobile
//
//  Created by David Steinberger on 12/27/10.
//  Copyright 2010 -. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreData/CoreData.h"

static NSString* kAppId = @"153647701377559";
static NSString* rootAlbumID = @"16684";

#define GlobalSettings \
((MySettings *)[MySettings sharedMySettings])

typedef enum {
	kAlbumView,
	kThumbView
} MyViewStyle;

@interface MySettings : NSObject {
	BOOL _viewOnly;
	NSString* _username;
	NSString* _password;
	NSString* _challenge;
	NSString* _baseURL;
	
	float _imageQuality;
    int _slideshowTimeout;
	int _uploadCounter;
    BOOL _showFBOnUploader;
    
	//UI settings
	MyViewStyle _viewStyle;
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, assign) BOOL viewOnly;
@property (nonatomic, readonly, retain) NSString* challenge;
@property (nonatomic, readonly, retain) NSString* baseURL;
@property (nonatomic, assign) float imageQuality;
@property (nonatomic, assign) int slideshowTimeout;
@property (nonatomic, assign) MyViewStyle viewStyle;
@property (nonatomic, assign) int uploadCounter;
@property (nonatomic, assign) BOOL showFBOnUploader;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (MySettings *)sharedMySettings;
- (void)save:(NSString*)baseURL 
withUsername:(NSString*)username 
withPassword:(NSString*)password
withChallenge:(NSString*)challenge 
withImageQuality:(float) imageQuality;
- (float)imageQuality;

@end
