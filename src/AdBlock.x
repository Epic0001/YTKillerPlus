#import "Shared.h"
#import <AVFoundation/AVFoundation.h>

// ─── Interfaces for private YouTube classes ───────────────────────────────────

@interface YTPlayerViewController : UIViewController
- (void)skipCurrentAd;
- (BOOL)isShowingAd;
@end

@interface YTAdClientPlaybackStartingConditionChecker : NSObject
- (BOOL)shouldAllowPlaybackToStartForClientWithVideoID:(NSString *)videoID;
@end

@interface YTAdsNativeAdPlayerOverlayView : UIView @end
@interface YTAdShieldView : UIView @end
@interface YTNativeAdView : UIView @end
@interface YTPromotedVideoAdPlayerView : UIView @end
@interface YTBannerAdView : UIView @end
@interface YTNativeAdOverlayView : UIView @end
@interface YTMidrollView : UIView @end
@interface YTMixedAdController : NSObject @end

@interface YTPlayerModel : NSObject
- (void)seekToTimeSeconds:(double)time;
- (double)getDuration;
- (BOOL)isAdPlaying;
@end

@interface YTSkipAdView : UIView
- (UIButton *)skipButton;
@end

// ─── Hooks ─────────────────────────────────────────────────────────────────────

// Block ad overlays from appearing
%hook YTAdsNativeAdPlayerOverlayView
- (void)didMoveToWindow {
    if ([YTKPrefs boolForKey:kAdBlockEnabled]) return;
    %orig;
}
%end

%hook YTAdShieldView
- (void)didMoveToWindow {
    if ([YTKPrefs boolForKey:kAdBlockEnabled]) return;
    %orig;
}
%end

%hook YTNativeAdView
- (void)didMoveToWindow {
    if ([YTKPrefs boolForKey:kAdBlockEnabled]) return;
    %orig;
}
%end

%hook YTPromotedVideoAdPlayerView
- (void)didMoveToWindow {
    if ([YTKPrefs boolForKey:kAdBlockEnabled]) return;
    %orig;
}
%end

%hook YTBannerAdView
- (void)didMoveToWindow {
    if ([YTKPrefs boolForKey:kAdBlockEnabled]) return;
    %orig;
}
%end

%hook YTNativeAdOverlayView
- (void)didMoveToWindow {
    if ([YTKPrefs boolForKey:kAdBlockEnabled]) return;
    %orig;
}
%end

%hook YTMidrollView
- (void)didMoveToWindow {
    if ([YTKPrefs boolForKey:kAdBlockEnabled]) return;
    %orig;
}
%end

// Allow playback regardless of ad state
%hook YTAdClientPlaybackStartingConditionChecker
- (BOOL)shouldAllowPlaybackToStartForClientWithVideoID:(NSString *)videoID {
    if ([YTKPrefs boolForKey:kAdBlockEnabled]) return YES;
    return %orig;
}
%end

// Auto-skip skippable ads
%hook YTSkipAdView
- (void)didMoveToWindow {
    %orig;
    if (![YTKPrefs boolForKey:kAutoSkipAds]) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIButton *btn = [self skipButton];
        if (btn && !btn.hidden) {
            [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
            YTKLog(@"Auto-skipped ad");
        }
    });
}
%end
