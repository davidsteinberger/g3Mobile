//
//  DBManagedObjectCache.m
//  DiscussionBoard
//
//  Created by Jeremy Ellison on 1/10/11.
//  Copyright 2011 Two Toasters. All rights reserved.
//

#import "DBManagedObjectCache.h"
#import "AppDelegate.h"
#import "RKMResponse.h"
#import "RKOEntity.h"
#import "MySettings.h"
#import "RKOItem.h"

@implementation DBManagedObjectCache

- (NSArray*)fetchRequestsForResourcePath:(NSString*)resourcePath {
		
 	NSString* predicateString = [GlobalSettings.baseURL stringByAppendingString:resourcePath];
	//NSLog(@"%@", predicateString);
	
	NSArray* components = [resourcePath componentsSeparatedByString:@"/"];
	NSString* restResource = [components objectAtIndex:2];
	//NSLog(@"%@", restResource);
	
	if ([restResource isEqual:@"tree"]) {
		NSFetchRequest* request = [RKMResponse fetchRequest];
		NSPredicate* predicate = [NSPredicate predicateWithFormat:@"url = %@", predicateString, nil];
		[request setPredicate:predicate];
		NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"url" ascending:YES];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		return [NSArray arrayWithObject:request];
	}
	
	if ([restResource isEqual:@"item"]) {
		NSFetchRequest* request = [RKOItem fetchRequest];
		NSPredicate* predicate = [NSPredicate predicateWithFormat:@"url = %@", predicateString, nil];
		[request setPredicate:predicate];
		NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"url" ascending:YES];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		return [NSArray arrayWithObject:request];
	}
	
	if ([restResource isEqual:@"tag_item"]) {
		NSFetchRequest* request = [RKOTagItem fetchRequest];
		NSPredicate* predicate = [NSPredicate predicateWithFormat:@"url = %@", predicateString, nil];
		[request setPredicate:predicate];
		NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"url" ascending:YES];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		return [NSArray arrayWithObject:request];
	}
	
	if ([restResource isEqual:@"tag"]) {
		NSFetchRequest* request = [RKOTag fetchRequest];
		NSPredicate* predicate = [NSPredicate predicateWithFormat:@"url = %@", predicateString, nil];
		[request setPredicate:predicate];
		NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"url" ascending:YES];
		[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		return [NSArray arrayWithObject:request];
	}
	
	//return nil;
}

@end
