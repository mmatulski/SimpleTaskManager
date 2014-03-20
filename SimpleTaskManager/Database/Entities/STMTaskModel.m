//
// Created by Marek M on 18.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "STMTaskModel.h"
#import "STMTask.h"


@implementation STMTaskModel {

}

- (instancetype)initWithName:(NSString *)name uid:(NSString *)uid index:(NSNumber *)index {
    self = [super init];
    if (self) {
        self.name = name;
        self.uid = uid;
        self.index = index;
    }

    return self;
}

- (instancetype)initWitEntity:(STMTask *)task {
    self = [super init];
    if (self) {
        self.name = task.name;
        self.uid = task.uid;
        self.index = task.index;
        self.objectId = task.objectID;
    }
    return self;
}

@end