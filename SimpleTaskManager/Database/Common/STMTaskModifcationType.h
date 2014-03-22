//
//  STMTaskAction.h
//  SimpleTaskManager
//
//  Created by Marek M on 21.03.2014.
//  Copyright (c) 2014 Tomato. All rights reserved.
//

#ifndef SimpleTaskManager_STMTaskAction____FILEEXTENSION___
#define SimpleTaskManager_STMTaskAction____FILEEXTENSION___

typedef NS_ENUM(NSUInteger , STMTaskModificationType){
    STMTaskModificationTypeNoChanges,
    STMTaskModificationTypeAdded,
    STMTaskModificationTypeRemoved,
    STMTaskModificationTypeRenamed,
    STMTaskModificationTypeReordered,
};

#endif
