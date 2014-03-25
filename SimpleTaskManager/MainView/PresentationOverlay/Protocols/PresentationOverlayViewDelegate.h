//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PresentationOverlayViewDelegate <NSObject>

-(void) theNewTaskDialogOpened;
-(void) theNewTaskDialogClosed;
-(void) userWantsToSaveTheNewTask:(NSString *) taskName;

@end