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

@implementation MainTableController {

}

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.draggedItemModel = nil;
        self.tableView = tableView;

        self.dataSource = [[MainTableDataSource alloc] initWithTableView:self.tableView];
        self.tableView.delegate = self;

        [self addLongPressRecognizer];
    }

    return self;
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

@end