//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingleOperation.h"


@interface RenameOperation : SingleOperation

@property(nonatomic, copy) NSString *taskUid;
@property(nonatomic, copy) NSString *theNewName;

- (instancetype)initWithTaskUid:(NSString *)taskUid theNewName:(NSString *)theNewName;

@end