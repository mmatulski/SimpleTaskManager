//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "SyncService.h"
#import "STMTask.h"


@implementation SyncService {

}

+ (instancetype) sharedInstance
{
    static dispatch_once_t dbAccessOnceToken;
    static id sharedInstance;
    dispatch_once(&dbAccessOnceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)addTaskWithName:(NSString *)name successFullBlock:(void (^)(STMTask *))successFullBlock failureBlock:(void (^)(NSError *err))failureBlock {

}

- (void)markAsCompletedTaskWithId:(NSString *)uid successFullBlock:(void (^)())block failureBlock:(void (^)(NSError *))block1 {

}

- (void)reorderTaskWithId:(NSString *)uid toIndex:(int)index1 successFullBlock:(void (^)())block failureBlock:(void (^)(NSError *))block1 {

}


@end