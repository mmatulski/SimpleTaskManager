//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableController+SelectedItem.h"
#import "STMTask.h"
#import "STMTaskModel.h"
#import "DBController.h"
#import "MessagesHelper.h"


@implementation MainTableController (SelectedItem)

- (void)showOptionsForItemAtIndexPath:(NSIndexPath *)indexPath taskModel:(STMTaskModel *) taskModel{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(cell){
        [self.delegate showOptionsForTaskModel:taskModel representedByCell:cell];
    } else {
        self.selectedItemModel = nil;
    }
}

- (void)hideOptionsForItemAtIndexPath:(NSIndexPath *)indexPath taskModel:(STMTaskModel *) taskModel{
    [self.delegate closeTaskOptionsForTaskModel:taskModel];
}

-(void) updateOptionsPositionForItemAtIndexPath:(NSIndexPath *)indexPath taskModel:(STMTaskModel *) taskModel{
    [self.delegate updatePositionOfOptionsForTaskModel:taskModel becauseItWasScrolledBy:self.scrollOffsetWhenItemWasSelected - self.tableView.contentOffset.y];
}

- (NSIndexPath *)indexPathForSelectedItem {
    if(!self.selectedItemModel){
        return nil;
    }

    return [self indexPathForTaskModel:self.selectedItemModel];
}

- (void)updateSelectedItemVisibility {
    if(self.selectedItemModel){
       self.selectedItemModel = nil;

       [MessagesHelper showMessage:@"Tasks has been synced."];
    }
}

- (void)emergencyCancelSelection {
    self.selectedItemModel = nil;

    [MessagesHelper showMessage:@"Task was changed by someone else ..."];
}

@end