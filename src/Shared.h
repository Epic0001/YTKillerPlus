#pragma once
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define YTKPLUS_VERSION     @"1.0.0"
#define YTKPLUS_BUNDLE_ID   @"com.google.ios.youtube"
#define YTKPLUS_PREFS_PATH  @"/var/mobile/Library/Preferences/com.epic0001.ytkplus.plist"

// Logging
#define YTKLog(fmt, ...) NSLog(@"[YTKillerPlus] " fmt, ##__VA_ARGS__)

// ─── Preference keys ─────────────────────────────────────────────────────────
#define kAdBlockEnabled           @"adBlockEnabled"
#define kBackgroundPlayEnabled    @"backgroundPlayEnabled"
#define kPiPEnabled               @"pipEnabled"
#define kDownloadEnabled          @"downloadEnabled"
#define kSponsorBlockEnabled      @"sponsorBlockEnabled"
#define kSpeedControlEnabled      @"speedControlEnabled"
#define kDefaultSpeed             @"defaultSpeed"
#define kHideShorts               @"hideShorts"
#define kHideComments             @"hideComments"
#define kHideEndCards             @"hideEndCards"
#define kHideSuggestedVideos      @"hideSuggestedVideos"
#define kHideRelatedVideos        @"hideRelatedVideos"
#define kHideInfoCards            @"hideInfoCards"
#define kHideWatermark            @"hideWatermark"
#define kHideTabLabels            @"hideTabLabels"
#define kHideShortsFeed           @"hideShortsFeed"
#define kHideNotifButton          @"hideNotifButton"
#define kHideCastButton           @"hideCastButton"
#define kAutoSkipAds              @"autoSkipAds"
#define kCellularQuality          @"cellularQuality"
#define kWifiQuality              @"wifiQuality"

// ─── Prefs helper ─────────────────────────────────────────────────────────────
@interface YTKPrefs : NSObject
+ (void)reload;
+ (BOOL)boolForKey:(NSString *)key;
+ (float)floatForKey:(NSString *)key defaultValue:(float)def;
+ (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)def;
@end

@implementation YTKPrefs {
}

static NSDictionary *_prefs = nil;

+ (void)reload {
    _prefs = [NSDictionary dictionaryWithContentsOfFile:YTKPLUS_PREFS_PATH] ?: @{};
}

+ (BOOL)boolForKey:(NSString *)key {
    if (!_prefs) [self reload];
    NSNumber *val = _prefs[key];
    return val ? [val boolValue] : NO;
}

+ (float)floatForKey:(NSString *)key defaultValue:(float)def {
    if (!_prefs) [self reload];
    NSNumber *val = _prefs[key];
    return val ? [val floatValue] : def;
}

+ (NSString *)stringForKey:(NSString *)key defaultValue:(NSString *)def {
    if (!_prefs) [self reload];
    return _prefs[key] ?: def;
}
@end
