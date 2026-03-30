//
//  YYVideoListPlayerView.m
//  YYVideoListPlayer
//
//  Created by yanbao on 2026/3/30.
//

#import "YYVideoListPlayerView.h"

@implementation YYVideoListPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.scrollsToTop = NO;
    self.backgroundColor = [UIColor clearColor];
    self.pagingEnabled = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;

    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollIndicatorInsets = NO;
    }
}
@end
