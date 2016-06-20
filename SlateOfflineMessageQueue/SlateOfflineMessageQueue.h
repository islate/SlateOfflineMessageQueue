//
//  OfflineMessageQueue.h
//  OfflineMessageQueue
//
//  Created by Xiangjian Meng on 15/5/20.
//  Copyright (c) 2015年 islate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlateOfflineMessageQueueTask.h"

@interface SlateOfflineMessageQueue : NSObject

// 子类重写此类方法创建单例对象
+ (instancetype)sharedQueue;

// 开启队列。应该最先调用。
- (void)startQueueWithName:(NSString *)name;

// 将任务加入队列
- (void)addTaskToQueueWithTask:(SlateOfflineMessageQueueTask *)task;

// 同步为完成任务进磁盘。
// 默认已经在app进入后台或者app关闭的情况下同步未完成的任务。使用者也可以在认为必要的时候调取此接口。
- (void)synchronize;

//=============================================================
// 以下是对未完成的任务进行操作

// 遍历所有未完成的task
- (void)enumerateUndoneTasksWithBlock:(void(^)(SlateOfflineMessageQueueTask *task, NSUInteger idx, BOOL *stop))block;

// 从未完成的任务中删除某个不想继续完成的task
- (void)removeUndoneTask:(SlateOfflineMessageQueueTask *)task;
- (void)removeUndoneTaskWithIdentifier:(NSString *)identifier;

// ============================================================
// 以下是需要子类化的方法
- (void)handleTask:(SlateOfflineMessageQueueTask *)task complete:(void (^)(BOOL success))block;

@end
