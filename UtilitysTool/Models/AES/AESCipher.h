#import <Foundation/Foundation.h>
#define AES(x) [AESCipher cipherText:x]
#define dAES(x) [AESCipher decryptedText:x]

NSString * aesEncryptString(NSString *content, NSString *key);
NSString * aesDecryptString(NSString *content, NSString *key);

NSData * aesEncryptData(NSData *data, NSData *key);
NSData * aesDecryptData(NSData *data, NSData *key);

@interface AESCipher : NSObject
+ (NSString*) cipherText:(NSString*)text;
+ (NSString*) decryptedText:(NSString*)text;
@end
