//
// Created by Marek M on 11.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "AppColors.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define GRAY(x) [UIColor colorWithWhite:x/255.0 alpha:1.0]

@implementation AppColors {

}
+ (UIColor *)cellBackgroundColor {
    return RGB(186, 183, 164);
}

+ (UIColor *)cellTextColor {
    return [UIColor whiteColor];
}

+ (UIColor *) stillToDoButtonColor {
    return RGB(239, 119, 119);
}

+ (UIColor *)messageDialogsBackgroundColor {
    return [UIColor colorWithRed:0.3 green:0.5 blue:0.7 alpha:0.8];
}

+ (UIColor *)cellDraggingTargetBackgroundColor {
    return RGB(184,184,255);
}

+ (UIColor *)cellBlinkingColor {
    return RGB(140,140,255);
}

+ (UIColor *)selectedCellBackgroundColor {
    return RGB(154,154,255);
}
@end