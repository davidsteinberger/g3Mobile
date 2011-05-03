//
//  MyCredentials.m
//  g3Mobile
//
//  Created by David Steinberger on 12/27/10.
//  Copyright 2010 -. All rights reserved.
//

#import "MySettings.h"
#import "SynthesizeSingleton.h"
#import "Vars.h"
#import "Param.h"

#import "CoreDAta/CoreData.h"

// RestKit
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@interface MySettings ()
	@property(nonatomic, readwrite, retain) NSString* username;
	@property(nonatomic, readwrite, retain) NSString* password;
	@property(nonatomic, readwrite, retain) NSString* challenge;
	@property(nonatomic, readwrite, retain) NSString* baseURL;

- (NSSet*) readVars;
- (NSString*) getValue:(NSString*)name;
- (BOOL)storeName:(NSString*)name withValue:(NSString*)value;
- (NSManagedObjectContext *) managedObjectContext;
- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
@end


@implementation MySettings

@synthesize viewOnly = _viewOnly;
@synthesize username = _username;
@synthesize password = _password;
@synthesize challenge = _challenge;
@synthesize baseURL = _baseURL;
@synthesize imageQuality = _imageQuality;
@synthesize viewStyle = _viewStyle;

SYNTHESIZE_SINGLETON_FOR_CLASS(MySettings);

- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    [super dealloc];
}

- (void)save:(NSString*)baseURL 
	 withUsername:(NSString*)username 
 withPassword:(NSString*)password
withChallenge:(NSString*)challenge 
withImageQuality:(float) imageQuality {

	self.baseURL = baseURL;
	self.username = username;
	self.password = password;
	self.challenge = challenge;
	
	self.imageQuality = imageQuality;
}

- (BOOL)viewOnly {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	BOOL viewOnly = [prefs boolForKey:@"viewOnly"];
    
    if (!viewOnly) {
        viewOnly = [[self getValue:@"viewOnly"] boolValue];
    }
	
    self->_viewOnly = viewOnly;
	return viewOnly;
}

- (void)setViewOnly:(BOOL)viewOnly {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setBool:viewOnly forKey:@"viewOnly"];	
    [self storeName:@"viewOnly" withValue:[NSString stringWithFormat:@"%d", viewOnly]];
	[prefs synchronize];
}

- (NSString*)baseURL {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString* baseURL = [prefs stringForKey:@"baseURL"];

	if (!baseURL || [baseURL isEqual:@""]) {
		//baseURL = [[MyDatabase readSettingsFromDatabase] objectForKey:@"baseURL"];
        baseURL = [self getValue:@"baseURL"];
	}
    
	self->_baseURL = (baseURL) ? baseURL : @"";
	return (baseURL) ? baseURL : @"";
}

- (void)setBaseURL:(NSString*)baseURL {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setObject:baseURL forKey:@"baseURL"];	
    [self storeName:@"baseURL" withValue:baseURL];
	[prefs synchronize];
}

- (NSString*)challenge {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString* challenge = [prefs stringForKey:@"challenge"];
	
	if (!challenge || [challenge isEqual:@""]) {
		//challenge = [[MyDatabase readSettingsFromDatabase] objectForKey:@"challenge"];
        challenge = [self getValue:@"challenge"];
	}
	
    self->_challenge = (challenge) ? challenge : @"";
	return (challenge) ? challenge : @"";
}

- (void)setChallenge:(NSString*)challenge {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setObject:challenge forKey:@"challenge"];
	[self storeName:@"challenge" withValue:challenge];
	[prefs synchronize];
}

- (void)setUsername:(NSString *)username {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:username forKey:@"username"];
    [self storeName:@"username" withValue:username];
    [prefs synchronize];
}

- (NSString*)username {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString* username = [prefs stringForKey:@"username"];
	
	if (!username) {
		//username = [[MyDatabase readSettingsFromDatabase] objectForKey:@"username"];		
        username = [self getValue:@"username"];
	}
	
    self->_username = (username) ? username : @"username";
	return (username) ? username : @"username";
}

- (NSString*)password {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString* password = [prefs stringForKey:@"password"];
	
	if (!password) {
		//password = [[MyDatabase readSettingsFromDatabase] objectForKey:@"password"];		
        password = [self getValue:@"password"];
	}
	
    self->_password = (password) ? password : @"";
	return (password) ? password : @"";
}

- (void)setImageQuality:(float)imageQuality {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setFloat:imageQuality forKey:@"imageQuality"];
	[self storeName:@"imageQuality" withValue:[NSString stringWithFormat:@"%f",imageQuality]];
	[prefs synchronize];	
}

- (float)imageQuality {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	float imageQuality = [prefs floatForKey:@"imageQuality"];
    
    if (imageQuality == 0) {
        imageQuality = [[self getValue:@"imageQuality"] floatValue];
    }
    
    self->_imageQuality = imageQuality;
    return imageQuality;
}

- (void)setViewStyle:(MyViewStyle)viewStyle {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setInteger:viewStyle forKey:@"viewStyle"];	
    [self storeName:@"viewStyle" withValue:[NSString stringWithFormat:@"%i",viewStyle]];
	[prefs synchronize];
}

- (MyViewStyle)viewStyle {
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	int viewStyle = [prefs integerForKey:@"viewStyle"];
    
    if (!viewStyle) {
        viewStyle = [[self getValue:@"viewStyle"] intValue];
    }
    
    self->_viewStyle = viewStyle;
    return viewStyle;
}



- (BOOL)storeName:(NSString*)name withValue:(NSString*)value {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vars" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    int cnt = 0;
    Vars* vars_f;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) {
        vars_f = (Vars*)[fetchedObjects objectAtIndex:0];
        cnt = [vars_f.params count];
    }
    
    [fetchRequest release];
    
    Vars* vars_n = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Vars" 
                    inManagedObjectContext:context];
    Param* var_n = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Param" 
                    inManagedObjectContext:context];
    
    if ( cnt > 0) {
        NSSet* params_s = vars_f.params;
        NSMutableSet* params_sm = [NSMutableSet setWithSet:params_s];
        
        // delete old parameter
        for (Param* var in params_s) {
            if ([var.name isEqualToString:name]) {
                [params_sm removeObject:var];
            }
        }
        // delete the whole config-object
        [context deleteObject:vars_f];
        
        //create the new object
        var_n.name = name;
        var_n.value = value;
        [params_sm addObject:var_n];
        vars_n.params = params_sm;
    } else {
        // no parameter exists
        // -> set object
        var_n.name = name;
        var_n.value = value;
        NSSet* tmp = [NSSet setWithObject:var_n];
        vars_n.params = tmp;
    }
    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return NO;
    } else {
        return YES;
    }
}

- (NSSet*) readVars {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Test listing all FailedBankInfos from the store
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Vars" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) {
        /*for (Vars* vars in fetchedObjects) {
         NSSet* var = vars.params;
         for (Var* param in var) {
         NSLog(@"Name: %@", param.name);
         NSLog(@"Value: %@", param.value);                
         }
         }*/
        return ((Vars*)[fetchedObjects objectAtIndex:0]).params;
    } 
    
    return nil;
}

- (NSString*) getValue:(NSString*)name {
    NSSet* allVars = [self readVars];
    NSArray* allObjects = [allVars allObjects];
    
    for (Param* var in allObjects) {
        if ([var.name isEqualToString:name]) {
            return var.value;
        }
    }
    
    return nil;
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"G3CoreData.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end
