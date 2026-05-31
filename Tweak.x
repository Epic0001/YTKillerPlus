#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "src/Shared.h"

// Module entry points are defined in their respective .x files.
// This file just wires up the %ctor initialisation order.

%ctor {
    YTKLog(@"YTKillerPlus loaded (v%@)", YTKPLUS_VERSION);
    [YTKPrefs reload];
}
