//
//  RKMSites.h
//  g3Mobile
//
//  Created by David Steinberger on 7/3/11.
//  Copyright 2011 -. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@interface RKMSite : NSManagedObject {
}

@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* title;

@end

@interface RKMSites : NSManagedObject {
}

@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSSet* rSite;

@end
