#import <Foundation/Foundation.h>
#define API [APIMgr shared]

@interface APIMgr : NSObject
@property (strong, nonatomic) NSURLSessionDataTask* sessionDataTask;
@property (assign, nonatomic) BOOL isShowMtokenError;
+ (APIMgr*)shared;
- (void) cancelRequest;
- (NSString*) getURL:(NSString*)apiPath;

@end
