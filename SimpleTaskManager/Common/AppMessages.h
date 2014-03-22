//
//  AppMessages.h
//
//  Created by Marek M on 08.10.2013.
//  Copyright (c) 2013 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonActivityView.h"

@interface AppMessages : NSObject <UIAlertViewDelegate>

+(void) showMessage:(NSString*) message;
+(void) showError:(NSString*) message;
+(void) showActivity;
+(void) showCancelableActivityForDelegate:(id<CommonActivityViewDelegate>) delegate;
+(void) closeActivity;

@end
