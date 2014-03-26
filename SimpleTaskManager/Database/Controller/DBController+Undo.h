//
// Created by Marek M on 16.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBController.h"

@interface DBController (Undo)

- (void)beginUndo;

- (void)endUndo;

- (void)undo;

- (void)addUndoManager;

@end