#import <Three20/Three20.h>

@class Reachability;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	NSString* _user;
	NSString* _password;
	Reachability* hostReach;
@public
	NSString* _challenge;
	NSString* _baseURL;
}

@property(nonatomic, retain) NSString* user;
@property(nonatomic, retain) NSString* password;
@property(nonatomic, retain) NSString* challenge;
@property(nonatomic, retain) NSString* baseURL;

- (void) finishedLogin;
- (void) updateInterfaceWithReachability: (Reachability*) curReach;
- (void) initRestKit;

@end

