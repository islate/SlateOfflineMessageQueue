//
//  OfflineMessageQueue.m
//  OfflineMessageQueue
//
//  Created by Xiangjian Meng on 15/5/20.
//  Copyright (c) 2015年 islate. All rights reserved.
//

#import "SlateOfflineMessageQueue.h"
#import "SlateReachability.h"
#import <UIKit/UIKit.h>

@implementation SlateOfflineMessageQueue
{
    NSString *currentQueueId;
    NSMutableArray *taskArray;
    NSOperationQueue *queue;

    BOOL currentNetworkState; // 记录开始网络连通状态
}

+ (instancetype)sharedQueue
{
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startQueueWithName:(NSString *)queueId
{
    currentNetworkState = ![self isNetworkBroken];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkUpdate) name:SlateReachabilityDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveUncompletedTask) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveUncompletedTask) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    currentQueueId = queueId;
    
    if (!taskArray)
    {
        NSString *filePath = [self tasksfilePathWithQueueId:queueId];
        NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
        array = [self taskArrayWithFileDataArray:array];
        if (array)
        {
            taskArray = [[NSMutableArray alloc] initWithArray:array];
        }
        else
        {
            taskArray = [[NSMutableArray alloc] init];
        }
    }
    
    if (queue == nil)
    {
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
    }
    
    if (![self isNetworkBroken])
    {
        [self doStartMessageQueue];
    }
}

- (void)addTaskToQueueWithTask:(SlateOfflineMessageQueueTask *)task
{
    if ([task isKindOfClass:[SlateOfflineMessageQueueTask class]])
    {
        [taskArray addObject:task];
        
        if (![self isNetworkBroken])
        {
            [self createOperationWithTask:task];
        }
    }
}

- (void)synchronize
{
    [self saveUncompletedTask];
}

- (void)enumerateUndoneTasksWithBlock:(void(^)(SlateOfflineMessageQueueTask *task, NSUInteger idx, BOOL *stop))block
{
    if ([taskArray count] > 0)
    {
        [[taskArray copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (obj && [obj isKindOfClass:[SlateOfflineMessageQueueTask class]])
            {
                if (block)
                {
                    block(obj,idx,stop);
                }
            }
        }];
    }
}

- (void)removeUndoneTask:(SlateOfflineMessageQueueTask *)task
{
    if (taskArray)
    {
        [taskArray removeObject:task];
    }
}

- (void)removeUndoneTaskWithIdentifier:(NSString *)identifier
{
    if (taskArray)
    {
        for (id obj in [taskArray copy])
        {
            if ([obj isKindOfClass:[SlateOfflineMessageQueueTask class]])
            {
                SlateOfflineMessageQueueTask *task = (SlateOfflineMessageQueueTask *)obj;
                if ([task.identifier isEqualToString:identifier])
                {
                    [taskArray removeObject:task];
                    break;
                }
            }
        }
    }
}

- (void)handleTask:(SlateOfflineMessageQueueTask *)task complete:(void (^)(BOOL))block
{
    ;
}

#pragma mark -
#pragma mark Private Method

- (void)handleTask:(SlateOfflineMessageQueueTask *)task
{
    [self handleTask:task complete:^(BOOL success) {
        if (success)
        {
            if (task)
            {
                [taskArray removeObject:task];
            }
        }
    }];
}

- (void)createOperationWithTask:(SlateOfflineMessageQueueTask *)task
{
    if (queue)
    {
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(handleTask:) object:task];
        [queue addOperation:operation];
    }
}

- (void)doStartMessageQueue
{
    //确保是队列里面是空的
    [queue cancelAllOperations];
    
    if ([taskArray count] > 0)
    {
        for (SlateOfflineMessageQueueTask *task in taskArray)
        {
            [self createOperationWithTask:task];
        }
    }
}

- (NSDictionary *)taskDictionaryWithTask:(SlateOfflineMessageQueueTask *)task
{
    if (task.identifier)
    {
        id userInfo = task.userInfo?:@"";
        if ([task respondsToSelector:@selector(serializingObjectWithTaskUserInfo:)])
        {
            userInfo = [task serializingObjectWithTaskUserInfo:task.userInfo];
        }
        return @{task.identifier:@{@"userInfo":userInfo,@"class":NSStringFromClass([task class])}};
    }
    return nil;
}

- (NSArray *)taskArrayWithFileDataArray:(NSArray *)array
{
    if ([array count] > 0)
    {
        NSMutableArray *arr = [NSMutableArray new];
        
        for (NSDictionary *dict in array)
        {
            NSArray *allkeys = [dict allKeys];
            if ([allkeys count] > 0)
            {
                NSString *identifier = [allkeys firstObject];
                id customDict = dict[identifier];
                NSString *className = customDict[@"class"];
                NSString *userInfo = customDict[@"userInfo"];
                if (userInfo && className)
                {
                    Class class = NSClassFromString(className);
                    SlateOfflineMessageQueueTask *task = [[class alloc] init];
                    task.identifier = identifier;
                    task.userInfo = userInfo;
                    if ([task respondsToSelector:@selector(taskUserInfoWithSerializedObject:)])
                    {
                        task.userInfo = [task taskUserInfoWithSerializedObject:userInfo];
                    }
                    
                    if ([task isKindOfClass:[SlateOfflineMessageQueueTask class]])
                    {
                        [arr addObject:task];
                    }
                }
            }
        }
        
        if ([arr count] > 0)
        {
            return arr;
        }
    }
    
    return nil;
}

- (void)saveUncompletedTask
{
    if (taskArray)
    {
        NSMutableArray *array = [NSMutableArray new];
        for (SlateOfflineMessageQueueTask *task in taskArray)
        {
            NSDictionary *taskDict = [self taskDictionaryWithTask:task];
            if (taskDict)
            {
                [array addObject:taskDict];
            }
        }
        
        [array writeToFile:[self tasksfilePathWithQueueId:currentQueueId] atomically:YES];

    }
}

- (BOOL)isNetworkBroken
{
    return [[SlateReachability sharedReachability] isNetworkBroken];
}

- (void)netWorkUpdate
{
    if ([self isNetworkBroken])
    {
        currentNetworkState = NO;
        
        //断网
        if (queue)
        {
            [queue cancelAllOperations];
        }
        
        //断网的时候取消各种延时请求
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    else
    {
        //有网
        if (!currentNetworkState)
        {
            // 防止重复触发message queue，只有网络状态真正变化了才触发message queue
            currentNetworkState = YES;
            [self doStartMessageQueue];
        }
    }
}

- (NSString *)tasksfilePathWithQueueId:(NSString *)queueId
{
    NSArray         *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString        *cacheDirectoryPath = [paths objectAtIndex:0];
    NSFileManager   *fileManger = [NSFileManager defaultManager];
    
    // 创建父目录
    NSString *fatherPath = [cacheDirectoryPath stringByAppendingFormat:@"/OfflineMessageQueue"];
    
    if (![fileManger fileExistsAtPath:fatherPath])
    {
        [fileManger createDirectoryAtPath:fatherPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *path = [fatherPath stringByAppendingFormat:@"/%@", queueId];
    
    if (![fileManger fileExistsAtPath:path])
    {
        BOOL sucess = [fileManger createFileAtPath:path contents:nil attributes:nil];
        
        if (sucess)
        {
            ;
        }
    }
    
    return path;
}

@end
