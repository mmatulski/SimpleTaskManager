//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "AppErrors.h"

NSString* const APPDOMAIN = @"STMDomain";

@implementation AppErrors {

}

+(NSError*) prepareErrorWithMessage: (NSString*) message andReason:(NSString*) reason andCode: (NSInteger) code {
    NSDictionary *userInfoDict = nil;
    if (reason) {
        userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:message,NSLocalizedDescriptionKey, reason, NSLocalizedFailureReasonErrorKey, nil];
    } else {
        userInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:message,NSLocalizedDescriptionKey, nil];
    }
    return [[NSError alloc] initWithDomain:APPDOMAIN code:code userInfo:userInfoDict];
}

+(NSError*) prepareErrorWithCode:(NSInteger) code{
    NSString* errorMessageForCode = [self messageForErrorCode:code];
    return [self prepareErrorWithMessage:errorMessageForCode andReason:nil andCode:code];
}

+(NSString*) messageForErrorCode:(NSInteger) code{
    NSString* result = nil;
    switch (code) {
        case ERROR_TASK_NOT_FOUND:
            return  __(@"Task not found");
        default:
            return __(@"Undefined error");
    }
}

@end