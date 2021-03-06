//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

#define __(locale) NSLocalizedString(locale, nil)
#define runOnBackgroundThread( ... ) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ##__VA_ARGS__)
#define runOnMainThread( ... )  dispatch_async(dispatch_get_main_queue(), ##__VA_ARGS__)

#define BlockWeakObject(o) __typeof(o) __weak
#define BlockWeakSelf BlockWeakObject(self)
#define BlockStrongSelf BlockStrongObject(self)
#define BlockStrongObject(o) __typeof(o) __strong

#define TICK NSDate *startTime = [NSDate date];
#define TOCK DDLogInfo(@"Elapsed Time: %f", -[startTime timeIntervalSinceNow]);

extern id MakeSafeCast(id object, Class targetClass);
extern void forwardError(NSError *err, NSError **error);

extern id performSelectorIfRespondsTo(id object, SEL selector);
extern void performSelectorIfRespondsToVoid(id object, SEL selector);


