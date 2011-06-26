//
//  MyAlbumUpdater.m
//  Gallery3
//
//  Created by David Steinberger on 12/20/10.
//  Copyright 2010 -. All rights reserved.
//

#import "extThree20JSON/NSObject+YAJL.h"

#import "MyAlbumUpdater.h"
#import "RestKit/RestKit.h"

#import "AppDelegate.h"
#import "SynthesizeSingleton.h"

@implementation MyAlbumUpdater

@synthesize delegate = _delegate;

SYNTHESIZE_SINGLETON_FOR_CLASS(MyAlbumUpdater);

- (id) initWithItemID:(NSString *)itemID andDelegate:(id<MyViewController>)delegate {
	_params = [[NSMutableDictionary alloc] init];
	_albumID = [NSString stringWithString: itemID];
    self.delegate = delegate;
	return self;
}

- (void) dealloc {
    self.delegate = nil;
	TT_RELEASE_SAFELY(_params);
	[super dealloc];
}

- (void) setValue:(NSString* )value param:(NSString* )param {
	//NSLog(@"value: %@, key: %@", value, param);
	[_params setObject:[NSString stringWithString:value] forKey:[NSString stringWithString:param]];
}

- (void) update {
	NSLog(@"Update Album for albumID: %@", self->_albumID);

	RKClient *client = [RKObjectManager sharedManager].client;
	[client setValue:@"put" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	RKParams *postParams = [RKParams params];
    
    NSError *error = nil;
	id <RKParser> parser = [[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
	NSString *paramsString = [parser stringFromObject:_params error:&error];
    
	[postParams setValue:paramsString forParam:@"entity"];
    
    NSString *resourcePath = [@"/rest/item/" stringByAppendingString:self->_albumID];
    
	[client post:resourcePath params:postParams delegate:self];
    
	[client setValue:@"get" forHTTPHeaderField:@"X-Gallery-Request-Method"];
}

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response {
    [self.delegate reloadViewController:YES];
}


- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error {
	NSLog(@"didFailLoadWithError");
    
    TTAlertViewController* alert = [[[TTAlertViewController alloc] initWithTitle:@"Error" message:@"Please check fields for valid vaues!"] autorelease];
    [alert addCancelButtonWithTitle:@"OK" URL:nil];
    [alert showInView:((UIViewController*)self.delegate).view animated:YES];
	//[((UIViewController*)self.delegate) showLoading:NO];
}


@end