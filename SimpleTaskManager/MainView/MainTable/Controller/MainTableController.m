//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableController.h"
#import "DragAndDropHandler.h"
#import "MainTableController+SelectedItem.h"
#import "MainTableController+DragAndDrop.h"
#import "STMTaskModel.h"
#import "MainTableDataSource.h"
#import "MainTableConsts.h"
#import "MainViewConsts.h"
#import "STMTask.h"
#import "TaskTableViewCell.h"

@implementation MainTableController {

}

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        _scrollPositionWhenSelectingItem = kDefaultTableScrollPositionWhenItemSelected;

        self.draggedItemModel = nil;
        self.tableView = tableView;

        self.dataSource = [[MainTableDataSource alloc] initWithTableView:self.tableView];
        self.tableView.delegate = self;

        [self addLongPressRecognizer];
        [self prepareEmptyFooterView];
    }

    return self;
}

- (void)prepareEmptyFooterView {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 60.0,100)];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
}

- (DragAndDropHandler *)dragAndDropHandler {
    if(!_dragAndDropHandler){
        [self prepareDragAndDropHelper];
    }

    return _dragAndDropHandler;
}


- (void)prepareDragAndDropHelper {
    self.dragAndDropHandler = [[DragAndDropHandler alloc] initWithDraggingSpace:[self.delegate viewForTemporaryViewsPresentation]];
}

-(CGRect) frameForCellAtIndexPath:(NSIndexPath *) indexPath{
    if(!indexPath){
        return CGRectNull;
    }

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(cell){
        UIView * parentViewOfCell = cell.superview;
        return [parentViewOfCell convertRect:cell.frame toView:nil];
    } else {
        UITableViewCell *anyVisibleCell = [[self.tableView visibleCells] firstObject];
        if(anyVisibleCell){
            NSIndexPath *visibleCellIndexPath = [self.tableView indexPathForCell:anyVisibleCell];
            NSInteger rowDiff = [indexPath row] - [visibleCellIndexPath row];
            CGFloat yDiff = rowDiff * kCellDefaultHeight;
            UIView * parentViewOfCell = anyVisibleCell.superview;
            CGRect cellFrameRelatingToTheWindows = [parentViewOfCell convertRect:anyVisibleCell.frame toView:nil];
            cellFrameRelatingToTheWindows.origin.y += yDiff;
            return  cellFrameRelatingToTheWindows;
        }

    }

    return CGRectNull;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellDefaultHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if([self isAnyTaskSelected]){
        if([self isSelectedTaskShownAtIndexPath:indexPath]){
            [self cancelSelectionAnimated:true];
        } else {
            //need to deselect task
            [self changeSelectedTaskToAnotherOneAtIndexPath:indexPath];
        }
    } else {
        [self setSelectedTaskAtForIndexPath:indexPath];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if([self isAnyTaskSelected]){
        [self informDelegateAboutCurrentSelectedTaskFrame];
    }
}

- (void)disableDataChangesListening:(BOOL)syncing {

    self.dataSource.paused = syncing;

    if(!syncing){
        if (self.selectedTaskModel) {
            [self refreshSelectedItemBecauseTableHasBeenReloaded];
        }

        if(self.draggedItemModel){
            [self refreshDraggedItemBecauseTableHasBeenReloaded];
        }
    }
}

//- (void)scrollToShowTaskModel:(STMTaskModel *)model {
//    if(model){
//        if ([self.dataSource doesTaskForModelStillExistInFetchedResultsControllerData:model]) {
//            NSIndexPath *indexPath = [self.dataSource indexPathForTaskModel:model];
//            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:kDefaultTableScrollPositionWhenItemSelected animated:false];
//        }
//    }
//}
//
//- (STMTaskModel *)modelForCellAtMiddleScrollPosition {
//
//    NSIndexPath *indexPathAtCenter= [self indexPathForCellAtMiddlePoint];
//
//    if(indexPathAtCenter){
//        STMTask*  task = [self.dataSource taskForIndexPath:indexPathAtCenter];
//        STMTaskModel* modelAtMiddlePoint = [[STMTaskModel alloc] initWitEntity:task];
//        return modelAtMiddlePoint;
//    }
//
//    return nil;
//}
//
//- (NSIndexPath *)indexPathForCellAtMiddlePoint {
//    CGFloat middleY = self.tableView.contentOffset.y + self.tableView.frame.size.height / 2.0;
//    CGFloat middleX = self.tableView.frame.size.width / 2.0;
//    NSIndexPath *indexPathAtCenter = [self.tableView indexPathForRowAtPoint:CGPointMake(middleX, middleY)];
//    return indexPathAtCenter;
//}

- (void)handleMemoryWarning {
    //TODO clean fetched cache
}

-(void) showNewTask:(STMTask *) task{
    STMTaskModel *taskModel = [[STMTaskModel alloc] initWitTask:task];
    if(taskModel){
        [self highlightCellForTaskModel:taskModel];
    } else {
        [self.dataSource reloadDataSourceAndTable];
    }
}

-(void) highlightCellForTaskModel:(STMTaskModel *) model{
    NSIndexPath *indexPath = [self.dataSource indexPathForTaskModel:model];
    if(indexPath){
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:true];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        TaskTableViewCell *taskCell = MakeSafeCast(cell, [TaskTableViewCell class]);
        [taskCell blinkCell];
    }
}


@end