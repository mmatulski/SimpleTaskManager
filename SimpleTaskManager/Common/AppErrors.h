//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

#define __ERR(code) [AppErrors prepareErrorWithCode:code]

#define ERROR_TASK_NOT_FOUND 1001

@interface AppErrors : NSObject
+ (NSError *)prepareErrorWithCode:(NSInteger)code;
@end