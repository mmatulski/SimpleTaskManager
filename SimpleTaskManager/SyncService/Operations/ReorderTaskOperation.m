//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "ReorderTaskOperation.h"


@implementation ReorderTaskOperation {

}

- (instancetype)initWithTaskUid:(NSString *)taskUid targetIndex:(int)targetIndex {
    self = [super init];
    if (self) {
        self.taskUid = taskUid;
        self.targetIndex = targetIndex;
    }

    return self;
}

@end