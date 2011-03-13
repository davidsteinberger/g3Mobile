//
//  RKTEntity.h
//  RKTwitter
//
//  Created by David Steinberger on 2/20/11.
//  Copyright 2011 -. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@interface RKOEntity : RKObject {
	NSString* _id;
	NSString* _parent;
	NSString* _title;
	NSString* _description;
	NSString* _type;
	NSString* _thumb_url_public;
	NSString* _thumb_url;
	NSString* _resize_url_public;
	NSString* _resize_url;
	NSString* _thumb_width;
	NSString* _thumb_height;
	NSString* _created;
}

@property (nonatomic, retain) NSString* id;
@property (nonatomic, retain) NSString* parent;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* thumb_url_public;
@property (nonatomic, retain) NSString* thumb_url;
@property (nonatomic, retain) NSString* resize_url_public;
@property (nonatomic, retain) NSString* resize_url;
@property (nonatomic, retain) NSString* thumb_width;
@property (nonatomic, retain) NSString* thumb_height;
@property (nonatomic, retain) NSString* created;

@end
