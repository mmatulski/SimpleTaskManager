//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingleOperation.h"


@interface ReorderTaskOperation : SingleOperation

@property(nonatomic, copy) NSString *taskUid;
@property(nonatomic) int targetIndex;

- (instancetype)initWithTaskUid:(NSString *)taskUid targetIndex:(int)targetIndex;

@end