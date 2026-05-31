#import "Shared.h"
#import <AVFoundation/AVFoundation.h>

// ─── Interfaces ───────────────────────────────────────────────────────────────

@interface YTPlayerViewController : UIViewController
- (AVPlayer *)contentVideoPlayer;
- (NSString *)currentVideoID;
@end

// ─── Segment model ────────────────────────────────────────────────────────────

typedef NS_ENUM(NSInteger, SBCategory) {
    SBCategorySponsored,
    SBCategoryIntro,
    SBCategoryOutro,
    SBCategoryInteraction,
    SBCategorySelfPromo,
    SBCategoryMusicOfftopic,
    SBCategoryPreview,
    SBCategoryFiller,
};

@interface YTKSBSegment : NSObject
@property (nonatomic) double start;
@property (nonatomic) double end;
@property (nonatomic) SBCategory category;
@end

@implementation YTKSBSegment @end

// ─── Manager ──────────────────────────────────────────────────────────────────

@interface YTKSponsorBlock : NSObject
+ (instancetype)shared;
- (void)fetchSegmentsForVideoID:(NSString *)videoID completion:(void(^)(NSArray<YTKSBSegment *> *))completion;
@end

@implementation YTKSponsorBlock {
    NSMutableDictionary<NSString *, NSArray<YTKSBSegment *> *> *_cache;
}

+ (instancetype)shared {
    static YTKSponsorBlock *inst;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ inst = [YTKSponsorBlock new]; });
    return inst;
}

- (instancetype)init {
    self = [super init];
    _cache = [NSMutableDictionary new];
    return self;
}

static NSString *const kSBAPIBase = @"https://sponsor.ajay.app/api/skipSegments";
static NSString *const kSBCategories = @"[\"sponsor\",\"intro\",\"outro\",\"interaction\",\"selfpromo\",\"music_offtopic\",\"preview\",\"filler\"]";

- (void)fetchSegmentsForVideoID:(NSString *)videoID completion:(void(^)(NSArray<YTKSBSegment *> *))completion {
    if (!videoID.length) { completion(@[]); return; }

    NSArray *cached = _cache[videoID];
    if (cached) { completion(cached); return; }

    NSString *encoded = [kSBCategories stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?videoID=%@&categories=%@", kSBAPIBase, videoID, encoded]];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *resp, NSError *err) {
        if (err || !data) { completion(@[]); return; }

        NSError *jsonErr;
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonErr];
        if (jsonErr || ![json isKindOfClass:[NSArray class]]) { completion(@[]); return; }

        NSMutableArray<YTKSBSegment *> *segs = [NSMutableArray new];
        NSDictionary *catMap = @{
            @"sponsor": @(SBCategorySponsored),
            @"intro": @(SBCategoryIntro),
            @"outro": @(SBCategoryOutro),
            @"interaction": @(SBCategoryInteraction),
            @"selfpromo": @(SBCategorySelfPromo),
            @"music_offtopic": @(SBCategoryMusicOfftopic),
            @"preview": @(SBCategoryPreview),
            @"filler": @(SBCategoryFiller),
        };

        for (NSDictionary *item in json) {
            NSArray *seg = item[@"segment"];
            if (seg.count != 2) continue;
            YTKSBSegment *s = [YTKSBSegment new];
            s.start = [seg[0] doubleValue];
            s.end   = [seg[1] doubleValue];
            s.category = [catMap[item[@"category"]] integerValue];
            [segs addObject:s];
        }

        self->_cache[videoID] = segs;
        YTKLog(@"SponsorBlock: fetched %lu segment(s) for %@", (unsigned long)segs.count, videoID);
        completion(segs);
    }];
    [task resume];
}

@end

// ─── Hooks ─────────────────────────────────────────────────────────────────────

%hook YTPlayerViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if (![YTKPrefs boolForKey:kSponsorBlockEnabled]) return;

    NSString *videoID = [self currentVideoID];
    if (!videoID.length) return;

    AVPlayer *player = [self contentVideoPlayer];
    if (!player) return;

    [[YTKSponsorBlock shared] fetchSegmentsForVideoID:videoID completion:^(NSArray<YTKSBSegment *> *segments) {
        if (!segments.count) return;

        // Observe player time and skip matching segments
        __weak AVPlayer *weakPlayer = player;
        CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
        [player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            AVPlayer *p = weakPlayer;
            if (!p) return;
            double current = CMTimeGetSeconds(time);
            for (YTKSBSegment *seg in segments) {
                if (current >= seg.start && current < seg.end) {
                    YTKLog(@"SponsorBlock: skipping segment %.1f–%.1f (%ld)", seg.start, seg.end, (long)seg.category);
                    [p seekToTime:CMTimeMakeWithSeconds(seg.end, NSEC_PER_SEC)
                  toleranceBefore:kCMTimeZero
                   toleranceAfter:kCMTimeZero];
                    break;
                }
            }
        }];
    }];
}

%end
