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

//- (void)setSelectedItemModel:(STMTaskModel *)selectedItemModel animated:(BOOL) animated{
//
//    if(![_selectedItemModel.objectId isEqual:selectedItemModel.objectId]){
//        if(selectedItemModel){
//            NSIndexPath *indexPath = [self.dataSource indexPathForTaskModel:selectedItemModel];
//            [self showOptionsForItemAtIndexPath:indexPath taskModel:selectedItemModel animated:animated];
//        }
//
//        if(_selectedItemModel && !selectedItemModel){
//            NSIndexPath *selectedIndexPath = [self.dataSource indexPathForTaskModel:_selectedItemModel];
//            [self hideOptionsForItemAtIndexPath:selectedIndexPath taskModel:_selectedItemModel];//TODO animated
//        }
//
//        self.scrollOffsetWhenItemWasSelected = self.tableView.contentOffset.y;
//
//        _selectedItemModel = selectedItemModel;
//
//        self.stateController.taskSelected = _selectedItemModel != nil;
//    }
//}

//- (void)setSelectedItemModel:(STMTaskModel *)selectedItemModel {
//    [self setSelectedItemModel:selectedItemModel animated:true];//TODO default should be false
//}

//- (void)deselectTaskModel:(STMTaskModel *)taskModel {
//    NSIndexPath *selectedIndexPath = [self indexPathForSelectedTask];
//    if(selectedIndexPath){
//        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:true];
//    }
//
//    self.selectedItemModel = nil;
//}

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

//    NSIndexPath *selectedIndexPath = [self indexPathForSelectedTask];
//    if(selectedIndexPath && [selectedIndexPath isEqual:indexPath]){
//        [tableView deselectRowAtIndexPath:indexPath animated:true];
//        self.selectedItemModel = nil;
//    } else {
//        if(![self.stateController isSelectionAvailableNow]){
//            [tableView deselectRowAtIndexPath:indexPath animated:false];
//            [self.stateController showInfoThatActionsAreBlockedWhenSyncing];
//            return;
//        }
//
//        STMTask *task = [self.dataSource taskForIndexPath:indexPath];
//        if(task){
//            STMTaskModel *model = [[STMTaskModel alloc] initWitEntity:task];
//            self.selectedItemModel = model;
//        }
//    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if([self isAnyTaskSelected]){
        [self informDelegateAboutCurrentSelectedTaskFrame];
    }
}

- (void)disableDataChangesListening:(BOOL)syncing {

    self.dataSource.paused = syncing;

    if(!self.dataSource.paused){
        if (self.selectedTaskModel) {
            [self refreshSelectedItemBecauseTableHasBeenReloaded];
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

@end