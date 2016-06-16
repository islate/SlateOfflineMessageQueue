//
//  OfflineMassageQueueTask.m
//  OfflineMessageQueue
//
//  Created by Xiangjian Meng on 15/5/20.
//  Copyright (c) 2015年 cn.com.modernmedia. All rights reserved.
//

#import "SlateOfflineMessageQueueTask.h"

@implementation SlateOfflineMessageQueueTask

- (instancetype)initWithIdentifier:(NSString *)identifier
                          userInfo:(id)userInfo
{
    self = [super init];
    if (self)
    {
        _identifier = identifier;
        _userInfo = userInfo;
    }
    return self;
}

@end
