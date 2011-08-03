//
//  NSURLRequest.m
//  g3Mobile
//
//  Created by David Steinberger on 8/3/11.
//  Copyright 2011 -. All rights reserved.
//

#import "NSURLRequest+ssl.h"

@implementation NSURLRequest (SSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
	return YES;
}


@end