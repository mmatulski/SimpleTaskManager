//
// Created by Marek M on 17.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "SingleOperation.h"
#import "STMTask.h"
#import "SingleOperationDelegate.h"


@implementation SingleOperation {

}

- (id)init {
    self = [super init];
    if (self) {
        self.success = false;
    }

    return self;
}

-(void) finishedSuccessFully{

    if(self.isCancelled){
       return;
    }

    self.success = true;
    self.error = nil;

    [self.delegate operationFinished:self];

    [self finish];

}

-(void) failedWithError:(NSError *) error{
    if(self.isCancelled){
        return;
    }

    self.error = error;
    self.success = false;

    [self.delegate operationFinished:self];

    [self finish];
}

- (void)performAdequateBlock {
    if (self.success) {
        if(self.successFullBlock){
            self.successFullBlock(nil);
        }
    } else {
        if(self.failureBlock){
            self.failureBlock(self.error);
        }
    }
}

@end