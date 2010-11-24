
@interface MyComment : NSObject {
  NSDate*   _created;
  NSNumber* _postId;
  NSString* _text;
  NSString* _name;
}

@property (nonatomic, retain) NSDate*   created;
@property (nonatomic, retain) NSNumber* postId;
@property (nonatomic, copy)   NSString* text;
@property (nonatomic, copy)   NSString* name;

@end
