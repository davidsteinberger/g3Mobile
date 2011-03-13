//
//  RKORelationShips.h
//  G3RestKitTest
//
//  Created by David Steinberger on 3/3/11.
//  Copyright 2011 -. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class RKOTags;
@class RKOEntity;
@class RKORelationships;
@class RKOComments;

@interface RKOItem : RKManagedObject {
}

@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) RKOEntity* entity;
@property (nonatomic, retain) RKOTags* tags;

@end

@interface RKOTags : RKManagedObject {
	
}

@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSSet* members;

@end

@class RKOTag;
@interface RKOTagItem : RKManagedObject {
	
}

@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* tag;

@end


@interface RKOTag : RKManagedObject {
}

@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* count;

@end








@interface RKORelationships : RKManagedObject {
	
}

@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) RKOTags* tags;

@end






@interface RKOComments : RKObject {
	NSString* _url;
}

@property (nonatomic, retain) NSString* url;

@end


