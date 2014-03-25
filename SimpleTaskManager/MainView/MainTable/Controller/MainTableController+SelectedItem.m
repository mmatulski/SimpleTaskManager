//
// Created by Marek M on 15.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableController+SelectedItem.h"
#import "STMTaskModel.h"
#import "MainTableDataSource.h"
#import "AppMessages.h"
#import "STMTask.h"
#import "MainViewConsts.h"


@implementation MainTableController (SelectedItem)

- (BOOL) isAnyTaskSelected {
    return self.selectedTaskModel != nil;
}

- (BOOL)isSelectedTaskShownAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *sel = [self indexPathForSelectedTask];
    return [indexPath isEqual:sel];
}

/*
    returns indexpath for item which is set as selected in this object
    it can be different value than tableView.indexPathForSelectedRow
    because selected item could not be refreshed yet for selected row
 */
- (NSIndexPath *)indexPathForSelectedTask {
    return [self.dataSource indexPathForTaskModel:self.selectedTaskModel];
    //return self.tableView.indexPathForSelectedRow;
}

- (BOOL)isSelectedModelStillAvailable {
    return [self.dataSource doesTaskForModelStillExistInFetchedResultsControllerData:self.selectedTaskModel];
}

- (void)refreshSelectedItemBecauseTableHasBeenReloaded {
    if(self.selectedTaskModel){
        if ([self isSelectedModelStillAvailable]) {
            NSIndexPath *selectedIndexPath = [self.dataSource indexPathForTaskModel:self.selectedTaskModel];
            [self.tableView selectRowAtIndexPath:selectedIndexPath animated:false scrollPosition:kDefaultTableScrollPositionWhenItemSelected];
            [self informDelegateAboutCurrentSelectedTaskFrame];
        } else {
            [self cancelSelectionAnimated:false];
            [AppMessages showError:@"Task has been closed by someone else"];
        }
    }
}

- (void)informDelegateAboutCurrentSelectedTaskFrame {
    CGRect selectedTaskFrame = [self selectedTaskFrame];
    if (!CGRectIsNull(selectedTaskFrame) &&
            !CGRectIsEmpty(selectedTaskFrame) &&
            !CGRectIsInfinite(selectedTaskFrame)) {
        [self.delegate selectedTaskFrameChanged:selectedTaskFrame];
    } else {
        DDLogWarn(@"selected frame is not valid");
    }
}

#pragma mark - Frames estimations

/*
    returns frame of selected cell (if selected, otherwise returns CGRectNull)
    frame is related to UIWindow
 */
-(CGRect) selectedTaskFrame{
    if([self isAnyTaskSelected]){
        return [self frameForCellAtIndexPath:[self indexPathForSelectedTask]];
    }

    return CGRectNull;
}

#pragma mark -

- (void)selectedTaskCompletedByUser {
    [self.dataSource taskCompleted];

    NSIndexPath * selectedIndexPath = [self indexPathForSelectedTask];
    if(selectedIndexPath){
        DDLogWarn(@"task has been completed but it is still available in datasource. "
                "Possible reason is that datasrouce is paused for refreshing gui [%d].", self.dataSource.paused);
        // we have to wait for sync end and then cell will disappear after table reload
        self.selectedTaskModel = nil;
        [self.tableView reloadData];
    } else {
        self.selectedTaskModel = nil;
    }
}

#pragma mark - Selecting and Deselecting tasks

- (void)setSelectedTaskAtForIndexPath:(NSIndexPath *)indexPath {
    if(indexPath){
        STMTask *task = [self.dataSource taskForIndexPath:indexPath];
        if(task){
            self.selectedTaskModel = [[STMTaskModel alloc] initWitEntity:task];
            [self.delegate taskHasBeenSelected];
        }
    }
}

- (void)changeSelectedTaskToAnotherOneAtIndexPath:(NSIndexPath *)anotherIndexPath{

    if(anotherIndexPath){
        STMTask *task = [self.dataSource taskForIndexPath:anotherIndexPath];
        if(task){
            self.selectedTaskModel = [[STMTaskModel alloc] initWitEntity:task];
            [self.delegate anotherTaskHasBeenSelected];
        }
    }
}

- (void)cancelSelectionAnimated:(BOOL) animated {
    NSIndexPath * selectedIndexPath = [self indexPathForSelectedTask];
    if(selectedIndexPath){
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:animated];
    }
    self.selectedTaskModel = nil;
    [self.delegate taskHasBeenUnselected];
}

@end