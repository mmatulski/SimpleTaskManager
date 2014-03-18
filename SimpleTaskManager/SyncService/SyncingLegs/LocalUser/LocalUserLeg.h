//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncingLeg.h"

@class RemoteLeg;


@interface LocalUserLeg : SyncingLeg

@property(nonatomic, strong) NSMutableArray * operationsWaitingForSyncWithServer;

@end