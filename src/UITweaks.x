#import "Shared.h"

// ─── Interfaces ───────────────────────────────────────────────────────────────

@interface YTPivotBarView : UIView @end
@interface YTPivotBarItemView : UIView
- (NSString *)pivotIdentifier;
@end
@interface YTShortsShelfView : UIView @end
@interface YTRelatedVideosView : UIView @end
@interface YTCommentSectionView : UIView @end
@interface YTEndScreenView : UIView @end
@interface YTWatermarkView : UIView @end
@interface YTInfoCardView : UIView @end
@interface YTCastButtonView : UIView @end
@interface YTNotificationPrefBellIconView : UIView @end
@interface YTPlayerOverlayView : UIView @end

@interface YTPivotBarViewController : UIViewController
- (NSArray *)pivotBarItems;
@end

// ─── Bottom tab bar ───────────────────────────────────────────────────────────

%hook YTPivotBarItemView

- (void)didMoveToWindow {
    %orig;
    if (![YTKPrefs boolForKey:kHideShorts]) return;
    NSString *pid = [self pivotIdentifier];
    if ([pid isEqualToString:@"FEshorts"]) {
        self.hidden = YES;
    }
}

%end

// ─── Shorts shelf in home feed ────────────────────────────────────────────────

%hook YTShortsShelfView

- (void)didMoveToWindow {
    %orig;
    if ([YTKPrefs boolForKey:kHideShortsFeed]) self.hidden = YES;
}

%end

// ─── Related / suggested videos ───────────────────────────────────────────────

%hook YTRelatedVideosView

- (void)didMoveToWindow {
    %orig;
    if ([YTKPrefs boolForKey:kHideRelatedVideos]) self.hidden = YES;
}

%end

// ─── Comments ─────────────────────────────────────────────────────────────────

%hook YTCommentSectionView

- (void)didMoveToWindow {
    %orig;
    if ([YTKPrefs boolForKey:kHideComments]) self.hidden = YES;
}

%end

// ─── End cards ────────────────────────────────────────────────────────────────

%hook YTEndScreenView

- (void)didMoveToWindow {
    %orig;
    if ([YTKPrefs boolForKey:kHideEndCards]) self.hidden = YES;
}

%end

// ─── Channel watermark ────────────────────────────────────────────────────────

%hook YTWatermarkView

- (void)didMoveToWindow {
    %orig;
    if ([YTKPrefs boolForKey:kHideWatermark]) self.hidden = YES;
}

%end

// ─── Info cards ───────────────────────────────────────────────────────────────

%hook YTInfoCardView

- (void)didMoveToWindow {
    %orig;
    if ([YTKPrefs boolForKey:kHideInfoCards]) self.hidden = YES;
}

%end

// ─── Cast button ──────────────────────────────────────────────────────────────

%hook YTCastButtonView

- (void)didMoveToWindow {
    %orig;
    if ([YTKPrefs boolForKey:kHideCastButton]) self.hidden = YES;
}

%end

// ─── Notification bell ────────────────────────────────────────────────────────

%hook YTNotificationPrefBellIconView

- (void)didMoveToWindow {
    %orig;
    if ([YTKPrefs boolForKey:kHideNotifButton]) self.hidden = YES;
}

%end
