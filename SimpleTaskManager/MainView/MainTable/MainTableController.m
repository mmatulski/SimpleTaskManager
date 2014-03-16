//
// Created by Marek M on 12.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainTableController.h"
#import "DBController.h"
#import "DBAccess.h"
#import "STMColors.h"
#import "STMTask.h"
#import "DragAndDropHandler.h"
#import "MainTableController+TaskOptions.h"
#import "MainTableController+DragAndDrop.h"

NSString * const kCellIdentifier = @"CellIdentifier";
unsigned int const kDefaultBatchSize = 20;

@implementation MainTableController {

}

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.draggedIndexPath = nil;
        self.tableView = tableView;

        [self prepareDBController];
        [self prepareFetchedResultsController];

        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
        self.tableView.dataSource = self;
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

- (void)prepareDBController {
    self.dbController = [[DBAccess sharedInstance] mainQueueController];
}

- (void)prepareFetchedResultsController {

    NSFetchRequest *fetchRequest = [self.dbController createFetchingTasksRequestWithBatchSize:kDefaultBatchSize];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.dbController.context sectionNameKeyPath:nil
                                                                                   cacheName:@"Root"];
    self.fetchedResultsController.delegate = self;

    NSError *err = nil;
    if(![self.fetchedResultsController performFetch:&err]){
        DDLogError(@"prepareFetchedResultsController performFetch failed %@", [err localizedDescription]);
    }
}

- (void)prepareDragAndDropHelper {
    self.dragAndDropHandler = [[DragAndDropHandler alloc] initWithDraggingSpace:[self.delegate viewForTemporaryViewsPresentation]];
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath {
    if(![_selectedIndexPath isEqual:selectedIndexPath]){
        if(selectedIndexPath){
            [self showOptionsForItemAtIndexPath:selectedIndexPath];
        }

        if(_selectedIndexPath){
            [self hideOptionsForItemAtIndexPath:_selectedIndexPath];
        }

        self.scrollOffsetWhenItemWasSelected = self.tableView.contentOffset.y;

        _selectedIndexPath = selectedIndexPath;


    }
}

- (void)handleMemoryWarning {
    //TODO clean fetched cache
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path {

    NSIndexPath *pathToRequest = path;
    if(self.draggedIndexPath){
        if([self.draggedIndexPath row] >= [path row]){
            pathToRequest = [NSIndexPath indexPathForRow:(path.row + 1) inSection:path.section];
        }

        NSLog(@"configureCell zmniejszona %d %d", [path row], [pathToRequest row]);
    }

    STMTask * task = [self.fetchedResultsController objectAtIndexPath:pathToRequest];
    if(task){
        cell.backgroundColor = [STMColors cellBackgroundColor];
        cell.textLabel.textColor = [STMColors cellTextColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
        cell.textLabel.text = [NSString stringWithFormat:@"[%d] %@", [[task index] intValue] , task.name];
        cell.detailTextLabel.text = task.uid;
        cell.textLabel.backgroundColor = [STMColors cellBackgroundColor];
    }
}

- (void)addLongPressRecognizer {
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.longPressRecognizer.minimumPressDuration = 0.8; //seconds
    self.longPressRecognizer.delegate = self;

    [self.tableView addGestureRecognizer:self.longPressRecognizer];
}

#pragma mark UILongPressGestureRecognizer

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return NO;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return NO;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}


- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView: gestureRecognizer.view];

    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        DDLogInfo(@"Began");

        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        STMTask * task = [self.fetchedResultsController objectAtIndexPath:indexPath];
        if(task){
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

            self.draggedIndexPath = indexPath;

            DDLogInfo(@"-- row %d", [self.draggedIndexPath row]);

            [self disableTableGestureRecognizerForScrolling];

            CGPoint pointRelatedToWindow = [gestureRecognizer locationInView:nil];
            [self.dragAndDropHandler dragView:cell fromPoint:pointRelatedToWindow];

           [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        }
    } else if(gestureRecognizer.state == UIGestureRecognizerStateFailed || gestureRecognizer.state == UIGestureRecognizerStateCancelled){
        DDLogInfo(@"Failed | Cancelled");

        [self.dragAndDropHandler stopDragging];
        NSIndexPath *indexPath = self.draggedIndexPath;
        self.draggedIndexPath = nil;
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];


        [self enableTableGestureRecognizerForScrolling];
    } else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        DDLogInfo(@"Long chagned");
        CGPoint pointRelatedToWindow = [gestureRecognizer locationInView:nil];
        [self.dragAndDropHandler moveDraggedViewToPoint:pointRelatedToWindow];

        [self dropOrHideDraggedCellForPoint:point];

    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        DDLogInfo(@"Ended");

        [self.dragAndDropHandler stopDragging];
        NSIndexPath *indexPath = self.draggedIndexPath;
        self.draggedIndexPath = nil;
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        [self enableTableGestureRecognizerForScrolling];
    }
}

- (void)enableTableGestureRecognizerForScrolling {
   [self.tableView panGestureRecognizer].enabled = true;
}

- (void)disableTableGestureRecognizerForScrolling {
   [self.tableView panGestureRecognizer].enabled = false;
}

- (void)deselectTask:(STMTask *)task {
    if(self.selectedIndexPath){
        [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:true];
    }

    self.selectedIndexPath = nil;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if(self.selectedIndexPath && [self.selectedIndexPath isEqual:indexPath]){
        [tableView deselectRowAtIndexPath:indexPath animated:true];
        self.selectedIndexPath = nil;
    } else {
        self.selectedIndexPath = indexPath;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.selectedIndexPath){
        [self updateOptionsPositionForItemAtIndexPath:self.selectedIndexPath];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id  sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    int result = [sectionInfo numberOfObjects];
    if(self.draggedIndexPath){
        result--;
        DDLogInfo(@"result zmniejszony %d", result);
    }

    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}


#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                    arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                    arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {

        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:break;
        case NSFetchedResultsChangeUpdate:break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end