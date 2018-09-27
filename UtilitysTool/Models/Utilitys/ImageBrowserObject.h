#import <Foundation/Foundation.h>

@interface ImageBrowserObject : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) UIImageView *imageView;

- (id)initWithTitle:(NSString *)title URL:(NSURL *)url;
- (void)scrollView:(UIScrollView *)scrollView addImageViewIfNeededForIndex:(NSInteger)index;
- (void)scrollView:(UIScrollView *)scrollView removeImageViewIfNeededForIndex:(NSInteger)index;
@end
