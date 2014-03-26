SimpleTaskManager
=================
<br>
This is very simple TODO app.<br>
It is written in Objective C, for iPhone only.

###Available features:

* User can add new task 
* User can change tasks order
* User can set task as completed (it will just remove task from db)

###Quick manual
* To add new task tap on the button with '+' or use pan gesture from the right edge of the screen
    <br>(When new task dialog will be shown type the name and then use pan gesture on dialog to the left edge to save it or to the right to close without saving)
* To change tasks order use long-press gesture on the cell and then move it to expected position
* To mark task as complete select task cell and then the possible options will be shown.
* Red background of "Generator" label means that sync is being processed now.

##Traffic generator
Every 20 seconds the random traffic simulating remote sync is generated.
This traffic contains changes for 25% of already added tasks (33.3% are renamed, 33.3% are reordered and rest are removed).
<br>
The traffic also contains new added tasks. The number of them is 101% of the removed items. To ensure that the number of tasks will be growing the number of added tasks is always greater than the removed ones.

To turn off generator just change "Generator" switch state to off (switch is at the top of application window).
<br> 
To change default generator settings go to:<br>
[SimpleTaskManager/SyncService/SyncingLegs/Remote/RemoteActionsHandlerStub.m](SimpleTaskManager/SyncService/SyncingLegs/Remote/RemoteActionsHandlerStub.m) 
<br>
and change init method:

```
(id)init {
    self = [super init];
    if (self) {
        _timerInterval = 20.0;
        _changedItemsShare = 0.25;
        _increaseRate = 1.01; //no less than 1
        _renameItemsShare = 0.33;
        _reorderedItemsShare = 0.33;
    }

    return self;
}
```

####Additional traffic generator
There is one more generator which is triggered in the half time between basic traffic generations.
This additional generator do the same actions as the basic one.
The difference is that it uses data that are not fresh. These data are the same data which was changed later in basic traffic generator but in the previous cycle. Data are passed between generator in serialized JSON form.

##Merging approach
The simplest approach is used. In this moment no additional fields are designed for data merges handling.
That's why if Task still exists in db any request for it will be processed.
The only limitation is that requests are processed synchronously - if user was first then his request will be performed before syncing.
<br>






    
