//
// Created by Marek M on 20.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "NSError+Log.h"


@implementation NSError (Log)

-(void)log{
    NSString* reason = [self localizedFailureReason];
    if (reason) {
        DDLogError(@"ERROR: %@ (%@)",[self localizedDescription], reason);
    } else {
        DDLogError(@"ERROR: %@",[self localizedDescription]);
    }
}


-(void)log:(NSString*)msg{
    NSString* reason = [self localizedFailureReason];
    if (reason) {
        DDLogError(@"ERROR: %@",[NSString stringWithFormat:@"%@ %@(%@)", msg, [self localizedDescription], reason]);
    } else {
        DDLogError(@"ERROR: %@",[NSString stringWithFormat:@"%@ %@", msg, [self localizedDescription]]);
    }
}

@end