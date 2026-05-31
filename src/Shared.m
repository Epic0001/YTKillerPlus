#import "Shared.h"

static NSDictionary *_prefs = nil;

@implementation YTKPrefs

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
