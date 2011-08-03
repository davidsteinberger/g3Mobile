//
//  NSURLRequest.h
//  g3Mobile
//
//  Created by David Steinberger on 8/3/11.
//  Copyright 2011 -. All rights reserved.
//

@interface NSURLRequest (SSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host;

@end