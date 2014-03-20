//
//  STMTask.h
//  SimpleTaskManager
//
//  Created by Marek M on 10.03.2014.
//  Copyright (c) 2014 Tomato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface STMTask : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSNumber * index;

@end
