//
// Created by Marek M on 11.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "STMColors.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define GRAY(x) [UIColor colorWithWhite:x/255.0 alpha:1.0]

@implementation STMColors {

}
+ (UIColor *)cellBackgroundColor {
    return RGB(186, 183, 164);
}

+ (UIColor *)cellTextColor {
    return [UIColor whiteColor];
}

@end