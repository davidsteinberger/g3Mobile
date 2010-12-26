
@interface MyComment : NSObject {
  NSDate*   _created;
  NSNumber* _postId;
  NSString* _text;
  NSString* _name;
  NSString* _avatar_url;
}

@property (nonatomic, retain) NSDate*   created;
@property (nonatomic, retain) NSNumber* postId;
@property (nonatomic, copy)   NSString* text;
@property (nonatomic, copy)   NSString* name;
@property (nonatomic, retain) NSString* avatar_url;

@end
