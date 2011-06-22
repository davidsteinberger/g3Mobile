//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20/Three20.h"
#import "MyPostController.h"
#import "MyUploadViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MyPostController

@synthesize titleView = _titleView;
@synthesize query = _query;
@synthesize uploadDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.delegate = self; 
		self.uploadDelegate = [self.query objectForKey:@"delegate"];		
    }
    return self;
}

- (void) dealloc {
	self.query = nil;
	self.titleView = nil;
	self.navigationItem.titleView = nil;
	self.textView.text = nil;
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  [super viewDidLoad];
	
  self.delegate = self; 
  self.uploadDelegate = [self.query objectForKey:@"delegate"];
	
  if (self.titleView) {
    self.navigationItem.titleView = [self.query objectForKey:@"titleView"];
  }

	NSString *text = [self.query objectForKey:@"text"];
	if (text && (NSNull*)text != [NSNull null]) {
		self.textView.text = nil;
		self.textView.text = text;
	}
}

- (void)viewDidUnload {
	self.query = nil;
	self.titleView = nil;
	self.navigationItem.titleView = nil;
	self.textView.text = nil;
	[super viewDidUnload];
}


- (IBAction)cancel:(id)sender {
		
}


- (void)postController:(TTPostController*)postController didPostText:(NSString *)text withResult:(id)result {
	if (self.uploadDelegate)
		[self.uploadDelegate postController:postController didPostText:text withResult:result];
}


- (void)postControllerDidCancel:(TTPostController*)postController {

}



@end
