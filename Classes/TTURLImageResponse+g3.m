//
//  MyURLImageResponse.m
//  TTCatalog
//
//  Created by David Steinberger on 11/7/10.
//  Copyright 2010 -. All rights reserved.
//

#import "TTURLImageResponse+g3.h"
#import "NSDataAdditions.h"

@implementation TTURLImageResponse(my)

- (NSError*)request:(TTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
			   data:(id)data {
	
	NSString *challenge = nil;
	
	//[self login:&challenge];
	
		// This response is designed for NSData and UIImage objects, so if we get anything else it's
		// probably a mistake.
		TTDASSERT([data isKindOfClass:[UIImage class]]
				  || [data isKindOfClass:[NSData class]]);
		TTDASSERT(nil == _image);
		
		if ([data isKindOfClass:[UIImage class]]) {
			_image = [data retain];
			
		} else if ([data isKindOfClass:[NSData class]]) {
			// TODO(jverkoey Feb 10, 2010): This logic doesn't entirely make sense. Why don't we just store
			// the data in the cache if there was a cache miss, and then just retain the image data we
			// downloaded? This needs to be tested in production.
			
			//setRequestHeader("X-Gallery-Request-Key", config.token);
			
//NSLog(@"dataObj: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
			//NSData *dataObj = [NSData dataWithBase64EncodedString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
			UIImage* image = [[TTURLCache sharedCache] imageForURL:request.urlPath fromDisk:NO];
			
			if (nil == image) {
				image = [UIImage imageWithData:data];
			}
			
			if (nil == image) {
				NSData *dataObj = [NSData dataWithBase64EncodedString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
				image = [UIImage imageWithData:dataObj];
			}
			
			if (nil != image) {
				if (!request.respondedFromCache) {
					// XXXjoe Working on option to scale down really large images to a smaller size to save memory
					//        if (image.size.width * image.size.height > (300*300)) {
					//          image = [image transformWidth:300 height:(image.size.height/image.size.width)*300.0
					//                         rotate:NO];
					//          NSData* data = UIImagePNGRepresentation(image);
					//          [[TTURLCache sharedCache] storeData:data forURL:request.URL];
					//        }
					NSLog(@"store for urlPath: %@", request.urlPath);
					[[TTURLCache sharedCache] storeImage:image forURL:request.urlPath];
				}
				
				_image = [image retain];
				
			} else {
				return [NSError errorWithDomain:kTTNetworkErrorDomain
										   code:kTTNetworkErrorCodeInvalidImage
									   userInfo:nil];
			}
		}

		return nil;
		
	}

-(void)login:(NSString **)challenge {
	NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://localhost/~David/test/rest"]];
	
	//set HTTP Method
	[request1 setHTTPMethod:@"POST"];
	
	//Implement request_body for send request here username and password set into the body.
	NSString *request_body = [NSString 
							  stringWithFormat:@"user=%@&password=%@",
							  [@"admin"        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
							  [@"gallery3"        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
							  ];
	//set request body into HTTPBody.
	[request1 setHTTPBody:[request_body dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	//set request url to the NSURLConnection
	NSData *returnedData = [NSURLConnection sendSynchronousRequest:request1
														   returningResponse:&response error:&error];	
	*challenge = [[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding];
	NSLog(@"response: %@", [[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding]);
}

@end
