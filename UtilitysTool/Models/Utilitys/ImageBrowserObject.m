#import "ImageBrowserObject.h"

@implementation ImageBrowserObject

- (id)initWithTitle:(NSString *)title URL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _title = title;
        _url = url;
    }
    return self;
}

- (void)scrollView:(UIScrollView *)scrollView addImageViewIfNeededForIndex:(NSInteger)index
{
    if (self.imageView)
        return;

    CGRect frame = CGRectMake(index * kDeiveWidth,
                              0.0,
                              kDeiveWidth,
                              scrollView.frame.size.height);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    [scrollView addSubview:imageView];

    __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.tintColor = [UIColor grayColor];
    activityIndicator.center = imageView.center;
    activityIndicator.hidesWhenStopped = YES;

    [imageView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    [imageView sd_setImageWithURL:self.url
                 placeholderImage:nil
                          options:SDWebImageAvoidAutoSetImage
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         [activityIndicator stopAnimating];
         [activityIndicator removeFromSuperview];
         if ([imageURL isEqual:self.url]) {
             if (cacheType == SDImageCacheTypeMemory) {
                 imageView.image = image;
             } else {
                 [UIView transitionWithView:imageView
                                   duration:.3
                                    options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                        imageView.image = image;
                                    }
                                 completion:nil];
             }
         }
     }];
    self.imageView = imageView;
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)scrollView:(UIScrollView *)scrollView removeImageViewIfNeededForIndex:(NSInteger)index
{
    if (!self.imageView)
        return;

    [self.imageView removeFromSuperview];
    self.imageView = nil;
}
@end
