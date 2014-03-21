//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ManagedOperation : NSOperation

@property BOOL done;

- (BOOL)isConcurrent;

- (BOOL)isExecuting;

- (BOOL)isFinished;

- (void)finish;

@end