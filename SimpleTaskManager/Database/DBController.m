//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DBController.h"


@implementation DBController {

}

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    self = [super init];
    if (self) {
        _context = context;
    }

    return self;
}

- (instancetype)initWithParentController:(DBController *)parentController {
    self = [super init];
    if (self) {
        _parentController = parentController;

        NSManagedObjectContext* parentContext = parentController.context;
        if(parentContext){
            _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_context setParentContext:parentContext];
        }
    }

    return self;
}

- (instancetype)initWithContext:(NSManagedObjectContext *)context parentController:(DBController *)parentController {
    self = [super init];
    if (self) {
        _context = context;
        _parentController = parentController;
    }

    return self;
}

@end