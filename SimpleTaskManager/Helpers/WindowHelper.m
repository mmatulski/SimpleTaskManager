//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "WindowHelper.h"


@implementation WindowHelper {

}

+(BOOL) isRetinaDisplay{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)){
        return true;
    }

    return false;
}

+(UIWindow*) mainWindow{
    NSArray* windows = [UIApplication sharedApplication].windows;
    if (windows && [windows count] > 0) {
        return [windows objectAtIndex:0];
    }

    return nil;
}

+(CGRect) mainWindowBoundsIOnCurrentOrientation{
    CGRect result = [self mainWindowBounds];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        result = CGRectMake(result.origin.x, result.origin.y, result.size.height, result.size.width);
    }

    return result;
}

+(CGRect) mainWindowBounds{
    return self.mainWindow.bounds;
}

@end