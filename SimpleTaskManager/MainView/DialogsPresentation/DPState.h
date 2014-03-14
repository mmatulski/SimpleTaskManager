//
//  DialogsPresentationState.h
//  SimpleTaskManager
//
//  Created by Marek M on 14.03.2014.
//  Copyright (c) 2014 Tomato. All rights reserved.
//

#ifndef SimpleTaskManager_DialogsPresentationState____FILEEXTENSION___
#define SimpleTaskManager_DialogsPresentationState____FILEEXTENSION___

typedef NS_ENUM(NSInteger , DPState) {
    DPStateNormal,
    DPStateNewTaskDialogOpened,
    DPStateNewTaskDialogOpeningStarted, //user can open it finally or resign
    DPStateNewTaskDialogOpeningAnimating,
    DPStateNewTaskDialogClosingAnimating,
};

#endif
