#import "Shared.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

// ─── Interfaces ───────────────────────────────────────────────────────────────

@interface YTBackgroundabilityPolicy : NSObject
- (BOOL)isBackgroundabilityEnabled;
@end

@interface YTPlayerViewController : UIViewController
- (AVPlayer *)contentVideoPlayer;
@end

@interface YTPivotBarViewController : UIViewController @end

@interface AVPictureInPictureController (YTK)
+ (BOOL)isPictureInPictureSupported;
@end

// ─── Hooks ─────────────────────────────────────────────────────────────────────

%hook YTBackgroundabilityPolicy
- (BOOL)isBackgroundabilityEnabled {
    if ([YTKPrefs boolForKey:kBackgroundPlayEnabled]) return YES;
    return %orig;
}
%end

%hook YTPlayerViewController

- (void)viewDidLoad {
    %orig;
    if (![YTKPrefs boolForKey:kBackgroundPlayEnabled]) return;

    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [session setCategory:AVAudioSessionCategoryPlayback error:&err];
    if (err) YTKLog(@"AVAudioSession error: %@", err);
    [session setActive:YES error:nil];
}

- (void)applicationDidEnterBackground:(id)app {
    if ([YTKPrefs boolForKey:kBackgroundPlayEnabled]) return;
    %orig;
}

%end

// ─── PiP ──────────────────────────────────────────────────────────────────────

%hook AVPlayerViewController

- (BOOL)allowsPictureInPicturePlayback {
    if ([YTKPrefs boolForKey:kPiPEnabled]) return YES;
    return %orig;
}

%end
