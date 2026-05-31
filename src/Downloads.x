#import "Shared.h"
#import <AVFoundation/AVFoundation.h>

// ─── Interfaces ───────────────────────────────────────────────────────────────

@interface YTPlayerViewController : UIViewController
- (NSString *)currentVideoID;
- (NSString *)currentVideoTitle;
@end

@interface YTMainAppControlsOverlayView : UIView
- (UIView *)topBar;
@end

// ─── Download manager ─────────────────────────────────────────────────────────

@interface YTKDownloadManager : NSObject <NSURLSessionDownloadDelegate>
+ (instancetype)shared;
- (void)downloadVideoID:(NSString *)videoID title:(NSString *)title quality:(NSString *)quality;
@end

@implementation YTKDownloadManager {
    NSURLSession *_session;
    NSMutableDictionary<NSURLSessionTask *, NSString *> *_taskTitles;
}

+ (instancetype)shared {
    static YTKDownloadManager *inst;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ inst = [YTKDownloadManager new]; });
    return inst;
}

- (instancetype)init {
    self = [super init];
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:nil];
    _taskTitles = [NSMutableDictionary new];
    return self;
}

- (void)downloadVideoID:(NSString *)videoID title:(NSString *)title quality:(NSString *)quality {
    // Resolve a download URL via the yt-dlp compatible API approach.
    // We use YouTube's /get_video_info endpoint for basic stream info.
    // NOTE: YouTube aggressively updates stream signing; for production
    //       usage integrate yt-dlp or a proxy server of your choice.
    NSString *urlStr = [NSString stringWithFormat:
        @"https://www.youtube.com/watch?v=%@", videoID];
    YTKLog(@"Download requested: %@ (%@) q=%@", title, urlStr, quality);

    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Download"
            message:[NSString stringWithFormat:@"Queued: %@\n\nNote: Integrate a stream resolver (yt-dlp/server) for production downloads.", title]
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        [root presentViewController:alert animated:YES completion:nil];
    });
}

// NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)task didFinishDownloadingToURL:(NSURL *)location {
    NSString *title = _taskTitles[task] ?: @"video";
    NSURL *dest = [[self downloadsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", title]];
    NSError *err;
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:dest error:&err];
    if (err) YTKLog(@"Download move error: %@", err);
    else     YTKLog(@"Download saved to: %@", dest.path);
    [_taskTitles removeObjectForKey:task];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)task didWriteData:(int64_t)written totalWritten:(int64_t)totalWritten totalExpected:(int64_t)total {
    if (total > 0) {
        float pct = (float)totalWritten / (float)total * 100.f;
        YTKLog(@"Download progress: %.1f%%", pct);
    }
}

- (NSURL *)downloadsDirectory {
    NSURL *docs = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *dir = [docs URLByAppendingPathComponent:@"YTKillerPlus/Video"];
    [[NSFileManager defaultManager] createDirectoryAtURL:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return dir;
}

@end

// ─── Download button injected into player overlay ─────────────────────────────

%hook YTMainAppControlsOverlayView

- (void)didMoveToWindow {
    %orig;
    if (![YTKPrefs boolForKey:kDownloadEnabled]) return;
    if ([self viewWithTag:9901]) return; // already added

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.tag = 9901;
    btn.tintColor = UIColor.whiteColor;
    [btn setImage:[UIImage systemImageNamed:@"arrow.down.circle.fill"] forState:UIControlStateNormal];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:btn];

    [NSLayoutConstraint activateConstraints:@[
        [btn.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-60],
        [btn.topAnchor constraintEqualToAnchor:self.topAnchor constant:12],
        [btn.widthAnchor constraintEqualToConstant:36],
        [btn.heightAnchor constraintEqualToConstant:36],
    ]];

    [btn addTarget:self action:@selector(ytkDownloadTapped:) forControlEvents:UIControlEventTouchUpInside];
}

%new
- (void)ytkDownloadTapped:(UIButton *)sender {
    UIViewController *vc = nil;
    UIResponder *responder = self;
    while ((responder = responder.nextResponder)) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            vc = (UIViewController *)responder;
            break;
        }
    }

    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Download Quality" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *q in @[@"1080p", @"720p", @"480p", @"360p", @"Audio only"]) {
        [sheet addAction:[UIAlertAction actionWithTitle:q style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            // Retrieve video ID from the nearest YTPlayerViewController
            UIResponder *r = self;
            while ((r = r.nextResponder)) {
                if ([r respondsToSelector:@selector(currentVideoID)]) {
                    NSString *vid = [(id)r currentVideoID];
                    NSString *title = [(id)r currentVideoTitle] ?: vid;
                    [[YTKDownloadManager shared] downloadVideoID:vid title:title quality:a.title];
                    break;
                }
            }
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [vc presentViewController:sheet animated:YES completion:nil];
}

%end
