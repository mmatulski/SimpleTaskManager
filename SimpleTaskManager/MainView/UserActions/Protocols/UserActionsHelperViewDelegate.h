//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserActionsHelperViewDelegate <NSObject>

-(void) userWantsToSaveTheNewTask:(NSString *) taskName;

@end