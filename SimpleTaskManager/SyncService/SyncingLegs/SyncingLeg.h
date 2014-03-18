//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingleOperationDelegate.h"
#import "SyncingLegProtocol.h"

@class STMTask;
@class SyncGuardService;

@class SingleOperation;

@interface SyncingLeg : NSObject <SingleOperationDelegate, SyncingLegProtocol>

@property(nonatomic, strong) NSMutableArray *operationsWaitingToSyncWidthLocalDB;
@property(nonatomic, weak) SyncGuardService *syncGuardService;

- (SingleOperation *)nextOperation;

@end