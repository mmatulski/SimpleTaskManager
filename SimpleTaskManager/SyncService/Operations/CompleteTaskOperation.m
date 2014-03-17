//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "CompleteTaskOperation.h"


@implementation CompleteTaskOperation {

}

- (instancetype)initWithTaskUid:(NSString *)taskUid {
    self = [super init];
    if (self) {
        self.taskUid = taskUid;
    }

    return self;
}

@end