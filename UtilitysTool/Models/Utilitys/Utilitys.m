#import "Utilitys.h"
#define DefaultCornerRadius 10

@implementation Utilitys

+ (UIViewController *)currentTopViewController
{
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController)
    {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

+ (void)alertTitle:(NSString *)title
           message:(NSString *)msg
              done:(NSString *)done
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:done
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [alert show];
    });
}

+ (void) alertTitle:(NSString *)title
            message:(NSString *)msg
{
    [self alertTitle:title message:msg done:@"確定"];
}

+ (void) alertMessage:(NSString *)msg
{
    [self alertTitle:AlertTitle message:msg done:@"確定"];
}

+ (void)errorAlertDelegate:(UIViewController *)delegate
                   message:(NSString *)msg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:AlertTitle
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"確定",nil) style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];

        [alert addAction:defaultAction];
        [delegate presentViewController:alert animated:YES completion:nil];
    });
}

+ (void)errorAlertDelegate:(UIViewController *)delegate
                     error:(NSError *)error
{
    if(!error)
        return;

    NSString* error_msg = [NSString stringWithFormat:@"%@",[error localizedDescription]];
    [Utilitys errorAlertDelegate:delegate
                         message:error_msg];
}

+ (BOOL) validateEmail: (NSString *) string
{
    return [string rangeOfString:@"^.+@.+\\..{2,}$" options:NSRegularExpressionSearch].location != NSNotFound;
}

+ (BOOL) validateEnglish: (NSString *) string
{
    NSString *emailRegex = @"[0-9a-zA-Z]+";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:string];
}

+ (BOOL) validateOnlyEnglish: (NSString *) string
{
    NSString *emailRegex = @"[a-zA-Z]+";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:string];
}

+ (BOOL) validateNumber: (NSString *) string
{
    NSString *regex = @"[0-9]+";
    NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [regexTest evaluateWithObject:string];
}

+ (BOOL) validateString: (NSString *)string existChars:(NSString*)regex
{
    BOOL isExist = NO;
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:regex];
    if([string rangeOfCharacterFromSet:set].location != NSNotFound){
        isExist = YES;
    }
    return isExist;
}

+ (BOOL) validateAccount: (NSString *) string
{
    BOOL isAccount = NO;
    
    if(string.length >0){
        if([self validateEmail:string]){
            isAccount = YES;
        }else{
            isAccount = [self validPhone:string];
        }
    }
    return isAccount;
}

+ (BOOL) validPhone: (NSString *) string
{
    NSString *mobileRegEx = @"[0-9]{10}";

    //0800
    NSPredicate *mobileTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegEx];
    if ([mobileTest evaluateWithObject:string] == NO) {
        return false;
    }else{
        return true;
    }
}

//驗證是否為合法密碼
+ (BOOL)isValidPassword:(NSString *)string{
    int eng_cnt = 0;
    int eng_cap_cnt = 0;
    int num_cnt = 0;
    int oth_cnt = 0;
    NSString *testString = string;
    NSUInteger alength = [testString length];
    for (int i = 0; i<alength; i++) {
        char commitChar = [testString characterAtIndex:i];
        NSString *temp = [testString substringWithRange:NSMakeRange(i,1)];
        const char *u8Temp = [temp UTF8String];
        if (3==strlen(u8Temp)){
            //字符串中含有中文
            oth_cnt+=1;
        }else if((commitChar>64)&&(commitChar<91)){
            //字符串中含有大写英文字母
            eng_cnt+=1;
            eng_cap_cnt+=1;
        }else if((commitChar>96)&&(commitChar<123)){
            //字符串中含有小写英文字母
            eng_cnt+=1;
        }else if((commitChar>47)&&(commitChar<58)){
            //字符串中含有数字
            num_cnt+=1;
        }else{
            //字符串中含有非法字符
            oth_cnt+=1;
        }
    }
    if(string.length< 8 || string.length>12){
        return false;
    }
    if (eng_cnt < 2 || num_cnt < 2) {
        return false;
    }
    if(eng_cap_cnt < 1){
        return false;
    }
    
    return true;
}

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)hours, (long)minutes];
}

+ (NSDate *)dateFromDateSring:(NSString*)dateString {
    
    NSDate* date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
    date = [dateFormatter dateFromString:dateString];
    
    if(date == nil){
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        date = [dateFormatter dateFromString:dateString];
    }
    
    if(date == nil){
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.s"];
        date = [dateFormatter dateFromString:dateString];
    }
    
    if(date == nil){
        [dateFormatter setDateFormat:@"MMM d, yyyy 'at' h:mm a"];
        date = [dateFormatter dateFromString:dateString];
    }

    if(date == nil){
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        date = [dateFormatter dateFromString:dateString];
    }
    
    return date;
}

+ (NSString*)apiStringForDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
}

+ (NSString*)stringForDate:(NSDate*)date {
    
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterMediumStyle
                                          timeStyle:NSDateFormatterShortStyle];
}

+ (NSString*)localeDateFormatString:(NSString*)source_date
{
    if([source_date isKindOfClass:[NSNull class]])
        return @"";
    
    NSString* localeFormat ;
    NSDate* date = [self dateFromDateSring:source_date];
    localeFormat = [self stringForDate:date];
    
    if([localeFormat length] == 0){
        localeFormat = source_date;
    }
    return localeFormat;
}

+ (NSString*) localeDayString:(NSString*)source_date
{
    if([source_date isKindOfClass:[NSNull class]])
        return @"";

    NSString* localeFormat ;
    NSDate* date = [self dateFromDateSring:source_date];
    localeFormat = [NSDateFormatter localizedStringFromDate:date
                                                  dateStyle:NSDateFormatterShortStyle
                                                  timeStyle:NSDateFormatterNoStyle];

    if([localeFormat length] == 0){
        localeFormat = source_date;
    }
    return localeFormat;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (void) radiusView:(UIView*)view cornerRadius:(CGFloat)cornerRadius
{
    if(cornerRadius == 0)
        cornerRadius = DefaultCornerRadius;
    view.layer.cornerRadius = cornerRadius;
    view.clipsToBounds = YES;
}

+ (void) radiusView:(UIView*)view
{
    [self radiusView:view cornerRadius:view.height/2];
}

+ (void) radiusViewLine:(UIView*)view
{
    [self radiusView:view cornerRadius:(view.width > view.height) ? view.height/2 : view.width/2];
    view.layer.borderColor = view.backgroundColor.CGColor;
    view.layer.borderWidth = 1;
    view.backgroundColor = [UIColor clearColor];
}

+ (void) radiusButton:(UIButton*)button
{
    [button setBackgroundImage:[self imageWithColor:button.backgroundColor] forState:0];
    [button setBackgroundColor:[UIColor clearColor]];
    [self radiusView:button];
}

+ (void) radiusButton:(UIButton*)button cornerRadius:(CGFloat)cornerRadius
{
    if(button.backgroundColor != [UIColor clearColor]){
        [button setBackgroundImage:[self imageWithColor:button.backgroundColor] forState:0];
    }
    [button setBackgroundColor:[UIColor clearColor]];
    [self radiusView:button cornerRadius:cornerRadius];
}

+ (void) tabButtonStyle:(UIButton*)button
{
    CGFloat spacing = 6.0;

    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
    button.imageEdgeInsets = UIEdgeInsetsMake(
                                              - (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);

    CGFloat edgeOffset = fabs(titleSize.height - imageSize.height) / 2.0;
    button.contentEdgeInsets = UIEdgeInsetsMake(edgeOffset, 0.0, edgeOffset, 0.0);
}

+ (void) bgColorImgButton:(UIButton*)button
{
    UIImage* bgImg = [self imageWithColor:button.backgroundColor];
    [button setBackgroundImage:bgImg forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
}

+ (void)useShadow:(UIView*)targetView
{
    targetView.layer.shadowColor = [UIColor blackColor].CGColor;
    targetView.layer.shadowOffset = CGSizeMake(0, 0);
    targetView.layer.shadowOpacity = 5.0;
    targetView.layer.shadowRadius = 5.0;
}

+ (void) useShadow:(UIView *)targetView cornerRadius:(float)cornerRadius
{
    if(cornerRadius == 0)
        cornerRadius = DefaultCornerRadius;

    CALayer *layer = targetView.layer;
    layer.cornerRadius = cornerRadius;
    layer.masksToBounds = NO;

    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 1.0;
    layer.shadowOpacity = .5;
    layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:layer.bounds cornerRadius:layer.cornerRadius] CGPath];

    CGColorRef bColor = targetView.backgroundColor.CGColor;
    targetView.backgroundColor = nil;
    layer.backgroundColor =  bColor ;
}

+ (BOOL) checkLengthText:(NSString*)text
               maxLength:(int)maxLength
               minLength:(int)minLength
               inputName:(NSString*)name
{
    if(minLength >= 0 && text.length == 0){
        
        [self alertTitle:@""
                 message:[NSString stringWithFormat:NSLocalizedString(@"您必須輸入%@",nil),name]
                    done:NSLocalizedString(@"確認",nil)];
        return NO;
    }else if(minLength >= 0 && minLength > text.length){
        [self alertTitle:@""
                 message:[NSString stringWithFormat:NSLocalizedString(@"您的%@不能少於 %d 個字元",nil),name,minLength]
                    done:NSLocalizedString(@"確認",nil)];
        return NO;
    }
    
    NSString* spaceString = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(minLength >= 0 && spaceString.length == 0){
        [self alertTitle:@""
                 message:[NSString stringWithFormat:NSLocalizedString(@"您必須輸入%@",nil),name]
                    done:NSLocalizedString(@"確認",nil)];
        return NO;
    }
    
    if(maxLength >= 0 && text.length > maxLength){
        [self alertTitle:@""
                 message:[NSString stringWithFormat:NSLocalizedString(@"您的%@不能超過 %d 個字元",nil),name,maxLength]
                    done:NSLocalizedString(@"確認",nil)];
        return NO;
    }
    
    return YES;
}

// Assumes input like "#00FF00" (#RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (void)addBottomLine:(UIView*)target andColor:(UIColor*)lineColor
{
    UIView* line = [[UIView alloc]initWithFrame:CGRectMake(0, target.frame.size.height - 1, target.frame.size.width, 1)];
    [line setBackgroundColor:lineColor];
    [target addSubview:line];
    [line setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
}

+ (void)textField:(UITextField*)texeField
           pColor:(UIColor*)color
{
    if ([texeField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        texeField.attributedPlaceholder = [[NSAttributedString alloc]
                                           initWithString:texeField.placeholder
                                           attributes:@{NSForegroundColorAttributeName : color}];
    }
}

+ (CGSize)tableContentSize:(UITableView*)tbView
{
    // Force the table view to calculate its height
    [tbView layoutIfNeeded];
    return tbView.contentSize;
}

//UI
+ (void)updateContainStyle:(UIView*)containView
{
    for(UIView* subView in containView.subviews){
        
        if([subView isKindOfClass:[UIStackView class]]){
            UIStackView* stackView = (UIStackView*)subView;
            if(stackView.tag == 1002){
                [self updateStackViewStyle:stackView];
            }
            continue;
        }
        
        if([subView isKindOfClass:[UIButton class]]){
            UIButton* button = (UIButton*)subView;
            if(button.tag == 1001){
                //換行按鈕
                [Utilitys tabButtonStyle:button];
            }else{
                [Utilitys radiusButton:button cornerRadius:2];
            }
            continue;
        }
        
        if(subView.tag == 1000){
            [Utilitys radiusView:subView cornerRadius:2];
        }
    }
    
    containView.backgroundColor = [UIColor clearColor];
}

+ (void)changeView:(UIView*)containView fromScrollView:(UIScrollView*)scrollView
{
    CGFloat rate = kDeiveWidth / 375.0;
    [containView setTransform:CGAffineTransformScale(scrollView.transform, rate, rate)];
    
    containView.left = 0;
    containView.top = 0;
    
    for(UIView* subView in scrollView.subviews){
        [subView removeFromSuperview];
    }
    
    CGFloat height = containView.height;
    
    float wSize = MIN(scrollView.width, kDeiveWidth);
    
    
    scrollView.contentSize = CGSizeMake(wSize, height);
    [scrollView addSubview:containView];
    [scrollView setContentOffset:CGPointZero animated:NO];
}

+ (void)changeView:(UIView*)containView fromView:(UIView*)targetView
{
    CGFloat rate = kDeiveWidth / 375.0;
    [containView setTransform:CGAffineTransformScale(targetView.transform, rate, rate)];
    
    containView.left = 0;
    containView.top = 0;
    
    for(UIView* subView in targetView.subviews){
        if([subView isKindOfClass:[UIImageView class]]){
            continue;
        }
        [subView removeFromSuperview];
    }
    
    [targetView addSubview:containView];
}

+ (void) updateStackViewStyle:(UIStackView*)stackView
{
    for(UIView* subView in stackView.subviews){
        if([subView isKindOfClass:[UILabel class]]){
            UILabel* label = (UILabel*)subView;
            if(label.text.length>0){
                [Utilitys radiusView:label];
            }else{
                [Utilitys radiusViewLine:label];
            }
            continue;
        }
    }
}

//Limit input text length
//Use in - (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
+ (BOOL)limitTextField:(UITextField *)textField
                 range:(NSRange)range
                string:(NSString *)string
             maxLength:(NSUInteger)maxLength
{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= maxLength || returnKey;
}

+ (BOOL)isString:(id)object
{
    if(object == nil ||
       [object isKindOfClass:[NSNull class]])
    {
        return NO;
    }
    if([object isKindOfClass:[NSString class]]){
        return YES;
    }
    return NO;
}

+ (BOOL)isDict:(id)object
{
    if(object == nil ||
       [object isKindOfClass:[NSNull class]])
    {
        return NO;
    }
    if([object isKindOfClass:[NSDictionary class]]){
        return YES;
    }
    return NO;
}

+ (BOOL)isArray:(id)object
{
    if(object == nil ||
       [object isKindOfClass:[NSNull class]])
    {
        return NO;
    }
    if([object isKindOfClass:[NSArray class]]){
        return YES;
    }
    return NO;
}

+ (NSString*)toString:(id)object
{
    NSString* string = @"";
    if([object isKindOfClass:[NSString class]]){
        string = [NSString stringWithFormat:@"%@",object];
    }else if([object isKindOfClass:[NSNumber class]]){
        string = [NSString stringWithFormat:@"%@",[object stringValue]];
    }
    return string;
}

+ (NSDictionary*) toDict:(id)target
{
    NSDictionary* inDict = [Utilitys isDict:target] ? target : nil;

    if(inDict == nil ||
       [inDict isKindOfClass:[NSNull class]] ||
       ![inDict isKindOfClass:[NSDictionary class]])
    {
        return [@{} copy];
    }
    
    NSArray *keys = [(NSDictionary*)inDict allKeys];
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    for(NSString *key in keys) {
        id obj = (NSDictionary*)inDict[key];
        [mDict setValue:[Utilitys returnNotNilObj:obj] forKey:key];
    }
    
    return [mDict copy];
}

+ (NSArray*) toArray:(id)target
{
    NSDictionary* inArr = [Utilitys isArray:target] ? target : nil;

    if(inArr == nil ||
       [inArr isKindOfClass:[NSNull class]] ||
       ![inArr isKindOfClass:[NSArray class]])
    {
        return [@[] copy];
    }
    
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    for(id obj in (NSArray*)inArr) {
        [mArr addObject:[Utilitys returnNotNilObj:obj]];
    }
    
    return [mArr copy];
}

+(id) returnNotNilObj:(id)obj {
    if(obj == nil || [obj isKindOfClass:[NSNull class]]) {
        return @"";
    } else if([obj isKindOfClass:[NSDictionary class]]) {
        return [Utilitys toDict:obj];
    } else if([obj isKindOfClass:[NSArray class]]) {
        return [Utilitys toArray:obj];
    }
    return [obj copy];
}

+ (BOOL) checkLengthText:(NSString*)text
               maxLength:(int)maxLength
               minLength:(int)minLength
               inputName:(NSString*)name
          viewController:(UIViewController*)vc
{
    if(minLength == 0 && text.length == 0){
        [self errorAlertDelegate:vc
                         message:[NSString stringWithFormat:NSLocalizedString(@"您必須輸入%@",nil),name]];
        return NO;
    }else if(minLength >= 0 && minLength > text.length){

        [self errorAlertDelegate:vc
                         message:[NSString stringWithFormat:NSLocalizedString(@"您的%@不能少於 %d 個字元",nil),name,minLength]];
        return NO;
    }

    NSString* spaceString = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(minLength >= 0 && spaceString.length == 0){
        [self errorAlertDelegate:vc
                         message:[NSString stringWithFormat:NSLocalizedString(@"您必須輸入%@",nil),name]];
        return NO;
    }

    if(maxLength > 0 && text.length > maxLength){
        [self errorAlertDelegate:vc
                         message:[NSString stringWithFormat:NSLocalizedString(@"您的%@不能超過 %d 個字元",nil),name,maxLength]];
        return NO;
    }

    return YES;
}

+ (void)drawDashLine:(UIView *)lineView
          lineLength:(int)lineLength
         lineSpacing:(int)lineSpacing
           lineColor:(UIColor *)lineColor
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame),CGRectGetHeight(lineView.frame) / 2)];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    [shapeLayer setStrokeColor:lineColor.CGColor];
    [shapeLayer setLineWidth:CGRectGetWidth(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL,0, CGRectGetHeight(lineView.frame));
    [shapeLayer setPath:path];
    CGPathRelease(path);
    [lineView.layer addSublayer:shapeLayer];
}

+ (BOOL)goURL:(NSString*)urlString
{
    BOOL enable = NO;
    NSURL* url = [NSURL URLWithString:urlString];

    if([[UIApplication sharedApplication] canOpenURL:url]){
        enable = YES;
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:nil];
    }

    return enable;
}

+ (void)fadeImageView:(UIImageView*)imageView
     placeholderImage:(UIImage*)placeholderImage
                  url:(NSString*)urlString
{
    imageView.alpha = 0;
    [imageView sd_setImageWithURL:[NSURL URLWithString:urlString]
                 placeholderImage:placeholderImage
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if(cacheType == SDImageCacheTypeNone){
             [UIView animateWithDuration:0.5
                                   delay:0
                                 options:UIViewAnimationOptionTransitionCrossDissolve
                              animations:^{
                                  imageView.alpha = 1;
                              }
                              completion:^(BOOL finished) {
                              }];
         }else{
             imageView.alpha = 1;
         }
     }];
}

+ (CALayer *)gradientImageBounds:(CGRect)frame
                           color:(UIColor*)color
                         toColor:(UIColor*)toColor
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    gradient.colors = @[(id)color.CGColor,(id)toColor.CGColor];
    gradient.startPoint = CGPointMake(0.0, 0.0);
    gradient.endPoint = CGPointMake(1.0, 0.0);
    return gradient;
}

+ (UIImage *)imageFromLayer:(CALayer *)layer
{
    UIGraphicsBeginImageContext([layer frame].size);

    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return outputImage;
}

+ (UIImage *)imageFromView:(UIView *) view
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(view.frame.size);
    }
    [view.layer renderInContext: UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (void)checkNeedsUpdateVersion:(NSString*)version
                     completion:(void(^)(BOOL appStoreHasNewerVersion))completion
{
    NSArray* appStoreVersionArray = [version componentsSeparatedByString:@"."];
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    BOOL appStoreHasNewerVersion = NO;

    if (version.length>=5 && appStoreVersionArray.count == 3){
        NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];

        NSArray* currentVersionArray = [currentVersion componentsSeparatedByString:@"."];
        NSInteger maxDeep = ([appStoreVersionArray count] > [currentVersionArray count])?
        [appStoreVersionArray count]: [currentVersionArray count];
        NSInteger minDeep = ([appStoreVersionArray count] > [currentVersionArray count])?
        [currentVersionArray count]: [appStoreVersionArray count];
        int i = 0;
        for( ; i< minDeep ; i++) {
            if([appStoreVersionArray[i] integerValue]>[currentVersionArray[i] integerValue]) {
                appStoreHasNewerVersion = YES;
                break;
            } else if([appStoreVersionArray[i] integerValue]<[currentVersionArray[i] integerValue]) {
                appStoreHasNewerVersion = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(appStoreHasNewerVersion);
                });
                return;
            }
        }

        if(minDeep == i && maxDeep> minDeep) {
            appStoreHasNewerVersion = YES;
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        completion(appStoreHasNewerVersion);
    });
}

+ (void)checkAppVersion:(NSString*)version
{
    [self checkNeedsUpdateVersion:version
                       completion:^(BOOL appStoreHasNewerVersion)
     {
         if(appStoreHasNewerVersion){
             dispatch_async(dispatch_get_main_queue(), ^{

                 UIAlertController* alert = [UIAlertController
                                             alertControllerWithTitle:AlertTitle
                                             message:[NSString stringWithFormat:@"已經有更新的版本，請立即下載更新。"]
                                             preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action)
                                                 {
                                                     NSString* appID = @"";//id
                                                     NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appID]];
                                                     [[UIApplication sharedApplication]
                                                      openURL:url
                                                      options:@{}
                                                      completionHandler:nil];
                                                 }];

                 [alert addAction:defaultAction];
                 [alert show];
             });
         }
     }];
}

+ (BOOL)callPhone:(NSString*)number
{
    if(number.length == 0)
        return NO;

    BOOL isEnable = NO;

    NSString *targetStrig = @"";
    targetStrig = [@"telprompt://" stringByAppendingString:number];
    NSURL* url = [NSURL URLWithString:targetStrig];

    if([[UIApplication sharedApplication] canOpenURL:url]){
        isEnable = YES;
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:nil];
    }else{
        isEnable = NO;
    }
    return isEnable;
}

@end
