//
// Created by Marek M on 09.03.2014.
// Copyright (c) 2014 Tomato. All rights reserved.
//

#import "DBAccess.h"
#import "AppDelegate.h"
#import "DBController.h"


@implementation DBAccess {

    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

+ (instancetype) sharedInstance
{
    static dispatch_once_t dbAccessOnceToken;
    static id sharedInstance;
    dispatch_once(&dbAccessOnceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self prepareMasterController];
        [self prepareMainQueueController];
    }

    return self;
}

- (void)prepareMasterController {
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        NSManagedObjectContext* masterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [masterContext setPersistentStoreCoordinator:coordinator];

        _masterControllerOnBackground = [[DBController alloc] initWithContext:masterContext];
    }
}

- (void)prepareMainQueueController {
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        NSManagedObjectContext* mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [mainQueueContext setPersistentStoreCoordinator:coordinator];

        _controllerOnMainQueue = [[DBController alloc] initWithContext:mainQueueContext parentController:self.masterControllerOnBackground];
    }
}

/*
    Use this worker for storing data.
 */
+ (DBController *)createBackgroundWorker {

    DBController *mainController = [[DBAccess sharedInstance] controllerOnMainQueue];
    DBController *backgroundController = [[DBController alloc] initWithParentController:mainController];

    return backgroundController;
}

#pragma mark - Core Data stack

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SimpleTaskManager" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    AppDelegate *appDelegate = MakeSafeCast([UIApplication sharedApplication].delegate, [AppDelegate class]);
    NSURL *storeURL = [[appDelegate applicationDocumentsDirectory] URLByAppendingPathComponent:@"SimpleTaskManager.sqlite"];

    NSError *error = nil;

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        
        DDLogWarn(@"Unresolved error %@, %@", error, [error userInfo]);

        NSError *err;
        if([[NSFileManager defaultManager] removeItemAtURL:storeURL error:&err]){
            if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]){
                DDLogError(@"Removing db not resolved the problem - Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }

        } else {
            DDLogError(@"Can not remove old db error %@, %@", error, [error userInfo]);
            abort();
        }
    }

    return _persistentStoreCoordinator;
}

@end