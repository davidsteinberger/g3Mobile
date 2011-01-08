//
//  MyImageUploader.m
//  gallery3
//
//  Created by David Steinberger on 11/21/10.
//  Copyright 2010 -. All rights reserved.
//

#import "MyImageUploader.h"

#import "AppDelegate.h"

#import "MySettings.h"
#import "MyAlbum.h"
#import "extThree20JSON/NSObject+YAJL.h"

#import "MyUploadViewController.h"
#import "UIImage+cropping.h"
#import "UIImage+resizing.h"

static int counter = 0;

@implementation MyImageUploader

@synthesize albumID = _albumID;
@synthesize delegate = _delegate;

- (id)initWithAlbumID:(NSString* ) albumID delegate:(MyUploadViewController*)delegate {

	[self createProgressionAlertWithMessage:@"Image upload" withActivity:NO];
	
	self.delegate = delegate;
	self.albumID = albumID;
	return self;
}

-(void) dealloc {
	self.albumID = nil;
	[super dealloc];
}


- (void)uploadImage {
	[self uploadImage:nil withDescription:nil];
}

- (void)uploadImage:(UIImage* )image withDescription:(NSString*)description {
	
	if (image == nil) {
		image = [TTIMAGE(@"bundle://empty.png") scaleToSize:CGSizeMake(320, 480)];		
	}

	NSData *imageData = UIImageJPEGRepresentation(image, GlobalSettings.imageQuality ? GlobalSettings.imageQuality : 0.5);
	
	[self uploadImageData:imageData withDescription:description];
}

- (void)uploadImageData:(NSData* )data withDescription:(NSString*)description {
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSData *imageData = data;
	
	NSString* imageName = [@"Mobile_Upload_" stringByAppendingString: [NSString stringWithFormat:@"%d", counter++]];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:    
							[imageName stringByAppendingString:@".jpg"], @"name",
							(description == nil) ? @"": description, @"description",
							@"photo", @"type",
							nil];  
	
	//json-encode & urlencode parameters
	NSString* requestString = [params yajl_JSONString];
	//requestString = [@"" stringByAppendingString:[self urlEncodeValue:requestString]];
	NSLog(@"%@", requestString);
	//NSString* requestString = [[@"{\"name\":\"" stringByAppendingString: imageName] stringByAppendingString:@".jpg\",\"description\":\"Test\ Description\",\"type\":\"photo\"}"];
	
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
	[body appendData:[[NSString stringWithString:@"Content-Transfer-Encoding: base64\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];			
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
	[NSURLConnection connectionWithRequest:request delegate:self];
	
	[MyAlbum updateFinishedWithItemURL:[[appDelegate.baseURL stringByAppendingString:@"/rest/tree/"] stringByAppendingString:self.albumID]];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	_progressView.progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
	
	[self.delegate uploaderDidUpload:(id)self];
	
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator reload];
}

- (void) createProgressionAlertWithMessage:(NSString *)message withActivity:(BOOL)activity
{
	_progressAlert = [[[UIAlertView alloc] initWithTitle: message
												message: @"Please wait..."
											   delegate: self
									  cancelButtonTitle: nil
									  otherButtonTitles: nil] autorelease];
	
	// Create the progress bar and add it to the alert
	if (activity) {
		_activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
		_activityView.frame = CGRectMake(139.0f-18.0f, 80.0f, 37.0f, 37.0f);
		[_progressAlert addSubview:_activityView];
		[_activityView startAnimating];
	} else {
		_progressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 225.0f, 90.0f)] autorelease];
		[_progressAlert addSubview:_progressView];
		[_progressView setProgressViewStyle: UIProgressViewStyleBar];
	}
	[_progressAlert show];
}

- (NSString *)urlEncodeValue:(NSString *)str {
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}


@end
