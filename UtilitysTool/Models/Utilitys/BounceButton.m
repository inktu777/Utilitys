#import "BounceButton.h"

@implementation BounceButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addTarget:self action:@selector(bounceEvent) forControlEvents:UIControlEventTouchDown];

}

- (void)bounceEvent
{
    UIView* targetView = (self.bounceView != nil) ? self.bounceView : self;
    [targetView setTransform:CGAffineTransformScale(self.transform, 0.85, 0.85)];
    [UIView animateWithDuration:1.0
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:10
                        options:0
                     animations:^{
                         [targetView setTransform:CGAffineTransformIdentity];
                     }
                     completion:^(BOOL finished) {

                     }];
}

@end
