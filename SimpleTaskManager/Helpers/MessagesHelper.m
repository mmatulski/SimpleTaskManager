//
// Created by Marek M on 19.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MessagesHelper.h"


@implementation MessagesHelper {

}
+ (void)showMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alert show];
}

@end