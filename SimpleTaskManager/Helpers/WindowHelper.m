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

@end