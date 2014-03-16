//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableController+TaskOptions.h"
#import "STMTask.h"


@implementation MainTableController (TaskOptions)

- (void)showOptionsForItemAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    STMTask *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate showOptionsForTask:task representedByCell:cell];
}

- (void)hideOptionsForItemAtIndexPath:(NSIndexPath *)indexPath {
    STMTask *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate closeTaskOptionsForTask:task];
}

-(void) updateOptionsPositionForItemAtIndexPath:(NSIndexPath *)indexPath{
    STMTask *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate updatePositionOfOptionsForTask:task becauseItWasScrolledBy:self.scrollOffsetWhenItemWasSelected - self.tableView.contentOffset.y];
}

@end