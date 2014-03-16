//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

#define runOnBackgroundThread( ... ) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ##__VA_ARGS__)
#define runOnMainThread( ... )  dispatch_async(dispatch_get_main_queue(), ##__VA_ARGS__)

#define BlockWeakObject(o) __typeof(o) __weak
#define BlockWeakSelf BlockWeakObject(self)

extern id MakeSafeCast(id object, Class targetClass);

extern void forwardError(NSError *err, NSError **error);

#define __(locale) NSLocalizedString(locale, nil)

