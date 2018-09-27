#import <Foundation/Foundation.h>

@interface Utilitys : NSObject

+ (UIViewController *) currentTopViewController;

+ (void) alertTitle:(NSString *)title
            message:(NSString *)msg
               done:(NSString *)done;

+ (void) alertTitle:(NSString *)title
            message:(NSString *)msg;

+ (void) alertMessage:(NSString *)msg;

+ (void) errorAlertDelegate:(UIViewController *)delegate
                    message:(NSString *)msg;

+ (void) errorAlertDelegate:(UIViewController *)delegate
                      error:(NSError *)error;

+ (BOOL) validateEmail: (NSString *) string;
+ (BOOL) validateEnglish: (NSString *) string;
+ (BOOL) validateOnlyEnglish: (NSString *) string;
+ (BOOL) validateNumber: (NSString *) string;
+ (BOOL) validateString: (NSString *) string existChars:(NSString*)regex;
+ (BOOL) validateAccount: (NSString *) string;
+ (BOOL) validPhone: (NSString *) string;
+ (BOOL) isValidPassword:(NSString *)string;

+ (NSString *) stringFromTimeInterval:(NSTimeInterval)interval;
+ (NSDate *) dateFromDateSring:(NSString*)dateString;
+ (NSString*) apiStringForDate:(NSDate*)date ;
+ (NSString*) stringForDate:(NSDate*)date;
+ (NSString*) localeDateFormatString:(NSString*)source_date;
+ (NSString*) localeDayString:(NSString*)source_date;

+ (UIImage *) imageWithColor:(UIColor *)color;
+ (void) radiusView:(UIView*)view cornerRadius:(CGFloat)cornerRadius;
+ (void) radiusView:(UIView*)view;
+ (void) radiusViewLine:(UIView*)view;
+ (void) radiusButton:(UIButton*)button;
+ (void) radiusButton:(UIButton*)button cornerRadius:(CGFloat)cornerRadius;
+ (void) tabButtonStyle:(UIButton*)button;
+ (void) bgColorImgButton:(UIButton*)button;
+ (void) useShadow:(UIView*)targetView;
+ (void) useShadow:(UIView *)targetView cornerRadius:(float)radius;

+ (BOOL) checkLengthText:(NSString*)text
               maxLength:(int)maxLength
               minLength:(int)minLength
               inputName:(NSString*)name;

+ (UIColor *) colorFromHexString:(NSString *)hexString;

+ (void) addBottomLine:(UIView*)target andColor:(UIColor*)lineColor;

+ (void) textField:(UITextField*)texeField
            pColor:(UIColor*)color;

+ (CGSize)tableContentSize:(UITableView*)tbView;

+ (BOOL)isString:(id)object;
+ (BOOL)isDict:(id)object;
+ (BOOL)isArray:(id)object;

+ (NSString*)toString:(id)object;
+ (NSDictionary*) toDict:(id)target;
+ (NSArray*) toArray:(id)target;
+ (id) returnNotNilObj:(id)obj;

//UI
+ (void)updateContainStyle:(UIView*)containView;
+ (void)changeView:(UIView*)containView fromScrollView:(UIScrollView*)scrollView;
+ (void)changeView:(UIView*)containView fromView:(UIView*)targetView;
+ (void)updateStackViewStyle:(UIStackView*)stackView;

+ (BOOL)limitTextField:(UITextField *)textField
                 range:(NSRange)range
                string:(NSString *)string
             maxLength:(NSUInteger)maxLength;

+ (BOOL) checkLengthText:(NSString*)text
               maxLength:(int)maxLength
               minLength:(int)minLength
               inputName:(NSString*)name
          viewController:(UIViewController*)vc;

+ (void)drawDashLine:(UIView *)lineView
          lineLength:(int)lineLength
         lineSpacing:(int)lineSpacing
           lineColor:(UIColor *)lineColor;

+ (BOOL)goURL:(NSString*)urlString;
+ (void)fadeImageView:(UIImageView*)imageView
     placeholderImage:(UIImage*)placeholderImage
                  url:(NSString*)urlString;
@end
