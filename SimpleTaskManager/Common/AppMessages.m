//
//  AppMessages.m
//
//  Created by Marek M on 08.10.2013.
//  Copyright (c) 2013 Tomato. All rights reserved.
//

#import "AppMessages.h"

static CommonActivityView * activityView;
static NSTimer* timer;

#define DELAY_FOR_ACTIVITY_SHOWING 0.8

@implementation AppMessages

+(void) showMessage:(NSString*) message{
    if ([NSThread isMainThread]) {
        [self showViewWithTitle:nil andMessage:message];
    } else {
        runOnMainThread(^{
            [self showViewWithTitle:nil andMessage:message];
        });
    }
}

+(void) showError:(NSString*) message{
    if ([NSThread isMainThread]) {
        [self showViewWithTitle:__(@"Error") andMessage:message];
    } else {
        runOnMainThread(^{
            [self showViewWithTitle:__(@"Error") andMessage:message];
        });
    }
}

+(void) showActivity{
    [self showActivityDialogCancelable:false forDelegate:nil];
}

+(void) showCancelableActivityForDelegate:(id<CommonActivityViewDelegate>) delegate{
    [self showActivityDialogCancelable:true forDelegate:delegate];
}

+(void) showActivityDialogCancelable:(BOOL) cancelable forDelegate:(id<CommonActivityViewDelegate>) delegate{
    if (activityView) {
        if ([activityView isShown]) {
            DDLogWarn(@"activityView is already shown");
            return;
        } else {
            activityView = nil;
        }
    }
    
    if ([NSThread isMainThread]) {
        activityView = [[CommonActivityView alloc] initCancelable:cancelable withDelegate:delegate];
        [self queueDelayedShow];
    } else {
        runOnMainThread(^{
            activityView = [[CommonActivityView alloc] initCancelable:cancelable withDelegate:delegate];
            [self queueDelayedShow];
        });
    }
}

+(void) queueDelayedShow{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:DELAY_FOR_ACTIVITY_SHOWING target:self selector:@selector(delayedShow) userInfo:nil repeats:false];
}

+(void) delayedShow{
    [activityView show];
}

+(void) closeActivity{
    [timer invalidate];
    
    if ([NSThread isMainThread]) {
        [activityView close];
        activityView = nil;
    } else {
        runOnMainThread(^{
            [activityView close];
            activityView = nil;
        });
    }
    
}

+(void) showViewWithTitle:(NSString*) title andMessage:(NSString*) message{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

}

- (void)alertViewCancel:(UIAlertView *)alertView {

}

@end
