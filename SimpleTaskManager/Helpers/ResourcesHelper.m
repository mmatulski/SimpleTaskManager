//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "ResourcesHelper.h"
#import "WindowHelper.h"

#define RETINA_SUFFIX @"@2x"

@implementation ResourcesHelper {

}

+(UIImage*) image:(NSString*) name{
    NSString* fileName = name;
    if ([WindowHelper isRetinaDisplay]) {
        fileName = [fileName stringByAppendingString:RETINA_SUFFIX];
    }

    return [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:fileName ofType:@"png"]];
}

@end