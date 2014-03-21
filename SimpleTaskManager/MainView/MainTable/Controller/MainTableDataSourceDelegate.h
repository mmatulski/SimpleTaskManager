//
// Created by Marek M on 21.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STMTaskModel;

@protocol MainTableDataSourceDelegate <NSObject>

-(STMTaskModel *)taskBeingMoved;

-(NSIndexPath *) currentTargetIndexPathForItemBeingMoved;

@end