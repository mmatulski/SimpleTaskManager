//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBController.h"

@interface DBController (FastSync)
- (void)fast_sync_AddedTasks:(NSArray *)addedTasks removedTasks:(NSArray *)removedTasks renamedTasks:(NSArray *)renamedTasks reorderedTasks:(NSArray *)reorderedTasks successFullBlock:(void (^)(id))successFullBlock failureBlock:(void (^)(NSError *))failureBlock;
@end