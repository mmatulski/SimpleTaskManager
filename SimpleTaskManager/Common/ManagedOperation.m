//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "ManagedOperation.h"


@implementation ManagedOperation {

}

-(id)init{
    self = [super init];
    if (!self)
        return nil;

    self.done = false;
    return self;
}

- (BOOL)isConcurrent
{
    return YES;
}

-(BOOL)isExecuting{
    return !self.done;
}


-(BOOL)isFinished{

    return self.done;
}


- (void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];

    self.done = true;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end