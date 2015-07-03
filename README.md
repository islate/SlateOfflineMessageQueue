# SlateOfflineMessageQueue

##项目简介

交互性的app经常会遇到app实时和服务器交互的场景。以收藏功能为例，用户会频繁点击收藏或取消收藏。而收藏状态本应该是实时和服务器同步的，但经常会遇到网络状况不稳或者断开网络的情况，导致不能实时同步收藏状态。如果遇到上述情况客户端不做任何处理的话，会导致用户体验不佳，用户无法进行收藏，如果假装用户收藏成功但并没有保存起来将来去与服务器同步的话，那么信息也必定会丢失。

离线队列就解决了上述问题，简述其功能：

* 用户触发了请求服务器的行为，将请求任务放进SlateOfflineMessageQueue，如果当前网络状况连通，SlateOfflineMessageQueue就会立刻触发该请求，如果服务器有了正确响应，则请求处理完毕，请求任务移除；如果服务器响应错误，或者没有响应，该请求任务就会被保存起来，待合适的时间继续进行请求。
* 如果用户触发了请求服务器的行为，将请求任务放进SlateOfflineMessageQueue中，当前网络处于非连通状态，那么SlateOfflineMessageQueue就会直接保存请求任务，待合适的时间继续进行请求。
* SlateOfflineMessageQueue还会监听网络状态的变化，如果当前网络状态由非连通变为连通状态，OfflineMessageQueue会自动重启所有保存下来的请求任务；如果当前网络状态由连通变为非连通，SlateOfflineMessageQueue会立刻保存当前还未完成的请求任务。

有了以上的保证，我们可以在UI上及时地对用户行为进行反馈，不需要等待服务器返回结果。因为只要将请求任务加进SlateOfflineMessageQueue，SlateOfflineMessageQueue会帮你完成后续工作。

##使用指南
OfflineMessageQueue组件主要由两个类组成：

	SlateOfflineMessageQueue类
	SlateOfflineMessageQueueTask类
由于OfflineMessageQueue要检测网络变化，所以依赖`SlateReachability`类。

如要使用，需要进行以下步骤：

* 将以上三个类拖进工程中。
* SlateOfflineMessageQueue不能直接使用（这个非常重要），必须子类化才可以使用。
* SlateOfflineMessageQueue子类在实现过程中，必须实现`+ (instancetype)sharedQueue;`及`- (void)handleTask:(SlateOfflineMessageQueueTask *)task complete:(void (^)(BOOL success))block;`方法，分别是创建单例实例和处理具体任务的方法。任务在处理完成之后，需要调用提供的block，将任务处理成功与否的状态传入。
* 子类化的SlateOfflineMessageQueue实例，在使用之前，必须先调用`- (void)startQueueWithName:(NSString *)name;`方法，以开启离线队列。**必须给这个队列一个名字**，与其他子类化队列作区分。该方法在全局中**只能调用一次**。
* 当需要处理请求任务时，先实例化一个SlateOfflineMessageQueueTask对象，将其加入离线队列，需要调用`- (void)addTaskToQueueWithTask:(SlateOfflineMessageQueueTask *)task;`方法。以后的事情，就交给SlateOfflineMessageQueue去处理吧。
* 在任何时候，你都可以调用SlateOfflineMessageQueue的`- (void)synchronize;`方法，来本地化你未完成的任务。当然，SlateOfflineMessageQueue会默认自动在app进入后台或者直接被关闭之前帮助你本地化任务，避免数据丢失。
* 你也可以使用我们提供好的`- (void)enumerateUndoneTasksWithBlock:(void(^)(SlateOfflineMessageQueueTask *task, NSUInteger idx, BOOL *stop))block;`方法来遍历所有目前尚未完成的任务。找出你认为不需要继续进行的任务将其删除，利用`- (void)removeUndoneTask:(SlateOfflineMessageQueueTask *)task;`或`- (void)removeUndoneTaskWithIdentifier:(NSString *)identifier;`方法。

####可选功能
SlateOfflineMessageQueueTask接受`TaskSerializingProtocol`协议，该协议包含两个方法：
	
	// 反序列化userInfo
	- (id)taskUserInfoWithSerializedObject:(id)object;

	// 序列化userInfo
	- (id)serializingObjectWithTaskUserInfo:(id)userInfo;

因为离线队列在特定情况下是要保存未完成任务到本地sandbox中的，所以通过这两个方法就可以控制对象序列化的行为，也就是说你可以控制userInfo以什么形式保存到本地，又可以以什么形式从本地读出。这样，你可以子类化SlateOfflineMessageQueueTask，重新实现此两个方法，就可以随心所欲的在userInfo中存储一些自定义Class的实例对象，然后在序列化的时候，转成可以写入磁盘的NSArray或者NSDictionary等基本数据结构，并在读出的时候继续转化为自定义的对象。


##Demo
具体使用方法及注释可以看demo。

## 如何参与
你可以通过[github地址]参与到该项目，提交issues，或提交pull request申请。

##开源协议
基于MIT协议开源


