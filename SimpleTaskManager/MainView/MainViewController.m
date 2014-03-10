//
//  MainViewController.m
//  SimpleTaskManager
//
//  Created by Marek M on 08.03.2014.
//  Copyright (c) 2014 Tomato. All rights reserved.
//

#import "MainViewController.h"
#import "AnimationsHelper.h"
#import "DBAccess.h"
#import "DBController.h"
#import "STMTask.h"

NSString * const kCellIdentifier = @"CellIdentifier";

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self prepareDBController];
    [self prepareFetchedResultsController];
}

- (void)prepareDBController {
    self.dbController = [[DBAccess sharedInstance] mainQueueController];
}

- (void)prepareFetchedResultsController {

    NSFetchRequest *fetchRequest = [self.dbController createFetchingTasksRequestWithBatchSize:20];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                managedObjectContext:self.dbController.context sectionNameKeyPath:nil
                                                           cacheName:@"Root"];
    self.fetchedResultsController.delegate = self;

    NSError *err = nil;
    if(![self.fetchedResultsController performFetch:&err]){
        DDLogError(@"prepareFetchedResultsController performFetch failed %@", [err localizedDescription]);
    }
}

- (IBAction)addTask:(id)sender {
    [self showAddTaskDialog];
}

- (void)showAddTaskDialog {
    self.addTaskDialog.hidden = false;
    [self.addTaskDialog.superview bringSubviewToFront:self.addTaskDialog];
}

- (IBAction)confirmAddingTask:(id)sender {

    self.addTaskDialog.hidden = true;
    [self.tableView.superview bringSubviewToFront:self.tableView];

    DBController *dbController = [DBAccess createBackgroundController];
    [dbController addTaskWithName:@"Go to sleep" successFullBlock:^(STMTask *task) {
        DDLogInfo(@"SUCCESS");
    } failureBlock:^(NSError *err) {
        DDLogError(@"FAILED");
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path {
    STMTask * task = [self.fetchedResultsController objectAtIndexPath:path];
    if(task){
        cell.textLabel.text = [NSString stringWithFormat:@"[%d] %@", [[task index] intValue] , task.name];
        cell.detailTextLabel.text = task.uid;
    }
}

#pragma mark - UITableViewDelegate methods

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id  sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    }

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
