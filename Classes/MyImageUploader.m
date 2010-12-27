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

static int counter = 0;

@implementation MyImageUploader

@synthesize albumID = _albumID;
@synthesize delegate = _delegate;

- (id)initWithAlbumID:(NSString* ) albumID delegate:(MyThumbsViewController* )delegate {

	[self createProgressionAlertWithMessage:@"Image upload" withActivity:NO];
	
	self.delegate = delegate;
	self.albumID = [[NSString alloc] initWithString:albumID];
	return self;
}

-(void) dealloc {
	TT_RELEASE_SAFELY(_albumID);
	[super dealloc];
}


- (void)uploadImage {
	[self uploadImage:nil];
}

- (void)uploadImage:(UIImage* ) image {
	
	if (image == nil) {
		image = TTIMAGE(@"bundle://empty.png");
	}

	NSData *imageData = UIImageJPEGRepresentation(image, GlobalSettings.imageQuality ? GlobalSettings.imageQuality : 0.5);
	
	[self uploadImageData:imageData];
}

- (void)uploadImageData:(NSData* ) data {
	
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
	//NSData* returnData = [NSURLConnection send:request returningResponse:nil error:nil];
	[NSURLConnection connectionWithRequest:request delegate:self];

	//NSString *returnString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
	
	//[NSURLConnection connectionWithRequest:request delegate:self];
	//NSLog(@"url to be removed: %@", urlString);

/*
	[[TTURLCache sharedCache] removeURL:@"http://192.168.2.102/~David/gallery3/index.php/rest/item/6870" fromDisk:YES];
    [[TTURLCache sharedCache] removeURL:@"http://192.168.2.102/~David/gallery3/index.php/rest/item/5166" fromDisk:YES];
    [[TTURLCache sharedCache] removeURL:@"http://192.168.2.102/~David/gallery3/index.php/rest/item/5188" fromDisk:YES];
	
	[[TTURLCache sharedCache] removeURL:@"http://192.168.2.102/~David/gallery3/index.php/rest/item/5159" fromDisk:YES];
	*/
	
	//[[TTURLCache sharedCache] removeAll:YES];
	//[[TTURLCache sharedCache] removeURL:@"http://192.168.2.102/~David/gallery3/index.php/rest/items?urls=%5B%22http://192.168.2.102/~David/gallery3/index.php/rest/item/7468%22,%22http://192.168.2.102/~David/gallery3/index.php/rest/item/6870%22,%22http://192.168.2.102/~David/gallery3/index.php/rest/item/5166%22,%22http://192.168.2.102/~David/gallery3/index.php/rest/item/5188%22%5D" fromDisk:YES];
	
	[[TTURLCache sharedCache] removeURL:urlString fromDisk:YES];
	/*[self.delegate loadAlbum:[NSString stringWithString:self.albumID]];
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator reload];*/
	
	//return returnString;
	//NSLog(returnString);
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
 {
	/*NSLog(@"totalBytesWritten: %i", totalBytesWritten);
	NSLog(@"totalBytesExpectedToWrite: %i", totalBytesExpectedToWrite);
	 NSLog(@"set: %f", (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
	NSLog(@"\n\n");*/
	 
	_progressView.progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
	//NSLog(@"albumID: %@", self.albumID);
	[self.delegate loadAlbum:[NSString stringWithString:self.albumID]];
	
	TTNavigator* navigator = [TTNavigator navigator];
	[navigator reload];
	
	TT_RELEASE_SAFELY(self->_progressAlert);
	TT_RELEASE_SAFELY(self->_activityView);
	TT_RELEASE_SAFELY(self->_progressView);
}

- (void) createProgressionAlertWithMessage:(NSString *)message withActivity:(BOOL)activity
{
	_progressAlert = [[UIAlertView alloc] initWithTitle: message
												message: @"Please wait..."
											   delegate: self
									  cancelButtonTitle: nil
									  otherButtonTitles: nil];
	
	// Create the progress bar and add it to the alert
	if (activity) {
		_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		_activityView.frame = CGRectMake(139.0f-18.0f, 80.0f, 37.0f, 37.0f);
		[_progressAlert addSubview:_activityView];
		[_activityView startAnimating];
	} else {
		_progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 225.0f, 90.0f)];
		[_progressAlert addSubview:_progressView];
		[_progressView setProgressViewStyle: UIProgressViewStyleBar];
	}
	[_progressAlert show];
}

@end
