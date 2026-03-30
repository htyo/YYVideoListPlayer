//
//  YYVideoListPlayerCell.m
//  YYVideoListPlayer
//
//  Created by yanbao on 2026/3/30.
//

#import "YYVideoListPlayerCell.h"


@interface YYVideoListPlayerCell ()
@property (strong, nonatomic) ZFPlayerController * playerController;
@property (assign, nonatomic) YYVideoListPlayerPlayBackState playState;
@property (assign, nonatomic) YYVideoListPlayerPlayLoadState loadState;
@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) YYVideoListPlayerReachabilityStatus reachabilityStatus;
@end

@implementation YYVideoListPlayerCell

- (ZFPlayerController *)playerController {
    if (!_playerController) {
        ZFAVPlayerManager * playerManager = [[ZFAVPlayerManager alloc] init];
        playerManager.shouldAutoPlay = NO;
        playerManager.scalingMode = ZFPlayerScalingModeAspectFill;
        
        _playerController = [[ZFPlayerController alloc] init];
        _playerController.currentPlayerManager = playerManager;
        _playerController.disableGestureTypes = ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
        _playerController.allowOrentitaionRotation = NO;
        _playerController.viewControllerDisappear = YES;
    }
    return _playerController;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupSubViews];
        [self _setupPlayer];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetSubViews];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _setupSubViews];
    [self _setupPlayer];
}

- (void)_setupSubViews {
    
    UIView * view = self.playerController.currentPlayerManager.view;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView insertSubview:view atIndex:0];
    

    [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:0]];
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:0]];
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0]];
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.contentView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0]];
    

}

- (void)_setupPlayer {
    __weak typeof(self) weakSelf = self;
    
    self.reachabilityStatus = -2;
    
    id<ZFPlayerMediaPlayback> playerManager = self.playerController.currentPlayerManager;
    
    playerManager.scalingMode = ZFPlayerScalingModeAspectFill;

    /// 播放进度回调
    playerManager.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        [weakSelf playerPlayCurrenTime:currentTime duration:duration];
    };
    
    /// 播放状态回调
    playerManager.playerPlayStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerPlaybackState playState) {
        weakSelf.playState = (YYVideoListPlayerPlayBackState)playState;
        [weakSelf playerPlayBackState:(YYVideoListPlayerPlayBackState)playState];
    };
    
    /// 加载状态回调
    playerManager.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        weakSelf.loadState = (YYVideoListPlayerPlayLoadState)loadState;
        [weakSelf playerPlayLoadState:(YYVideoListPlayerPlayLoadState)loadState];
    };
    
    /// 缓存进度回调
    playerManager.playerBufferTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval bufferTime) {
        [weakSelf playerPlayBufferTime:weakSelf.playerController.bufferTime/weakSelf.playerController.totalTime];
    };
    
    
    /// 播放失败回调
    playerManager.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        [weakSelf playerPlayFailed:error];
    };
    
    /// 播放结束回调
    playerManager.playerDidToEnd = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        weakSelf.playState = YYVideoListPlayerPlayBackStateEnd;
        [weakSelf playerPlayDidToEnd];
    };
    
    self.playerController.gestureControl.singleTapped = ^(ZFPlayerGestureControl * _Nonnull control) {
        [self playerSingleTapped];
    };
    
    self.playerController.gestureControl.doubleTapped = ^(ZFPlayerGestureControl * _Nonnull control) {
        [self playerDoubleTapped];
    };
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChangeNotification:) name:ZFReachabilityDidChangeNotification object:nil];

}

- (void)reachabilityDidChangeNotification:(NSNotification *) notification {
    NSInteger status = [notification.userInfo[ZFReachabilityNotificationStatusItem] integerValue];
    [self playerReachabilityDidChange:status];
    
    if ((self.reachabilityStatus == 0 || self.reachabilityStatus == -1) && status >= 1) {
        [self reloadPlayer];
    }
    self.reachabilityStatus = status;
}

- (void)setViewControllerDisappear:(BOOL)viewControllerDisappear {
    _viewControllerDisappear = viewControllerDisappear;
    self.playerController.viewControllerDisappear = viewControllerDisappear;
}

- (void)setModel:(YYVideoListPlayerModel *)model {
    _model = model;
    self.playerController.currentPlayerManager.assetURL = [NSURL URLWithString:model.videoUrl];
    [self pause];
//    [self.playerController.currentPlayerManager.view.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.videoImageUrl]];
}

- (void)play {
    self.isPlaying = YES;
    if (self.playerController.currentTime >= self.playerController.totalTime - 1.0) {
        [self.playerController.currentPlayerManager replay];
    } else {
        [self.playerController.currentPlayerManager play];
    }
}

- (void)pause {
    self.isPlaying = NO;
    [self.playerController.currentPlayerManager pause];

}

- (void)stop {
    [self.playerController.currentPlayerManager stop];

}

- (void)replay {
    self.isPlaying = YES;
    [self.playerController.currentPlayerManager replay];
}

- (void)reloadPlayer {
    [self.playerController.currentPlayerManager reloadPlayer];
}

- (void)seekTime:(NSTimeInterval)seekTime {
    self.playerController.currentPlayerManager.seekTime = seekTime;

}

- (void)playerPlayCurrenTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {}

- (void)playerPlayBackState:(YYVideoListPlayerPlayBackState)state {}

- (void)playerPlayLoadState:(YYVideoListPlayerPlayLoadState)state {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoListPlayerCellPlayLoadState:)]) {
        [self.delegate videoListPlayerCellPlayLoadState:state];
    }
}

- (void)playerPlayBufferTime:(NSTimeInterval)bufferTime {
    
}

- (void)playerPlayFailed:(NSError *)error{
    NSLog(@"playerPlayFailed:%@",error);
}

- (void)playerPlayDidToEnd{
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoListPlayerCellPlayDidToEnd)]) {
        [self.delegate videoListPlayerCellPlayDidToEnd];
    }
}

- (void)playerReachabilityDidChange:(YYVideoListPlayerReachabilityStatus)status{}

- (void)playerSingleTapped {
}

- (void)playerDoubleTapped {}

- (void)resetSubViews {
    self.isPlaying = NO;
    self.reachabilityStatus = -2;
}
@end

