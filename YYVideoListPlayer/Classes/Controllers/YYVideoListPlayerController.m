//
//  YYVideoListPlayerController.m
//  YYVideoListPlayer
//
//  Created by yanbao on 2026/3/30.
//

#import <MJRefresh/MJRefresh.h>
#import "YYVideoListPlayerController.h"
#import "YYVideoListPlayerView.h"
#import "YYVideoListPlayerCell.h"

@interface YYVideoListPlayerController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,YYVideoListPlayerCellDelegate>
@property (weak,   nonatomic) YYVideoListPlayerView * listPlayerView;
@property (copy,   nonatomic) NSString * videoListPlayerCellIdentifier;
@property (strong, nonatomic) NSIndexPath * currentIndexPath;
@property (strong, nonatomic) YYVideoListPlayerCell * currentDisplayCell;
@end

@implementation YYVideoListPlayerController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.currentDisplayCell.viewControllerDisappear = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.currentDisplayCell.viewControllerDisappear = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupSubViews];
}

/// 用下划线标识私有方法,防止子类错误使用
- (void)_setupSubViews {
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    YYVideoListPlayerView *  listPlayerView = [[YYVideoListPlayerView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    listPlayerView.delegate = self;
    listPlayerView.dataSource = self;
    [listPlayerView registerClass:YYVideoListPlayerCell.class forCellWithReuseIdentifier:@"YYVideoListPlayerCell"];
    [self.view addSubview:listPlayerView];
    self.listPlayerView = listPlayerView;
    
}

- (void)resetVideoListPlayerViewFrame:(CGRect)frame {
        self.listPlayerView.frame = frame;
}

- (void)registerVideoListPlayerCellWithClass:(nullable Class)cellClass {
    NSString * string = NSStringFromClass(cellClass);
    self.videoListPlayerCellIdentifier = string;
    [self.listPlayerView registerClass:cellClass forCellWithReuseIdentifier:string];
}

- (void)registerVideoListPlayerCellNibWithClass:(nullable Class)cellClass {
    NSString * string = NSStringFromClass(cellClass);
    self.videoListPlayerCellIdentifier = string;
    [self.listPlayerView registerNib:[UINib nibWithNibName:string bundle:nil] forCellWithReuseIdentifier:string];
}

- (nullable YYVideoListPlayerCell *)dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath {
    if (self.videoListPlayerCellIdentifier) {
        return [self.listPlayerView dequeueReusableCellWithReuseIdentifier:self.videoListPlayerCellIdentifier forIndexPath:indexPath];
    } else {
        return nil;
    }
}

- (NSArray <YYVideoListPlayerCell *>* )visibleCells {
    return [self.listPlayerView visibleCells];
}

- (void)reloadData {
    [UIView performWithoutAnimation:^{
        [self.listPlayerView reloadData];
    }];

    // 1️⃣ 确保布局立即刷新，以便 cellForItemAtIndexPath 能拿到 cell
    [self.listPlayerView layoutIfNeeded];

    // 2️⃣ 重新获取当前 cell
    NSIndexPath *indexPath = self.currentIndexPath;
    if (indexPath) {
        self.currentDisplayCell = [self.listPlayerView cellForItemAtIndexPath:indexPath];
    }

    [self play];

}

- (void)reloadDataWithScrollToItemAtIndexPath:(nullable NSIndexPath *)indexPath completion:(nullable void (^)(void))completion {
    [UIView performWithoutAnimation:^{
        [self.listPlayerView reloadData];
        [self.listPlayerView layoutIfNeeded];
    }];
    NSIndexPath *targetIndexPath = indexPath ?: [NSIndexPath indexPathForItem:0 inSection:0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollToItemAtIndexPath:targetIndexPath animated:NO completion:completion];
    });
}

- (void)insterDataWithIndexPaths:(NSArray <NSIndexPath *>*) indexPaths completion:(nullable void (^)(void))completion {
    [CATransaction begin];
    [CATransaction setCompletionBlock:nil];
    [self.listPlayerView insertItemsAtIndexPaths:indexPaths];
    [CATransaction commit];
    if (completion) completion();
}

- (void)willDisplayCell:(YYVideoListPlayerCell*)cell indexPath:(NSIndexPath *)indexPath {
    
}


- (void)setHeaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    self.listPlayerView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:target refreshingAction:action];
}

- (void)beginHeaderRefreshing {
    [self.listPlayerView.mj_header beginRefreshing];
}

- (void)endHeaderRefreshing {
    [self.listPlayerView.mj_header endRefreshing];
}

- (void)setFooterWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    self.listPlayerView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:target refreshingAction:action];
}

- (void)beginFooterRefreshing {
    [self.listPlayerView.mj_footer beginRefreshing];
}

- (void)endFooterRefreshing {
    [self.listPlayerView.mj_footer endRefreshing];
}

- (void)endFooterRefreshingWithNoMoreData {
    [self.listPlayerView.mj_footer endRefreshingWithNoMoreData];
}

- (void)resetFooterNoMoreData {
    [self.listPlayerView.mj_footer resetNoMoreData];
}

- (void)setCurrentDisplayCell:(YYVideoListPlayerCell *)currentCell {
    if (_currentDisplayCell == currentCell) return;

    YYVideoListPlayerCell * oldCell = _currentDisplayCell;
    _currentDisplayCell = currentCell;
    
    [oldCell pause];
    oldCell.viewControllerDisappear = YES;
    oldCell.delegate = nil;
    [oldCell resetSubViews];
    
    _currentDisplayCell.viewControllerDisappear = NO;
    [_currentDisplayCell pause]; // viewControllerDisappear的调用会自动播放，所以切换播放器之后，先设置调用暂停播放。将播放控制给其他地方播放
    _currentDisplayCell.delegate = self;
}

- (void)play {
    if (!self.currentDisplayCell) {
        NSIndexPath *indexPath = self.currentIndexPath;
        if (indexPath) {
            YYVideoListPlayerCell  * cell = (YYVideoListPlayerCell *)[self.listPlayerView cellForItemAtIndexPath:indexPath];
            self.currentDisplayCell = cell;
        }
    }
    
    if (!self.currentDisplayCell.viewControllerDisappear) {
        [self.currentDisplayCell play];
    }
}

- (void)pause {
    [self.currentDisplayCell pause];
}

- (void)playerDidToEnd {
    [self scrollToNext];
}

#pragma mark event
- (BOOL)hasNext {
    NSIndexPath *current = self.currentIndexPath;
    if (!current) return NO;

    NSInteger sections = [self numberOfSectionsInCollectionView:self.listPlayerView];

    NSInteger items = [self collectionView:self.listPlayerView numberOfItemsInSection:current.section];

    // 同 section 还有下一行
    if (current.row + 1 < items) {
        return YES;
    }

    // 下一 section
    if (current.section + 1 < sections) {
        NSInteger nextSectionItems =[self collectionView:self.listPlayerView numberOfItemsInSection:current.section + 1];
        return nextSectionItems > 0;
    }

    return NO;
}

- (void)scrollToNext {
    if (![self hasNext]) return;

    NSIndexPath *current = self.currentIndexPath;
    NSIndexPath *nextIndexPath = nil;

    NSInteger items = [self collectionView:self.listPlayerView numberOfItemsInSection:current.section];

    // 同 section 下一行
    if (current.row + 1 < items) {
        nextIndexPath = [NSIndexPath indexPathForRow:current.row + 1 inSection:current.section];
    } else {
        // 下一 section 第一行
        nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:current.section + 1];
    }

    [self scrollToItemAtIndexPath:nextIndexPath animated:YES completion:nil];
}

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completion:(nullable void (^)(void))completion {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToItemAtIndexPath:indexPath animated:animated completion:completion];
        });
        return;
    }

    [self.listPlayerView layoutIfNeeded];
    if (![self yy_isValidIndexPath:indexPath]) return;

    if (animated) {
        [self.listPlayerView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:UICollectionViewScrollPositionTop
                                            animated:YES];
    } else {
        [UIView performWithoutAnimation:^{
            [self.listPlayerView scrollToItemAtIndexPath:indexPath
                                        atScrollPosition:UICollectionViewScrollPositionTop
                                                animated:NO];
            [self.listPlayerView layoutIfNeeded];
        }];
    }

    self.currentIndexPath = indexPath;
    [self didChangeIndexPathForVisible];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.currentDisplayCell = (YYVideoListPlayerCell *)[self.listPlayerView cellForItemAtIndexPath:indexPath];
        [self play];
        if (completion) completion();
    });
}

- (BOOL)yy_isValidIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) return NO;

    NSInteger sections = [self.listPlayerView numberOfSections];
    if (indexPath.section < 0 || indexPath.section >= sections) return NO;

    NSInteger items = [self.listPlayerView numberOfItemsInSection:indexPath.section];
    if (indexPath.item < 0 || indexPath.item >= items) return NO;

    return YES;
}

- (void)scrollDidEnd {
    CGFloat offsetY = self.listPlayerView.contentOffset.y;
    for (NSIndexPath *indexPath in self.listPlayerView.indexPathsForVisibleItems) {
        UICollectionViewCell *cell = [self.listPlayerView cellForItemAtIndexPath:indexPath];
        if (floor(offsetY) == floor(cell.frame.origin.y) && ![indexPath isEqual:self.currentIndexPath]) {
            [self skipToIndexPath:indexPath];
        }
    }
}

- (void)skipToIndexPath:(NSIndexPath *)indexPath {
    [self didChangeIndexPathForVisible];
    
    YYVideoListPlayerCell * cell = (YYVideoListPlayerCell *)[self.listPlayerView cellForItemAtIndexPath:indexPath];

    self.currentIndexPath = indexPath;
    self.currentDisplayCell = cell;
    [self play];
}

- (void)didChangeIndexPathForVisible {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoListPlayerController:didChangeIndexPathForVisible:)]) {
        [self.delegate videoListPlayerController:self didChangeIndexPathForVisible:self.currentIndexPath];
    }
}

#pragma mark - YYVideoListPlayerCellDelegate
- (void)videoListPlayerCellPlayDidToEnd {
    [self playerDidToEnd];
}

/// 如果有锁或者要控制他播放，需要在子类中重写
- (void)videoListPlayerCellPlayLoadState:(YYVideoListPlayerPlayLoadState)state {
    if (!self.currentDisplayCell.playerController.isViewControllerDisappear && state == YYVideoListPlayerPlayLoadStatePlayable) {
        if (self.currentDisplayCell.isPlaying) [self.currentDisplayCell play];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoListPlayerController:willBeginDraggingWithIndexPath:)]) {
        [self.delegate videoListPlayerController:self willBeginDraggingWithIndexPath:self.currentIndexPath];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollDidEnd];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollDidEnd];
    }
}
#pragma mark -UICollectionViewDelegate,UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInVideoListPlayerContoller:)]) {
        return [self.dataSource numberOfItemsInVideoListPlayerContoller:self];
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(videoListPlayerController:cellForItemAtIndexPath:)]) {
        YYVideoListPlayerCell * cell = [self.dataSource videoListPlayerController:self cellForItemAtIndexPath:indexPath];
        return cell;
    } else {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"YYVideoListPlayerCell" forIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self willDisplayCell:(YYVideoListPlayerCell*)cell indexPath:indexPath];
}


@end
