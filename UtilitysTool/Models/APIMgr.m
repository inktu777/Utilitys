#import "APIMgr.h"

//server
#define serverip_test @"testapi.com.tw"
#define serverip_real @"api.com.tw"

#define webviewip_test @"test.com.tw"
#define webviewip_real @"real.com.tw"

//RD測試server相關
#define SERVER_TEST_MODE 0 //切換正式機 1->測試環境
#define LOCAL_TEST 0 //本端測試

#define TIMEOUT_SEC 30

//Home API Json 回傳格式
#define ErrCode @"resultcode"
#define ErrMsg @"messages"
#define Num(i) [NSNumber numberWithInteger:i]

#define IDFV [[[UIDevice currentDevice]identifierForVendor] UUIDString]

@implementation APIMgr

+ (APIMgr*) shared
{
    //Singleton instance
    static APIMgr *thisManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        thisManager = [[self alloc] init];
    });
    return thisManager;
}

- (NSURLSession*)defConfig
{
    return [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (void)cancelRequest
{
    if (self.sessionDataTask.state == NSURLSessionTaskStateRunning) {
        [self.sessionDataTask cancel];
        log(@"cancel Request");
    }
}

- (NSString*) getURL:(NSString*)apiPath
{
    NSString *urlPath;
    if(SERVER_TEST_MODE){
        urlPath = [[NSString alloc] initWithFormat:@"http://%@/%@",serverip_test,apiPath];
    }else{
        urlPath = [[NSString alloc] initWithFormat:@"https://%@/%@",serverip_real,apiPath];
    }
    return urlPath;
}

-(void)logJson:(NSData*)jsonData
{
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    log(@"body data:\n%@",jsonString);
}

- (void)logError:(NSError*)error target:(NSString*)target
{
    if(error){
        NSLog(@"\n[Error]%@\ncode : %d\nmsg : %@",target, (int)error.code , [error localizedDescription]);
    }
}

- (void) server_request_json:(NSDictionary*)dataJson
                   urlString:(NSString*)urlString
                  completion:(void(^)(NSDictionary* result, NSError *error))completion
{
    log(@"\nAPI URL: %@\n",urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:TIMEOUT_SEC];
    [request setHTTPMethod:@"POST"];

    if(dataJson){
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:[self dictRemoveNull:dataJson]
                                                             options:0
                                                               error:nil]];
    }
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self logJson:request.HTTPBody];

    NSURLSession* session = [self defConfig];
    self.sessionDataTask = [session dataTaskWithRequest:request
                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                   {
                       NSDictionary* result;
                       if(data){
                           result = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
                       }

                       NSError * __error = nil;
                       int returnCode = [result[ErrCode] intValue];
                       if (result && returnCode == 0) {
                           //成功
                           NSString* text = [NSString stringWithFormat:@"%@",result];
                           log(@"result : \n%@",[text stringByRemovingPercentEncoding]);
                       }else{
                           if(result && returnCode){
                               NSDictionary *userInfo = @{NSLocalizedDescriptionKey:result[ErrMsg]};
                               __error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                             code:returnCode
                                                         userInfo:userInfo];
                               NSString* text = [NSString stringWithFormat:@"%@",result];
                               log(@"result Error: \n%@",[text stringByRemovingPercentEncoding]);
                           }else{
                               __error = error;
                           }
                       }

                       dispatch_async(dispatch_get_main_queue(), ^{
                           completion(result,__error);
                       });
                   }];
    [self.sessionDataTask resume];
    [session finishTasksAndInvalidate];
}

- (void) server_json:(NSDictionary*)json
                 api:(NSString*)api
          completion:(void(^)(NSDictionary* result, NSError *error))completion
{

    NSString* apiPath = [self getURL:api];

    [self server_request_json:json
                    urlString:apiPath
                   completion:^(NSDictionary* result,
                                NSError* error)
     {
         if([self checkTokenError:error]){
             //reflash
             [self getToken_completion:^(BOOL success, NSError *error)
              {
                  if(success){
                      [self server_request_json:json
                                      urlString:apiPath
                                     completion:^(NSDictionary* result,
                                                  NSError* error)
                       {
                           completion(result,error);
                       }];
                  }else{
                      completion(nil,error);
                  }
              }];
         }else{
             completion(result,error);
         }
     }];
}

//移除被填入null的Dict欄位
- (NSDictionary *)dictRemoveNull:(NSDictionary *)target_dict
{
    NSMutableDictionary *dict = [target_dict mutableCopy];
    NSArray *keysForNullValues = [dict allKeysForObject:[NSNull null]];
    [dict removeObjectsForKeys:keysForNullValues];
    return dict;
}

- (void)rootReload
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateViews"
                                                        object:nil];
}

//API
-(BOOL)checkTokenError:(NSError*)error
{
    BOOL isTokenError = NO;
    switch (error.code) {
        case 10002:
            isTokenError = YES;
            break;
        case 10003:
            isTokenError = YES;
            break;
        default:
            break;
    }

    return isTokenError;
}

- (void)runTokenError
{
    self.isShowMtokenError = YES;

    dispatch_async(dispatch_get_main_queue(), ^{

        UIAlertController* alert = [UIAlertController
                                    alertControllerWithTitle:AlertTitle
                                    message:[NSString stringWithFormat:@"登入憑證失效，請您再重新登入。"]
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
                                        {
                                            //singout
                                            self.isShowMtokenError = NO;
                                        }];

        [alert addAction:defaultAction];
        [alert show];
    });
}

/*
更新Token
 */
- (void) getToken_completion:(void(^)(BOOL success, NSError *error))completion
{
    NSDictionary* dataJson = @{
                               @"id":@"asf2g90fAS7S6dh",
                               };

    [self server_request_json:dataJson
                    urlString:[self getURL:@"Application"]
                   completion:^(NSDictionary* result,
                                NSError* error)
     {
         BOOL success = NO;
         NSString* apToken = @"";
         if(!error){
             apToken = result[@"data"];
             if(apToken.length){
                 success = YES;
                 //save token
             }
         }

         dispatch_async(dispatch_get_main_queue(), ^{
             completion(success,error);
         });
     }];
}

/*
檢查token
 */
- (void) getAppVersion_completion:(void(^)(NSString* version, NSError *error))completion
{
    NSDictionary* dataJson = @{
                               @"os":@"iOS"
                               };
    NSString* urlString = [self getURL:@"path/CheckToken"];

    [self server_request_json:dataJson
                    urlString:urlString
                   completion:^(NSDictionary* result,
                                NSError* error)
     {
         if([self checkApTokenError:error]){
             //reflash
             [self getApToken_completion:^(BOOL success, NSError *error)
             {
                 if(success){
                     [self server_request_json:dataJson
                                     urlString:urlString
                                    completion:^(NSDictionary* result,
                                                 NSError* error)
                      {
                          NSString* version = @"";
                          if(!error){
                              version = result[@"data"];
                          }
                          dispatch_async(dispatch_get_main_queue(), ^{
                              completion(version,error);
                          });
                      }];
                 }else{
                     dispatch_async(dispatch_get_main_queue(), ^{
                         completion(@"",error);
                     });
                 }
             }];
         }else{
             NSString* version = @"";
             if(!error){
                 version = result[@"data"];
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 completion(version,error);
             });
         }
     }];
}

/*
會員登入/註冊
 */
- (void)setLoginAccount:(NSString*)account
             completion:(void(^)(BOOL successful,
                                 NSString* message,
                                 NSError *error))completion
{
    [self server_json:@{
                        @"account":account,
                        }
                  api:@"Member/Login"
           completion:^(NSDictionary* result,
                        NSError* error)
     {
         NSString* message = @"";
         BOOL successful = NO;
         if (result && error.code == 0) {
             //成功
             successful = YES;
             message = result[ErrMsg];
         }

         [self logError:error target:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];

         dispatch_async(dispatch_get_main_queue(), ^{
             completion(successful,message,error);
         });
     }];
}

/*
簡訊驗證
 */
- (void)setLoginVerifyCode:(NSString*)code
                   account:(NSString*)account
                completion:(void(^)(NSString* account,
                                    NSString* name,
                                    NSString* token,
                                    NSError *error))completion
{
    [self server_json:@{
                        @"validcode" : code,
                        @"account" : account,
                        }
                  api:@"Member/Activate"
           completion:^(NSDictionary* result,
                        NSError* error)
     {

         NSString* account = @"";
         NSString* name = @"";
         NSString* mbtoken = @"";
         NSDictionary* data = [Utilitys toDict:result[@"data"]];
         if (data && error.code == 0) {
             //成功
             account = data[@"account"];
             name = data[@"name"];
             mbtoken = data[@"token"];
         }

         [self logError:error target:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];

         dispatch_async(dispatch_get_main_queue(), ^{
             completion(account,name,mbtoken,error);
         });
     }];
}

/*
首頁
 */
- (void) getRootPage:(int)page
          completion:(void(^)(NSArray* dataArray,
                              NSError *error))completion
{

    [self server_json:@{
                        @"page":IntText(page)
                        }
                  api:@"Home/Home/Index"
           completion:^(NSDictionary* result,
                        NSError* error)
     {
         NSArray* dataArray = nil;

         NSDictionary* data = [Utilitys toDict:result[@"data"]];
         if (data && error.code == 0) {
             //成功
             dataArray = [Utilitys toArray:data[@"news"]];
         }

         [self logError:error target:[NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__]];

         dispatch_async(dispatch_get_main_queue(), ^{
             completion(dataArray,error);
         });
     }];
}
//webView

- (NSString*) getWebURL:(NSString*)apiPath
{
    NSString *urlPath;
    if(SERVER_TEST_MODE){
        urlPath = [[NSString alloc] initWithFormat:@"https://%@/%@",webviewip_test,apiPath];
    }else{
        urlPath = [[NSString alloc] initWithFormat:@"https://%@/%@",webviewip_real,apiPath];
    }
    return urlPath;
}

- (NSMutableURLRequest*) webview_json:(NSDictionary*)json
                                  api:(NSString*)api
{

    NSString* urlString = [self getWebURL:api];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:TIMEOUT_SEC];
    [request setHTTPMethod:@"POST"];
    if(json){
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:[self dictRemoveNull:json]
                                                             options:0
                                                               error:nil]];
    }
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self logJson:request.HTTPBody];

    return request;
}

/*
 單繳
 */
- (NSMutableURLRequest*) getPayment:(NSArray*)list
{
    NSDictionary* dataJson = @{
                               @"billnos":list
                               };

    return [self webview_json:dataJson
                   api:@"Member/Payment"];
}

/*
 網站條款
 */
- (NSMutableURLRequest*) getServiceTerms
{
    return [self webview_json:nil
                          api:@"Home/ServiceTerms"];
}

/*
 聯絡我們
 */
- (NSString*) urlContactUs
{
    NSString* urlPath = [self getWebURL:@"Member/ContactUs"];
    return urlPath;
}

@end
