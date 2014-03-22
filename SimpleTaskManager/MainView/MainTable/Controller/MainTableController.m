//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableController.h"
#import "STMTask.h"
#import "DragAndDropHandler.h"
#import "MainTableController+SelectedItem.h"
#import "MainTableController+DragAndDrop.h"
#import "STMTaskModel.h"
#import "MainTableDataSource.h"
#import "MainTableConsts.h"
#import "MainTableStateController.h"
#import "AppMessages.h"

@implementation MainTableController {

}

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.draggedItemModel = nil;
        self.tableView = tableView;

        self.dataSource = [[MainTableDataSource alloc] initWithTableView:self.tableView];
        self.tableView.delegate = self;

        [self prepareStateController];
        [self addLongPressRecognizer];
    }

    return self;
}

- (void)prepareStateController {
    self.stateController = [[MainTableStateController alloc] initWithMainTableController:self];
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

- (void)setSelectedItemModel:(STMTaskModel *)selectedItemModel {

    if(![_selectedItemModel.objectId isEqual:selectedItemModel.objectId]){
        if(selectedItemModel){
            NSIndexPath *indexPath = [self.dataSource indexPathForTaskModel:selectedItemModel];
            [self showOptionsForItemAtIndexPath:indexPath taskModel:selectedItemModel];
        }

        if(_selectedItemModel && !selectedItemModel){
            NSIndexPath *selectedIndexPath = [self.dataSource indexPathForTaskModel:_selectedItemModel];
            [self hideOptionsForItemAtIndexPath:selectedIndexPath taskModel:_selectedItemModel];
        }

        self.scrollOffsetWhenItemWasSelected = self.tableView.contentOffset.y;

        _selectedItemModel = selectedItemModel;

        self.stateController.taskSelected = _selectedItemModel != nil;
    }
}

- (void)handleMemoryWarning {
    //TODO clean fetched cache
}

- (void)deselectTaskModel:(STMTaskModel *)taskModel {
    NSIndexPath *selectedIndexPath = [self indexPathForSelectedItem];
    if(selectedIndexPath){
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:true];
    }

    self.selectedItemModel = nil;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellDefaultHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSIndexPath *selectedIndexPath = [self indexPathForSelectedItem];
    if(selectedIndexPath && [selectedIndexPath isEqual:indexPath]){
        [tableView deselectRowAtIndexPath:indexPath animated:true];
        self.selectedItemModel = nil;
    } else {
        if(![self.stateController isSelectionAvailabelNow]){
            [tableView deselectRowAtIndexPath:indexPath animated:false];
            [self.stateController showInfoThatActionsAreBlockedWhenSyncing];
            return;
        }

        STMTask *task = [self.dataSource taskForIndexPath:indexPath];
        if(task){
            STMTaskModel *model = [[STMTaskModel alloc] initWitEntity:task];
            self.selectedItemModel = model;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.selectedItemModel){
        NSIndexPath *selectedIndexPath = [self indexPathForSelectedItem];
        [self updateOptionsPositionForItemAtIndexPath:selectedIndexPath taskModel:self.selectedItemModel];
    }
}

- (void)refreshSelectedItemBecauseSyncHasBeenPerformed {
    if(self.selectedItemModel){
        NSIndexPath *selectedIndexPath = [self indexPathForSelectedItem];
        if(selectedIndexPath){
            [self.tableView selectRowAtIndexPath:selectedIndexPath animated:false scrollPosition:UITableViewScrollPositionMiddle];
            self.scrollOffsetWhenItemWasSelected = self.tableView.contentOffset.y;
            [self showOptionsForItemAtIndexPath:selectedIndexPath taskModel:self.selectedItemModel];
        } else {
            [self cancelSelection];
            [AppMessages showError:@"Task has been closed by remote side"];
        }


    }
}

@end