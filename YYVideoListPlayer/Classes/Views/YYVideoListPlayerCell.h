//
//  YYVideoListPlayerCell.h
//  YYVideoListPlayer
//
//  Created by yanbao on 2026/3/30.
//

#import <UIKit/UIKit.h>
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "YYVideoListPlayerModel.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YYVideoListPlayerPlayBackState) {
    YYVideoListPlayerPlayBackStateUnknown,
    YYVideoListPlayerPlayBackStatePlaying,
    YYVideoListPlayerPlayBackStatePaused,
    YYVideoListPlayerPlayBackStateFailed,
    YYVideoListPlayerPlayBackStateStopped,
    YYVideoListPlayerPlayBackStateEnd
};

typedef NS_OPTIONS(NSUInteger, YYVideoListPlayerPlayLoadState) {
    YYVideoListPlayerPlayLoadStateUnknown        = 0,
    YYVideoListPlayerPlayLoadStatePrepare        = 1 << 0,
    YYVideoListPlayerPlayLoadStatePlayable       = 1 << 1,
    YYVideoListPlayerPlayLoadStatePlaythroughOK  = 1 << 2, // Playback will be automatically started.
    YYVideoListPlayerPlayLoadStateStalled        = 1 << 3, // Playback will be automatically paused in this state, if started.
};

typedef NS_ENUM(NSInteger, YYVideoListPlayerReachabilityStatus) {
    YYVideoListPlayerReachabilityStatusUnknown          = -1,
    YYVideoListPlayerReachabilityStatusNotReachable     = 0,
    YYVideoListPlayerReachabilityStatusReachableViaWiFi = 1,
    YYVideoListPlayerReachabilityStatusReachableVia2G   = 2,
    YYVideoListPlayerReachabilityStatusReachableVia3G   = 3,
    YYVideoListPlayerReachabilityStatusReachableVia4G   = 4,
    YYVideoListPlayerReachabilityStatusReachableVia5G   = 5
};

@protocol YYVideoListPlayerCellDelegate <NSObject>

@optional
- (void)videoListPlayerCellPlayDidToEnd;
- (void)videoListPlayerCellPlayLoadState:(YYVideoListPlayerPlayLoadState)state;
@end

@interface YYVideoListPlayerCell : UICollectionViewCell
@property (strong, nonatomic) YYVideoListPlayerModel * model;
@property (weak,   nonatomic) id <YYVideoListPlayerCellDelegate> delegate;
@property (strong, nonatomic, readonly) ZFPlayerController * playerController;
@property (assign, nonatomic) BOOL isCurrent;
@property (assign, nonatomic) BOOL viewControllerDisappear;
@property (assign, nonatomic, readonly) BOOL isPlaying;
@property (assign, nonatomic, readonly) YYVideoListPlayerPlayBackState playState;
@property (assign, nonatomic, readonly) YYVideoListPlayerPlayLoadState loadState;

- (void)play;
- (void)pause;
- (void)stop;
- (void)replay;
- (void)reloadPlayer;
- (void)seekTime:(NSTimeInterval)seekTime;

/// 下面方法中有设置代理， 子类需要调用super，否则需要在子类重写代理。
- (void)playerPlayCurrenTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;
- (void)playerPlayBackState:(YYVideoListPlayerPlayBackState)state;
- (void)playerPlayLoadState:(YYVideoListPlayerPlayLoadState)state;
- (void)playerPlayBufferTime:(NSTimeInterval)bufferTime;
- (void)playerPlayFailed:(NSError *)error;
- (void)playerPlayDidToEnd;

- (void)playerSingleTapped;
- (void)playerDoubleTapped;

- (void)resetSubViews;
@end

NS_ASSUME_NONNULL_END
