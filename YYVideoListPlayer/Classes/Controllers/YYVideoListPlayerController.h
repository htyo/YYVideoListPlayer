//
//  YYVideoListPlayerController.h
//  YYVideoListPlayer
//
//  Created by yanbao on 2026/3/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YYVideoListPlayerController,YYVideoListPlayerView,YYVideoListPlayerCell,YYVideoListPlayerModel;

@protocol YYVideoListPlayerControllerDelegate <NSObject>

@optional
- (void)videoListPlayerController:(YYVideoListPlayerController *)contoller willBeginDraggingWithIndexPath:(NSIndexPath *)indexPath;
- (void)videoListPlayerController:(YYVideoListPlayerController *)contoller didChangeIndexPathForVisible:(NSIndexPath *)indexPath;
@end

@protocol YYVideoListPlayerControllerDataSource <NSObject>
- (NSInteger)numberOfItemsInVideoListPlayerContoller:(YYVideoListPlayerController *)contoller;
- (YYVideoListPlayerCell *)videoListPlayerController:(YYVideoListPlayerController *)contoller cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface YYVideoListPlayerController : UIViewController
@property (strong, nonatomic, readonly) NSIndexPath * currentIndexPath;
@property (strong, nonatomic, readonly) YYVideoListPlayerCell * currentDisplayCell;

@property (weak,   nonatomic) id <YYVideoListPlayerControllerDelegate> delegate;
@property (weak,   nonatomic) id <YYVideoListPlayerControllerDataSource> dataSource;

- (void)resetVideoListPlayerViewFrame:(CGRect)frame;

- (void)registerVideoListPlayerCellWithClass:(nullable Class)cellClass;
- (void)registerVideoListPlayerCellNibWithClass:(nullable Class)cellClass;
- (nullable YYVideoListPlayerCell *)dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath;

- (void)reloadData;
- (void)reloadDataWithScrollToItemAtIndexPath:(nullable NSIndexPath *)indexPath completion:(nullable void (^)(void))completion;
- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completion:(nullable void (^)(void))completion;
- (void)insterDataWithIndexPaths:(NSArray <NSIndexPath *>*) indexPaths completion:(nullable void (^)(void))completion;
- (void)willDisplayCell:(YYVideoListPlayerCell*)cell indexPath:(NSIndexPath *)indexPath;
- (NSArray <YYVideoListPlayerCell *>*)visibleCells;

- (void)setHeaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action;
- (void)beginHeaderRefreshing;
- (void)endHeaderRefreshing;

- (void)setFooterWithRefreshingTarget:(id)target refreshingAction:(SEL)action;
- (void)beginFooterRefreshing;
- (void)endFooterRefreshing;
- (void)endFooterRefreshingWithNoMoreData;
- (void)resetFooterNoMoreData;

// overrideo
- (void)play;
- (void)pause;
- (void)playerDidToEnd;

@end
NS_ASSUME_NONNULL_END

