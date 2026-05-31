#import "Shared.h"
#import <AVFoundation/AVFoundation.h>

// ─── Interfaces ───────────────────────────────────────────────────────────────

@interface YTPlayerViewController : UIViewController
- (AVPlayer *)contentVideoPlayer;
@end

@interface YTMainAppControlsOverlayView : UIView @end

// ─── Speed overlay view ───────────────────────────────────────────────────────

@interface YTKSpeedPill : UIView
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *decreaseBtn;
@property (nonatomic, strong) UIButton *increaseBtn;
@property (nonatomic, weak)   AVPlayer *player;
@property (nonatomic, assign) float currentSpeed;
@end

@implementation YTKSpeedPill

- (instancetype)initWithPlayer:(AVPlayer *)player {
    self = [super initWithFrame:CGRectMake(0, 0, 160, 36)];
    if (!self) return nil;

    self.player = player;
    self.currentSpeed = [YTKPrefs floatForKey:kDefaultSpeed defaultValue:1.0f];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.layer.cornerRadius = 18;
    self.clipsToBounds = YES;

    _decreaseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_decreaseBtn setTitle:@"−" forState:UIControlStateNormal];
    _decreaseBtn.tintColor = UIColor.whiteColor;
    _decreaseBtn.frame = CGRectMake(0, 0, 40, 36);
    [_decreaseBtn addTarget:self action:@selector(decrease) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_decreaseBtn];

    _label = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 80, 36)];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = UIColor.whiteColor;
    _label.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:_label];

    _increaseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_increaseBtn setTitle:@"+" forState:UIControlStateNormal];
    _increaseBtn.tintColor = UIColor.whiteColor;
    _increaseBtn.frame = CGRectMake(120, 0, 40, 36);
    [_increaseBtn addTarget:self action:@selector(increase) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_increaseBtn];

    [self refreshLabel];
    return self;
}

- (void)refreshLabel {
    _label.text = [NSString stringWithFormat:@"%.2gx", self.currentSpeed];
}

- (void)applySpeed {
    if (self.player) {
        self.player.rate = self.currentSpeed;
        YTKLog(@"Speed set to %.2g", self.currentSpeed);
    }
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:YTKPLUS_PREFS_PATH] ?: [NSMutableDictionary new];
    prefs[kDefaultSpeed] = @(self.currentSpeed);
    [prefs writeToFile:YTKPLUS_PREFS_PATH atomically:YES];
}

static const float kSpeedSteps[] = { 0.25f, 0.5f, 0.75f, 1.0f, 1.25f, 1.5f, 1.75f, 2.0f, 2.5f, 3.0f };
static const int kSpeedStepCount = sizeof(kSpeedSteps) / sizeof(kSpeedSteps[0]);

- (void)decrease {
    float cur = self.currentSpeed;
    for (int i = kSpeedStepCount - 1; i >= 0; i--) {
        if (kSpeedSteps[i] < cur - 0.01f) {
            self.currentSpeed = kSpeedSteps[i];
            break;
        }
    }
    [self refreshLabel];
    [self applySpeed];
}

- (void)increase {
    float cur = self.currentSpeed;
    for (int i = 0; i < kSpeedStepCount; i++) {
        if (kSpeedSteps[i] > cur + 0.01f) {
            self.currentSpeed = kSpeedSteps[i];
            break;
        }
    }
    [self refreshLabel];
    [self applySpeed];
}

@end

// ─── Hooks ─────────────────────────────────────────────────────────────────────

%hook YTPlayerViewController

- (void)viewDidLoad {
    %orig;
    if (![YTKPrefs boolForKey:kSpeedControlEnabled]) return;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AVPlayer *player = [self contentVideoPlayer];
        if (!player) return;

        float savedSpeed = [YTKPrefs floatForKey:kDefaultSpeed defaultValue:1.0f];
        if (savedSpeed != 1.0f) {
            player.rate = savedSpeed;
            YTKLog(@"Restored saved speed %.2g", savedSpeed);
        }

        YTKSpeedPill *pill = [[YTKSpeedPill alloc] initWithPlayer:player];
        pill.currentSpeed = player.rate;
        [pill refreshLabel];

        UIView *root = self.view;
        pill.translatesAutoresizingMaskIntoConstraints = NO;
        [root addSubview:pill];
        [NSLayoutConstraint activateConstraints:@[
            [pill.topAnchor constraintEqualToAnchor:root.safeAreaLayoutGuide.topAnchor constant:8],
            [pill.trailingAnchor constraintEqualToAnchor:root.trailingAnchor constant:-16],
            [pill.widthAnchor constraintEqualToConstant:160],
            [pill.heightAnchor constraintEqualToConstant:36],
        ]];
    });
}

%end
