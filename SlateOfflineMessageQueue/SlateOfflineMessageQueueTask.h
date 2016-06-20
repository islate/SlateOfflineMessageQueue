//
//  OfflineMassageQueueTask.h
//  OfflineMessageQueue
//
//  Created by Xiangjian Meng on 15/5/20.
//  Copyright (c) 2015年 islate. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^SerializationBlock)(id);

@protocol TaskSerializingProtocol <NSObject>

@optional

// 反序列化userInfo
- (id)taskUserInfoWithSerializedObject:(id)object;

// 序列化userInfo
- (id)serializingObjectWithTaskUserInfo:(id)userInfo;

@end


@interface SlateOfflineMessageQueueTask : NSObject <TaskSerializingProtocol>

- (instancetype)initWithIdentifier:(NSString *)identifier
                          userInfo:(id)userInfo;

// 标志task
@property (nonatomic, strong) NSString *identifier;

// 自定义信息
@property (nonatomic, strong) id userInfo;

@end
