//
//  MyImageUploader.m
//  gallery3
//
//  Created by David Steinberger on 11/21/10.
//  Copyright 2010 -. All rights reserved.
//

#import "MyImageUploader.h"

#import "AppDelegate.h"

static int counter = 0;

@implementation MyImageUploader

@synthesize albumID = _albumID;
@synthesize returnURL = _returnURL;

- (id)initWithAlbumID:(NSString* ) albumID {
	self.albumID = albumID;
	return self;
}

- (void)uploadImage {
	[self uploadImage:nil];
}

- (NSString* )uploadImage:(UIImage* ) image {
	
	if (image == nil) {
		image = TTIMAGE(@"bundle://defaultPerson.png");
	}
	
	NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
	
	return [self uploadImageData:imageData];
}

- (NSString* )uploadImageData:(NSData* ) data {
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSData *imageData = data;
	
	NSString* imageName = [@"Mobile_Upload_" stringByAppendingString: [NSString stringWithFormat:@"%d", counter++]];
	
	NSString* requestString = [[@"{\"name\":\"" stringByAppendingString: imageName] stringByAppendingString:@".jpg\",\"type\":\"photo\"}"];
	//NSString* requestString = @"{\"name\":\"Voeux2010.jpg\",\"type\":\"photo\"}";
	NSData* metaData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
	
	// setting up the URL to post to
	NSString *urlString = [[appDelegate.baseURL stringByAppendingString:@"/rest/item/"] stringByAppendingString:self.albumID];
	
	// setting up the request object
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	
	// boundary to split multipart content
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	
	// set needed headers
	[request setValue:appDelegate.challenge forHTTPHeaderField:@"X-Gallery-Request-Key"];
	[request setValue:@"post" forHTTPHeaderField:@"X-Gallery-Request-Method"];
	[request setValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	// create body
	NSMutableData *body = [NSMutableData data];
	
	// add data
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"entity\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];	
	[body appendData:[[NSString stringWithString:@"Content-Type: text/plain; charset=UTF-8\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];	
	[body appendData:[[NSString stringWithString:@"Content-Transfer-Encoding: 8bit\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];			
	[body appendData:metaData];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"file\"; filename=\"ipodfile.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];		
	[body appendData:imageData];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// setting the body of the post to the reqeust
	[request setHTTPBody:body];
	
	// now lets make the connection to the web
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *returnString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
	
	[[TTURLCache sharedCache] removeURL:urlString fromDisk:YES];
	
	return returnString;
	//NSLog(returnString);
}

@end
