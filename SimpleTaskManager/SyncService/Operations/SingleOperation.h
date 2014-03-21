//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManagedOperation.h"

@class STMTask;
@protocol SingleOperationDelegate;


@interface SingleOperation : ManagedOperation

@property(nonatomic, weak) id<SingleOperationDelegate> delegate;
@property(nonatomic, strong) NSDate * timeWhenOperationWasRequested;//maybe all should be kept in db
@property(nonatomic, strong) void (^successFullBlock)(STMTask *);
@property(nonatomic, strong) void (^failureBlock)(NSError *);
@property(nonatomic) BOOL success;
@property(nonatomic, strong) NSError *error;


- (void)finishedSuccessFully;

- (void)failedWithError:(NSError *)error;

- (void)performAdequateBlock;
@end