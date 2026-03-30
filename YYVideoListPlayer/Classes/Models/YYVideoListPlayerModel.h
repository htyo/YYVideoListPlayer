//
//  YYVideoListPlayerModel.h
//  YYVideoListPlayer
//
//  Created by yanbao on 2026/3/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YYVideoListPlayerModel : NSObject
@property (assign, nonatomic) NSInteger videoId;
@property (strong, nonatomic) NSString * videoImageUrl;
@property (strong, nonatomic) NSString * videoUrl;
@property (assign, nonatomic) NSTimeInterval currentTime;
@end

NS_ASSUME_NONNULL_END
