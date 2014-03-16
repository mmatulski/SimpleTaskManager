//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMTask;

@protocol UserActionsHelperControllerDelegate <NSObject>

-(void) userWantsToDeselectTask:(STMTask *) task;

@end