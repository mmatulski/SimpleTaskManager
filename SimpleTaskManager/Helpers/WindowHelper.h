//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WindowHelper : NSObject

+ (BOOL) isRetinaDisplay;

+ (UIWindow *)mainWindow;

+ (CGRect)mainWindowBoundsIOnCurrentOrientation;

@end