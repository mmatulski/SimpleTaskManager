//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableController+SelectedItem.h"
#import "STMTaskModel.h"
#import "MainTableDataSource.h"
#import "AppMessages.h"


@implementation MainTableController (SelectedItem)

- (void)showOptionsForItemAtIndexPath:(NSIndexPath *)indexPath taskModel:(STMTaskModel *)taskModel animated:(BOOL)animated {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(cell){
        [self.delegate showOptionsForTaskModel:taskModel representedByCell:cell animated:animated ];
    } else {
        DDLogWarn(@"showOptionsForItemAtIndexPath no cell found");
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

    return [self.dataSource indexPathForTaskModel:self.selectedItemModel];
}

- (void)updateSelectedItemVisibility {
    if(self.selectedItemModel){
       self.selectedItemModel = nil;

       [AppMessages showMessage:@"Tasks has been synced."];
    }
}

- (void)emergencyCancelSelection {
    self.selectedItemModel = nil;

    [AppMessages showMessage:@"Task was changed by someone else ..."];
}

- (void)cancelSelection {
    self.selectedItemModel = nil;
    NSIndexPath * selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if(selectedIndexPath){
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:false];
    }
}


@end