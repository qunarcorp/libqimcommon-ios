 //
//  IMManager.m
//  qunarChatMac
//
//  Created by 平 薛 on 14-11-24.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import "QIMManager.h"
#import "QIMManager+Calendar.h"
#import "QIMManager+MiddleVirtualAccountManager.h"
#import "QIMManager+ClientConfig.h"
#import "QIMManager+Request.h"
#import "QIMManager+Collection.h"
#import "QIMManager+Consult.h"
#import "QIMManager+DB.h"
#import "QIMManager+UserMedal.h"
#import "QIMManager+PublicNavUserManager.h"
#import "QIMManager+Friend.h"
#import "QIMManager+Group.h"
#import "QIMManager+GroupMessage.h"
#import "QIMManager+Helper.h"
#import "QIMManager+KeyChain.h"
#import "QIMManager+Login.h"
#import "QIMManager+Message.h"
#import "QIMManager+MySelfStatus.h"
#import "QIMManager+NetWork.h"
#import "QIMManager+PublicRobot.h"
#import "QIMManager+resetLoginInfo.h"
#import "QIMManager+Session.h"
#import "QIMManager+SingleMessage.h"
#import "QIMManager+SystemMessage.h"
#import "QIMManager+UserVcard.h"
#import "QIMManager+Found.h"
#import "QIMManager+Search.h"
#import "QIMManager+XmppImManagerEvent.h"

#import "XmppImManager.h"

#import "QIMNotificationKeys.h"

#import "QIMJSONSerializer.h"

#import "QIMFileManager.h"
#import "QIMDESHelper.h"

#import <SystemConfiguration/CaptiveNetwork.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonCrypto.h>

#import "QIMUUIDTools.h"
#import "QIMAppSetting.h"
#import "QIMNetworkObserver.h"

//#import "ASIDataCompressor.h"
//#import "ASIDataDecompressor.h"
//#import "Database.h"

#import "QIMAppInfo.h"
#import "QIMUserCacheManager.h"
#import "QIMNavConfigManager.h"
#import "QIMVoiceNoReadStateManager.h"

//Categories
#import "NSData+QIMBase64.h"
#import "NSString+QIMBase64.h"
#import "NSDate+QIMCategory.h"

#import "NSDateFormatter+QIMCategory.h"
#import "NSDate+QIMCategory.h"
#import "UIImage+QIMUtility.h"
#import "NSString+QIMUtility.h"
#import "NSMutableDictionary+QIMSafe.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif
#import "QIMHttpRequestMonitor.h"
#import "QIMWatchDog.h"

static QIMManager *__IMManager = nil;

@implementation QIMManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __IMManager = [[QIMManager alloc] init];
        [__IMManager initManager];
    });
    if (!__IMManager) {
        __IMManager = [[QIMManager alloc] init];
        [__IMManager initManager];
    }
    return __IMManager;
}

- (void)clearQIMManager {
    _imageCachePath = nil;
    _downLoadFile = nil;
    _currentSessionUserId = nil;
    _friendDescDic = nil;
    _friendInfoDic = nil;        //好友昵称信息
    _groupInfoDic = nil;
    // 落地了
    _notReadMsgDic = nil;  //未读消息数
    _notReadMsgByGroupDic = nil;  //未读群消息
    _notMindGroupDic = nil;
    _groupList = nil;
    _onlineTables = nil;       // session 在线状态列表
    _userBigHeaderDic = nil;     //用户高清头像字典
    _hasAtMeDic = nil;           //At 字典
    _hasAtAllDic = nil;          //At All
    _stickJidDic = nil;          //置顶的jid
    _conversationParamDic = nil; //会话参数
    _notSendTextDic = nil;       //为发送的文本
    _timeStempDic = nil;
    _chatIdInfoDic = nil;        //会话ChatId 字典
    _myGroupList = nil;                //已存在群列表
    _updateGroupList = nil;            //群增量列表
    _updateGroupIdList = nil;          //群增量Id列表
    _lastMaxGroupVersion = 0;          //最后群时间
    _channelInfoDic = nil;       //渠道信息
    _appendInfoDic = nil;         //各业务线或部门追加信息
    _memberMessageArray = nil;
    
    _sendFileMessageSet = nil;
    
    _lastReceiveGroupMsgTimeDic = nil;
    
    _groupHeaderImageDic = nil;
    _groupHeaderImageCachePath = nil; //群头像缓存地址
    
    _lastLoginTimeDic = nil;
    _lastSingleMsgTime = 0;
    _lastGroupMsgTime = 0;
    _lastSystemMsgTime = 0;
    
    _getSingleHistoryFailed = NO;
    _getGroupHistoryFailed = NO;
    _getSystemHistoryFailed = NO;
    
    _webName = nil;
    
    self.clientConfigDic = nil;
    
    _shareLocationDic = nil;
    _shareLocationFromIdDic = nil;
    _shareLocationUserDic = nil;
}

- (NSMutableDictionary *)timeStempDic {
    if (!_timeStempDic) {
        _timeStempDic = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return _timeStempDic;
}

- (void)initManager {
    
    [QIMNetworkObserver Instance];
    [self initAppCacheConfig];
    [[XmppImManager sharedInstance] setProductType:[[QIMAppInfo sharedInstance] appType]];
    [[XmppImManager sharedInstance] setAppVersion:[[QIMAppInfo sharedInstance] AppBuildVersion]];
    [[XmppImManager sharedInstance] setSystemVersion:[[QIMAppInfo sharedInstance] SystemVersion]];
    [[XmppImManager sharedInstance] setPlatform:[[QIMAppInfo sharedInstance] Platform]];
    [[XmppImManager sharedInstance] setDeviceName:[[QIMAppInfo sharedInstance] deviceName]];
    [[XmppImManager sharedInstance] setLoginType:XmppLoginType_LAN];
//    [self updateNavigationConfig];
    [self registerEvent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnecting) name:@"ONXMPPConnecting" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkChange:) name:kNotifyNetworkChange object:nil];
    //切换账号成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSwitchAccount:) name:kNotifySwichUserSuccess object:nil];
}

- (dispatch_queue_t)cacheQueue {
    return _cacheQueue;
}

- (void*)cacheTag {
    return _cacheTag;
}

- (void)initAppCacheConfig {
    self.update_chat_card = dispatch_queue_create("update_chat_card", DISPATCH_QUEUE_SERIAL);
    self.update_group_card = dispatch_queue_create("update_group_vcard", DISPATCH_QUEUE_SERIAL);
    self.update_group_member_queue = dispatch_queue_create("Update Group Member Info Queue", DISPATCH_QUEUE_SERIAL);
    self.load_group_offline_msg_queue = dispatch_queue_create("Load Group Offline Msg Queue", DISPATCH_QUEUE_SERIAL);
    self.load_user_state_queue = dispatch_queue_create("Load User State", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    self.receive_msg_queue = dispatch_queue_create("Receive Msg", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    self.receive_msgSendState_queue = dispatch_queue_create("Receive MsgSendState Queue", DISPATCH_QUEUE_SERIAL);
    self.receive_msgReadState_queue = dispatch_queue_create("Receive MsgReadState Queue", DISPATCH_QUEUE_SERIAL);
    self.receive_notify_queue = dispatch_queue_create("Receive Presence Notify Msg", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    self.load_user_header = [[YYDispatchQueuePool alloc] initWithName:@"Load User Header" queueCount:2 qos:NSQualityOfServiceUserInitiated];
//    dispatch_queue_create("Load User Header", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    self.load_session_content = [[YYDispatchQueuePool alloc] initWithName:@"load_session_content" queueCount:2 qos:NSQualityOfServiceBackground];
    self.load_session_name = [[YYDispatchQueuePool alloc] initWithName:@"load_session_name" queueCount:2 qos:NSQualityOfServiceBackground];
    self.load_session_unreadcount = [[YYDispatchQueuePool alloc] initWithName:@"load_session_unreadcount" queueCount:2 qos:NSQualityOfServiceBackground];
    self.load_groupDB_VCard = [[YYDispatchQueuePool alloc] initWithName:@"load group card from DB" queueCount:2 qos:NSQualityOfServiceBackground];
    self.load_msgNickName = [[YYDispatchQueuePool alloc] initWithName:@"load msg nickName" queueCount:2 qos:NSQualityOfServiceBackground];
    self.load_msgMedalList = [[YYDispatchQueuePool alloc] initWithName:@"load msg medalList" queueCount:2 qos:NSQualityOfServiceBackground];
    self.load_msgHeaderImage = [[YYDispatchQueuePool alloc] initWithName:@"load msg headerImage" queueCount:2 qos:NSQualityOfServiceBackground];

//    dispatch_queue_create("Load Session Content", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    self.lastReceiveGroupMsgTimeDic = [[NSMutableDictionary alloc] init];
    self.load_customEvent_queue = dispatch_queue_create("Load CustomEvent Queue", DISPATCH_QUEUE_SERIAL);
    self.lastQueue = dispatch_queue_create("Last Manager Queue", DISPATCH_QUEUE_SERIAL);
    
    self.cacheQueue = dispatch_queue_create("IMManager CACHE QUEUE", DISPATCH_QUEUE_SERIAL);
    self.cacheTag = &_cacheTag;
    dispatch_queue_set_specific(self.cacheQueue, self.cacheTag, self.cacheTag, NULL);
    
    self.atMeCacheQueue = dispatch_queue_create("IMManager atMeCache Queue", DISPATCH_QUEUE_SERIAL);
    self.atMeCacheTag = &_atMeCacheTag;
    dispatch_queue_set_specific(self.atMeCacheQueue, self.atMeCacheTag, self.atMeCacheTag, NULL);
    
    _timeStempDic = [[NSMutableDictionary alloc] init];
//    _hasAtMeDic = [[NSMutableDictionary alloc] init];
//    _hasAtAllDic = [[NSMutableDictionary alloc] init];
    _friendDescDic = [[NSMutableDictionary alloc] init];
    _friendInfoDic = [[NSMutableDictionary alloc] init];
    _groupList = [[NSMutableArray alloc] init];
    _memberMessageArray = [[NSMutableArray alloc] init];
    _lastLoginTimeDic = [[NSMutableDictionary alloc] init];
    _groupInfoDic = [[NSMutableDictionary alloc] init];
    _groupHeaderImageDic = [[NSMutableDictionary alloc] init];
    _shareLocationDic = [NSMutableDictionary dictionary];
    _shareLocationUserDic = [NSMutableDictionary dictionary];
    _shareLocationFromIdDic = [NSMutableDictionary dictionary];
    _userResourceDic = [NSMutableDictionary dictionary];
    _onlineTables = [[NSMutableDictionary alloc] init];
    _imageCachePath = [UserCachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/imageCache/"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_imageCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_imageCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    _downLoadFile = [UserCachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/imageCache/"]];

    if (![[NSFileManager defaultManager] fileExistsAtPath:_downLoadFile]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_downLoadFile withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)initUserDicts {
    
    {
        _stickJidDic = [NSMutableDictionary dictionary];
        NSDictionary *dic = [[QIMUserCacheManager sharedInstance] userObjectForKey:kStickJidDic];
        if (dic) {
            [_stickJidDic setDictionary:dic];
        }
    }
    
    {
        _conversationParamDic = [NSMutableDictionary dictionary];
        NSDictionary *dic = [[QIMUserCacheManager sharedInstance] userObjectForKey:kConversationParamDic];
        if (dic) {
            [_conversationParamDic setDictionary:dic];
        }
    }
    
    {
        _notReadMsgDic = [[NSMutableDictionary alloc] init];
    }
    
    {
        _notReadMsgByGroupDic = [[NSMutableDictionary alloc] init];
    }
    
    {
        _notMindGroupDic = [[NSMutableDictionary alloc] init];
    }
    
    _userBigHeaderDic = [NSMutableDictionary dictionary];
    {
        NSDictionary *dic = [[QIMUserCacheManager sharedInstance] userObjectForKey:kUserBigHeaderDic];
        if (dic) {
            [_userBigHeaderDic setDictionary:dic];
        }
    }
    _hotCommentUUIdsDic = [NSMutableDictionary dictionaryWithCapacity:2];
    _userNormalHeaderDic = [NSMutableDictionary dictionaryWithCapacity:5];
    
    _userInfoDic = [NSMutableDictionary dictionaryWithCapacity:5];
    
    _notSendTextDic = [NSMutableDictionary dictionary];
    {
        NSDictionary *dic = [[QIMUserCacheManager sharedInstance] userObjectForKey:kNotSendTextDic];
        [_notSendTextDic setDictionary:dic];
    }
    
    self.clientConfigDic = [NSMutableDictionary dictionary];
    {
        NSDictionary *dic = [[QIMUserCacheManager sharedInstance] userObjectForKey:kNewClinetConfigDic];
        if (dic) {
            self.clientConfigDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        }
    }
    
    _chatIdInfoDic = [NSMutableDictionary dictionary];
    {
        NSDictionary *dic = [[QIMUserCacheManager sharedInstance] userObjectForKey:kChannelInfoDic];
        if (dic) {
            [_chatIdInfoDic setDictionary:dic];
        }
    }
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
        _channelInfoDic = [NSMutableDictionary dictionary];
        {
            NSDictionary *dic = [[QIMUserCacheManager sharedInstance] userObjectForKey:kChannelInfoDic];
            if (dic) {
                [_channelInfoDic setDictionary:dic];
            }
        }
        
        _appendInfoDic = [NSMutableDictionary dictionary];
        {
            NSDictionary *dic = [[QIMUserCacheManager sharedInstance] userObjectForKey:kAppendInfoDic];
            if (dic) {
                [_appendInfoDic setDictionary:dic];
            }
        }
    }
    _soundName = [[QIMManager sharedInstance] getClientNotificationSoundName];
}

@end

@implementation QIMManager (RegisterEvent)

- (void)refreshSwitchAccount:(NSDictionary *)notify {
    [self checkClientConfig];
}

// <iq type='get' id='id_'><key xmlns='urn:xmpp:key'/></iq>
- (NSString *)updateRemoteLoginKey {
    @synchronized (self) {
        self.remoteKey = [[XmppImManager sharedInstance] getRemoteLoginKey];
    }
    return _remoteKey;
}

- (NSString *)getImagerCache {
    
    //启动后_imageCachePath为空
    if (!_imageCachePath) {
        //防止数据库及Beta环境本地路径出错
        _imageCachePath = [UserCachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/imageCache/"]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_imageCachePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_imageCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:_imageCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_imageCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return _imageCachePath;
}

- (void)loginComplate {
    QIMVerboseLog(@"初始化一下日志统计组件");
    Class autoTrackerDataManager = NSClassFromString(@"QIMAutoTrackerDataManager");
    [autoTrackerDataManager performSelector:@selector(qimDB_sharedLogDBInstanceWithDBFullJid:) withObject:[[QIMManager sharedInstance] getLastJid]];
    
    NSOperationQueue *loginComplateQueue = [[NSOperationQueue alloc] init];
    [loginComplateQueue setMaxConcurrentOperationCount:1];
    loginComplateQueue.name = @"loginComplateQueue";
    QIMVerboseLog(@"self.loginComplateQueue State : %d", loginComplateQueue.isSuspended);
    QIMVerboseLog(@"self.loginComplateQueue Opertions1 : %@", loginComplateQueue.operations);
    [loginComplateQueue cancelAllOperations];
    QIMVerboseLog(@"self.loginComplateQueue Opertions2 : %@", loginComplateQueue.operations);

    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loginComplateOperation) object:nil];
    [operation setCompletionBlock:^{
        QIMVerboseLog(@"loginComplateOperation执行完事");
    }];
    [loginComplateQueue addOperation:operation];
    QIMVerboseLog(@"self.loginComplateQueue Opertions3 : %@", loginComplateQueue.operations);
}

- (void)loginComplateOperation {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginState object:[NSNumber numberWithBool:YES]];
    [self updateAppWorkState:AppWorkState_Updating];
    self.notNeedCheckNetwotk = NO;
    self.needTryRelogin = YES;
    QIMVerboseLog(@"<Method: %s, Set _needTryRelogin == YES>", __func__);
    //重置消息是否最新Flag
    _latestGroupMessageFlag = YES;
    _latestSingleMessageFlag = YES;
    _latestSystemMessageFlag = YES;
    
    [[QIMUserCacheManager sharedInstance] setCacheName:[[QIMManager sharedInstance] getLastJid]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *userName = [[QIMUserCacheManager sharedInstance] userObjectForKey:kLastUserId];
        NSString *userFullJid = [userName stringByAppendingFormat:@"@%@", [[XmppImManager sharedInstance] domain]];
        [[QIMUserCacheManager sharedInstance] setUserObject:userFullJid forKey:@"kFullUserJid"];
        QIMVerboseLog(@"LoginComplate 之后的userFullJid : %@", userFullJid);
        NSString *tempUserToken = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"kTempUserToken"];
//        [[QIMUserCacheManager sharedInstance] setUserObject:tempUserToken?tempUserToken:@"" forKey:@"userToken"];
        [self updateLastUserToken:tempUserToken];
        QIMVerboseLog(@"LoginComplate 之后的tempUserToken : %@", tempUserToken);
#warning NavDict NavConfig
        NSDictionary *currentLoginNavConfig = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"NavConfig"];
        NSDictionary *currentNavDict = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"QC_CurrentNavDict"];
        NSDictionary *navDict = @{@"NavConfig":currentLoginNavConfig?currentLoginNavConfig:@{}, @"NavUrl":currentNavDict?currentNavDict : @{}};
        [self addUserCacheWithUserId:userName WithUserFullJid:userFullJid WithNavDict:navDict];
        
        NSString *oldLoginUser = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"LastestLoginUser"];
        if (oldLoginUser && ![oldLoginUser isEqualToString:[[QIMManager sharedInstance] getLastJid]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                QIMVerboseLog(@"抛出通知 : kNotifySwichUserSuccess");
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySwichUserSuccess object:@(YES)];
            });
        }
        [[QIMUserCacheManager sharedInstance] setUserObject:[[QIMManager sharedInstance] getLastJid] forKey:@"LastestLoginUser"];
    });
    QIMVerboseLog(@"userDocuments : %@", UserDocumentsPath);
    QIMVerboseLog(@"userPath : %@", UserPath);
    //防止数据库及Beta环境本地路径出错
    _imageCachePath = [UserCachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/imageCache/"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_imageCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_imageCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    _downLoadFile = [UserCachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/imageCache/"]];

    if (![[NSFileManager defaultManager] fileExistsAtPath:_downLoadFile]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_downLoadFile withIntermediateDirectories:YES attributes:nil error:nil];
    }

    QIMVerboseLog(@"开始获取单人历史记录2");
    CFAbsoluteTime startTime1 = [[QIMWatchDog sharedInstance] startTime];
    [self updateOfflineMessagesV2];
    QIMVerboseLog(@"获取单人历史记录2loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime1]);
    QIMVerboseLog(@"获取单人历史记录结束2");

    QIMVerboseLog(@"开始获取消息已读状态2");
    CFAbsoluteTime startTime2 = [[QIMWatchDog sharedInstance] startTime];
    [self getReadFlag];
    QIMVerboseLog(@"获取消息已读状态2loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime2]);
    QIMVerboseLog(@"获取消息已读状态结束2");

    dispatch_async(dispatch_get_main_queue(), ^{
        QIMVerboseLog(@"强制刷一下单聊会话框界面的消息开始2");
        [[NSNotificationCenter defaultCenter] postNotificationName:kSingleChatMsgReloadNotification object:nil];
        QIMVerboseLog(@"强制刷一下单聊会话框界面的消息结束2");
    });

    QIMVerboseLog(@"开始获取群历史记录2");
    CFAbsoluteTime startTime3 = [[QIMWatchDog sharedInstance] startTime];
    [self updateOfflineGroupMessages];
    QIMVerboseLog(@"获取群历史记录2loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime3]);
    QIMVerboseLog(@"获取群历史记录结束2");

    dispatch_async(dispatch_get_main_queue(), ^{
        QIMVerboseLog(@"强制刷新列表页");
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:@"ForceRefresh"];
        QIMVerboseLog(@"强制刷新列表页结束");
        
        QIMVerboseLog(@"强制刷一下群聊会话框界面的消息开始2");
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupChatMsgReloadNotification object:nil];
        QIMVerboseLog(@"强制刷一下群聊会话框界面的消息结束2");
    });
    [self updateAppWorkState:AppWorkState_Login];
    QIMVerboseLog(@"主页Title已经更新为登录完成");
    
    QIMVerboseLog(@"开始获取群阅读指针2");
    CFAbsoluteTime startTime4 = [[QIMWatchDog sharedInstance] startTime];
    [self updateMucReadMark];
    QIMVerboseLog(@"获取群阅读指针2loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime4]);
    QIMVerboseLog(@"获取群阅读指针结束2");
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMVerboseLog(@"获取阅读指针之后再次强制刷新列表页");
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:@"ForceRefresh"];
        QIMVerboseLog(@"获取阅读指针之后再次强制刷新列表页结束");
    });
    QIMVerboseLog(@"同步消息完成耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime1]);

    QIMVerboseLog(@"开始获取系统历史记录2");
    CFAbsoluteTime startTime5 = [[QIMWatchDog sharedInstance] startTime];
    [self updateOfflineSystemNoticeMessages];
    QIMVerboseLog(@"获取系统历史记录2loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime5]);
    QIMVerboseLog(@"获取系统历史记录结束2");
    
    [[IMDataManager qimDB_SharedInstance] qimDB_updateMessageFromState:QIMMessageSendState_Waiting ToState:QIMMessageSendState_Faild];
    QIMVerboseLog(@"开始同步服务端漫游的个人配置2");
    CFAbsoluteTime startTime6 = [[QIMWatchDog sharedInstance] startTime];
    [self getRemoteClientConfig];
    QIMVerboseLog(@"同步服务端漫游的个人配置2loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime6]);
    QIMVerboseLog(@"同步服务端漫游的个人配置完成2");
    
    if ([[QIMAppInfo sharedInstance] appType] != QIMProjectTypeQChat) {
        QIMVerboseLog(@"开始获取我的关联账户2");
        CFAbsoluteTime startTime7 = [[QIMWatchDog sharedInstance] startTime];
        [self getRemoteCollectionAccountList];
        QIMVerboseLog(@"获取我的关联账户2loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime7]);
        /* 暂时屏蔽公众号
        QIMVerboseLog(@"开始同步公众号列表2");
        CFAbsoluteTime startTime8 = [[QIMWatchDog sharedInstance] startTime];
        [self updatePublicNumberList];
        QIMVerboseLog(@"同步公众号列表2loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime8]);
        QIMVerboseLog(@"同步公众号列表完成2");
         */
    }
    
    QIMVerboseLog(@"开始Check组织架构2");
    CFAbsoluteTime startTime9 = [[QIMWatchDog sharedInstance] startTime];
    [self updateOrganizationalStructure];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotifyNotificationReloadOrganizationalStructure" object:nil];
    });
    QIMVerboseLog(@"Check组织架构2loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime9]);
    QIMVerboseLog(@"Check组织架构结束2");

    QIMVerboseLog(@"开始请求增量群列表");
    CFAbsoluteTime startTime10 = [[QIMWatchDog sharedInstance] startTime];
    [self quickJoinAllGroup];
    QIMVerboseLog(@"快速入群完成2loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime10]);
    QIMVerboseLog(@"快速入群完成2");

    QIMVerboseLog(@"开始获取增量群名片");
    [self getIncrementGroupCards];
    QIMVerboseLog(@"获取增量群名片完成");

    QIMVerboseLog(@"开始TCP发送已送达消息状态2");
    CFAbsoluteTime startTime11 = [[QIMWatchDog sharedInstance] startTime];
    [self sendRecevieMessageState];
    QIMVerboseLog(@"TCP发送已送达消息状态2loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime11]);
    QIMVerboseLog(@"TCP发送已送达消息状态结束2");
    
    QIMVerboseLog(@"开始同步消息推送设置2");
    CFAbsoluteTime startTime12 = [[QIMWatchDog sharedInstance] startTime];
    [self getMsgNotifyRemoteSettings];
    QIMVerboseLog(@"同步消息推送设置2loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime12]);
    QIMVerboseLog(@"同步同步消息推送设置2");
    
    [self checkClientConfig];

    QIMVerboseLog(@"开始获取加密会话密码箱2");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotifyNotificationGetRemoteEncrypt" object:nil];
    });
    QIMVerboseLog(@"开始获取加密会话密码箱2结束");
    
    CFAbsoluteTime startTime13 = [[QIMWatchDog sharedInstance] startTime];
    [self sendPushTokenWithMyToken:[[QIMAppInfo sharedInstance] getPushToken] WithDeleteFlag:NO withCallback:nil];
    QIMVerboseLog(@"注册Token1loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime13]);
    
    // 更新好友列表
    CFAbsoluteTime startTime14 = [[QIMWatchDog sharedInstance] startTime];
    [self updateFriendList];
    QIMVerboseLog(@"更新好友列表loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime14]);
    
    CFAbsoluteTime startTime15 = [[QIMWatchDog sharedInstance] startTime];
    [self updateFriendInviteList];
    QIMVerboseLog(@"邀请好友申请loginComplate耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime15]);
    
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
        QIMVerboseLog(@"客服获取快捷回复");
        [self getRemoteQuickReply];
    };
    
    if ([[QIMNavConfigManager sharedInstance] showOA] == YES) {
        QIMVerboseLog(@"开始获取行程区域");
        [self getRemoteAreaList];
        QIMVerboseLog(@"结束获取行程区域");
        
        QIMVerboseLog(@"开始获取用户行程列表");
        [self getRemoteUserTripList];
        QIMVerboseLog(@"结束获取用户行程列表");
    }
    [self updateMyCard];

    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            if ([self isMerchant]) {
                //客服发送上线通知
                QIMVerboseLog(@"客服发送上线通知");
                [self sendQChatOnlineNotification];
            }
        });
    }
    
    if ([[QIMAppInfo sharedInstance] appType] != QIMProjectTypeQChat) {
        
        QIMVerboseLog(@"登录之后请求一下驼圈入口开关");
        [self getCricleCamelEntrance];
        QIMVerboseLog(@"登录之后请求一下驼圈视频配置");
        [self getCricleCamelVideoConfig];
        
        QIMVerboseLog(@"登录之后获取一下驼圈提醒开关");
        [self getRemoteWorkMomentSwitch];
        
        QIMVerboseLog(@"登录之后请求一下驼圈未读消息");
        [self getupdateRemoteWorkNoticeMsgs];
        
    
        QIMVerboseLog(@"登录之后请求热线账户列表");
        [self getRemoteHotlineShopList];
        
        QIMVerboseLog(@"登录之后获取发现页应用列表");
        [self getRemoteFoundNavigation];
        
        QIMVerboseLog(@"登录之后获取勋章列表");
        [self getRemoteMedalList];
        
        QIMVerboseLog(@"登录之后获取我的勋章列表");
        [self getRemoteUserMedalListWithUserId:[[QIMManager sharedInstance] getLastJid]];
    }
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQTalk) {
        QIMVerboseLog(@"登录之后请求一下骆驼帮未读数");
        
        [[QIMManager sharedInstance] getExploreNotReaderCount];
    }
    
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeStartalk && [[QIMAppInfo sharedInstance] applicationState] == QIMApplicationStateLaunch) {
        QIMVerboseLog(@"请求新版本");
//        [self findNewestClient];
    }

    QIMVerboseLog(@"登录之后主动上报日志");
    Class autoTracker = NSClassFromString(@"QIMAutoTrackerOperation");
    id autoTrackerObject = [[autoTracker alloc] init];
    [autoTrackerObject performSelectorInBackground:@selector(uploadTracerData) withObject:nil];
}

- (void)generateClientConfigUpgradeArrayWithType:(QIMClientConfigType)type WithArray:(id)valueArr {
    if (!self.clientConfigUpgradeArray) {
        self.clientConfigUpgradeArray = [NSMutableArray arrayWithCapacity:3];
    }
    switch (type) {
        case QIMClientConfigTypeKMarkupNames: {
            NSDictionary *valueDic = (NSDictionary *)valueArr;
            for (NSString *xmppId in [valueDic allKeys]) {
                if (xmppId.length > 0) {
                    NSString *remarkName = [valueDic objectForKey:xmppId];
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
                    [dict setQIMSafeObject:[self transformClientConfigKeyWithType:type] forKey:@"key"];
                    [dict setQIMSafeObject:remarkName forKey:@"value"];
                    [dict setQIMSafeObject:xmppId forKey:@"subkey"];
                    [self.clientConfigUpgradeArray addObject:dict];
                }
            }
        }
            break;
        case QIMClientConfigTypeKCollectionCacheKey: {
            NSArray *valueArray = (NSArray *)valueArr;
            for (NSDictionary *dic in valueArray) {
                NSString *configKey = [self transformClientConfigKeyWithType:type];
                NSString *configValue = dic[@"httpUrl"];
                NSString *subKey = [[QIMFileManager sharedInstance] md5fromUrl:configValue];
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
                [dict setQIMSafeObject:configKey forKey:@"key"];
                [dict setQIMSafeObject:configValue forKey:@"value"];
                [dict setQIMSafeObject:subKey forKey:@"subkey"];
                [self.clientConfigUpgradeArray addObject:dict];
            }
        }
            break;
        case QIMClientConfigTypeKStickJidDic: {
            NSString *valueStr = (NSString *)valueArr;
            NSDictionary *valueDic = [[QIMJSONSerializer sharedInstance] deserializeObject:valueStr error:nil];
            for (NSString *xmppId in [valueDic allKeys]) {
                if (xmppId.length <= 0) {
                    continue;
                }
                NSString *combineJid = [NSString stringWithFormat:@"%@<>%@", xmppId, xmppId];
                ChatType chatType = [xmppId containsString:@"conference."] ? ChatType_GroupChat : ChatType_SingleChat;
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
                NSDictionary *chatTypeDict = @{@"chatType":@(chatType)};
                [dict setQIMSafeObject:[self transformClientConfigKeyWithType:type] forKey:@"key"];
                [dict setQIMSafeObject:[[QIMJSONSerializer sharedInstance] serializeObject:chatTypeDict] forKey:@"value"];
                [dict setQIMSafeObject:combineJid forKey:@"subkey"];
                [self.clientConfigUpgradeArray addObject:dict];
            }
        }
            break;
        case QIMClientConfigTypeKNotificationSetting: {
            
        }
            break;
        case QIMClientConfigTypeKConversationParamDic: {
            
        }
            break;
        case QIMClientConfigTypeKQuickResponse: {
            
        }
            break;
        case QIMClientConfigTypeKChatColorInfo: {
            NSDictionary *valueDict = (NSDictionary *)valueArr;
            NSString *configKey = [self transformClientConfigKeyWithType:type];
            NSString *configValue = [[QIMJSONSerializer sharedInstance] serializeObject:valueDict];
            NSString *subKey = [[QIMManager sharedInstance] getLastJid];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
            [dict setQIMSafeObject:configKey forKey:@"key"];
            [dict setQIMSafeObject:configValue forKey:@"value"];
            [dict setQIMSafeObject:subKey forKey:@"subkey"];
            [self.clientConfigUpgradeArray addObject:dict];
        }
            break;
        case QIMClientConfigTypeKCurrentFontInfo: {
            NSDictionary *valueDict = (NSDictionary *)valueArr;
            NSString *configKey = [self transformClientConfigKeyWithType:type];
            NSString *configValue = [[QIMJSONSerializer sharedInstance] serializeObject:valueDict];
            NSString *subKey = [[QIMManager sharedInstance] getLastJid];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
            [dict setQIMSafeObject:configKey forKey:@"key"];
            [dict setQIMSafeObject:configValue forKey:@"value"];
            [dict setQIMSafeObject:subKey forKey:@"subkey"];
            [self.clientConfigUpgradeArray addObject:dict];
        }
            break;
        case QIMClientConfigTypeKNoticeStickJidDic: {
            NSArray *dataList = (NSArray *)valueArr;
            if (!self.notMindGroupDic) {
                self.notMindGroupDic = [NSMutableDictionary dictionaryWithCapacity:3];
            }
            for (NSDictionary *dict in dataList) {
                NSString *domain = [dict objectForKey:@"domain"];
                NSString *muc_name = [dict objectForKey:@"muc_name"];
                BOOL subscribe_flag = [[dict objectForKey:@"subscribe_flag"] boolValue];
                NSString *groupId = [NSString stringWithFormat:@"%@@%@", muc_name, domain];
                if (subscribe_flag == NO) {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
                    [dict setQIMSafeObject:[self transformClientConfigKeyWithType:QIMClientConfigTypeKNoticeStickJidDic] forKey:@"key"];
                    [dict setQIMSafeObject:@"0" forKey:@"value"];
                    [dict setQIMSafeObject:groupId forKey:@"subkey"];
                    [self.clientConfigUpgradeArray addObject:dict];
//                    [self.notMindGroupDic setObject:@(subscribe_flag) forKey:groupId];
                }
            }
        }
            break;
        default:
            break;
    }
}

@end

@implementation QIMManager (Common)

//获取组织架构
- (void)updateOrganizationalStructure {
    NSString *destUrl = [NSString stringWithFormat:@"%@/update/getUpdateUsers.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSInteger userMaxVersion = [[IMDataManager qimDB_SharedInstance] qimDB_getUserCacheDataWithKey:kGetUpdateUsersV2Version withType:7];
    NSDictionary *versionDic = @{@"version":@(userMaxVersion)};
    NSData *versionData = [[QIMJSONSerializer sharedInstance] serializeObject:versionDic error:nil];
    [[QIMManager sharedInstance] sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:versionData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([responseDic isKindOfClass:[NSDictionary class]]) {
            BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
            NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
            if (ret && errcode == 0) {
                NSDictionary *dataDic = [responseDic objectForKey:@"data"];
                long long maxVersion = [[dataDic objectForKey:@"version"] longLongValue];
                [[IMDataManager qimDB_SharedInstance] qimDB_UpdateUserCacheDataWithKey:kGetUpdateUsersV2Version withType:7 withValue:@"新版组织架构时间戳" withValueInt:maxVersion];
                NSArray *updateUserList = [dataDic objectForKey:@"update"];
                NSArray *userList = [dataDic objectForKey:@"update"];
                [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertOrgansUserInfos:userList];
                
                NSArray *deleteUserList = [dataDic objectForKey:@"delete"];
                [[IMDataManager qimDB_SharedInstance] qimDB_clearUserListForList:deleteUserList];
            } else {
                QIMErrorLog(@"请求新版本组织架构失败了", [responseDic objectForKey:@"errmsg"]);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

@end

@implementation QIMManager (CommonConfig)

- (void)setIsMerchant:(BOOL)isMerchant {
    _isLoadMerchant = YES;
    [[QIMUserCacheManager sharedInstance] setUserObject:@(isMerchant) forKey:@"isMerchant"];
    _isMerchant = isMerchant;
}

- (BOOL)isMerchant {
    if (YES == _isLoadMerchant) {
        return _isMerchant;
    } else {
        NSNumber *isMerchantCacheNumber = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"isMerchant"];
        if (isMerchantCacheNumber) {
            return [isMerchantCacheNumber boolValue];
        }
    }
    return _isMerchant;
}

/**
 *  UserName Ex: lilulucas.li
 *
 *  @return UserName
 */
+ (NSString *)getLastUserName {
    return [[[QIMUserCacheManager sharedInstance] userObjectForKey:kLastUserId] lowercaseString];
}

- (void)updateLastTempUserToken:(NSString *)token {
    [[QIMUserCacheManager sharedInstance] setUserObject:token forKey:@"kTempUserToken"];
}

- (NSString *)getLastTempUserToken {
    return [[QIMUserCacheManager sharedInstance] userObjectForKey:@"kTempUserToken"];
}

- (void)updateLastUserToken:(NSString *)tempUserToken {
    [[QIMUserCacheManager sharedInstance] setUserObject:tempUserToken?tempUserToken:@"" forKey:@"userToken"];
}

- (NSString *)getLastUserToken {
    return [[QIMUserCacheManager sharedInstance] userObjectForKey:@"userToken"];
}

/**
 *  PWD
 *
 *  @return 无用
 */
- (NSString *)getLastPassword {
    return [[QIMUserCacheManager sharedInstance] userObjectForKey:kLastPassword];
}

/**
 *  JID  Ex: lilulucas.li@ejabhost1
 *
 *  @return JID
 */
- (NSString *)getLastJid {
    if ([QIMManager getLastUserName]) {
        return [[NSString stringWithFormat:@"%@@%@", [QIMManager getLastUserName], [[XmppImManager sharedInstance] domain]] lowercaseString];
    }
    return nil;
}

/**
 *  nickName  Ex: 李露lucas
 *
 *  @return MyNickName
 */
- (NSString *)getMyNickName {
    
    NSString *myNickName = nil;
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
        myNickName = [QIMManager getLastUserName];
    } else {
        /*
        NSDictionary *myProfile = [self getUserInfoByUserId:[self getLastJid]];
        if (myProfile.count) {
            NSString *nickName = [myProfile objectForKey:@"Name"];
            if (nickName) {
                myNickName = nickName;
            }
        }
        */
    }
    return myNickName;
}

- (NSString *)myRemotelogginKey {
    return self.remoteKey;
}

- (NSString *)getDomain {
    return [[XmppImManager sharedInstance] domain];
}

- (NSString *) thirdpartKeywithValue {
    
    long long time = ([[NSDate date] timeIntervalSince1970]) * 1000;
    
    NSString *remoteKey = [self remoteKey];
    if (remoteKey.length <= 0) {
        remoteKey = [self updateRemoteLoginKey];
    }
    remoteKey = remoteKey != nil ? remoteKey : @"";
    
    NSString *k2 = [NSString stringWithFormat:@"%@%lld",
                    remoteKey,
                    time];
    
    NSString *newString = [NSString stringWithFormat:@"u=%@&d=%@&k=%@&t=%lld",
                           [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           [[XmppImManager sharedInstance] domain],
                           [k2 qim_getMD5],
                           time];
    
    
    NSString *newBase64Str = [newString qim_base64EncodedString];
    return newBase64Str;
}

- (long long)getCurrentServerTime {
    return ([[NSDate date] timeIntervalSince1970] - self.serverTimeDiff)*1000;
}

- (NSString *)remoteKey {
    if (_remoteKey == nil || [_remoteKey length] <= 0) {
        [self updateRemoteLoginKey];
    }
    return _remoteKey;
}

- (int)getServerTimeDiff {
    return _serverTimeDiff;
}

- (NSHTTPCookie *)cookie {
    NSDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:[[QIMManager sharedInstance] thirdpartKeywithValue] forKey:NSHTTPCookieValue];
    [properties setValue:@"q_ckey" forKey:NSHTTPCookieName];
    [properties setValue:@".qunar" forKey:NSHTTPCookieDomain];
    [properties setValue:@"/" forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    return cookie;
}

- (NSString *)getWlanRequestURL {
    
    NSData *requestURLData = [QIMUUIDTools getRequestUrl];
    NSString *requestURL = [[NSString alloc] initWithData:requestURLData encoding:NSUTF8StringEncoding];
    if (requestURL.length > 0) {
        return requestURL;
    } else {
        if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
            return [[QIMNavConfigManager sharedInstance] newerHttpUrl];
        } else{
            return [[QIMNavConfigManager sharedInstance] newerHttpUrl];
        }
    }
}

- (NSString *)getWlanRequestDomain {

    NSData *requestDomainData = [QIMUUIDTools getRequestDoamin];
    NSString *requestDomain = [[NSString alloc] initWithData:requestDomainData encoding:NSUTF8StringEncoding];
    if (requestDomain.length > 0) {
        return requestDomain;
    } else {
        if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
            return @"ejabhost2";
        } else {
            return @"ejabhost1";
        }
    }
    return nil;
}

- (NSString *)getWlanKeyByTime:(int)time {

     NSString *key = [NSString stringWithFormat:@"%@%d", [QIMUUIDTools deviceUUID], time];
     QIMVerboseLog(@"快捷回复使用的key : %@", key);
     NSString *str = [NSString stringWithFormat:@"u=%@@%@&k=%@", [[QIMUUIDTools loginUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self getWlanRequestDomain], [[key qim_getMD5] lowercaseString]];
    /*
     if ([[self getWlanRequestDomain] isEqualToString:@"ejabhost1"] || [[self getWlanRequestDomain] isEqualToString:@"ejabhost2"]) {
     str = [NSString stringWithFormat:@"u=%@&k=%@", [[QIMUUIDTools loginUserName] ? [QIMUUIDTools loginUserName] : [QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[key qim_getMD5] lowercaseString]];
     }
    */
     QIMVerboseLog(@"快捷回复Base64之前 : %@", str);
     return [[str dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (NSDictionary *)loadWlanCookie {
    
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
        NSMutableDictionary *qcookieProperties = [NSMutableDictionary dictionary];
        [qcookieProperties setObject:@"_q" forKey:NSHTTPCookieName];
        [qcookieProperties setObject:[QIMUUIDTools qcookie] forKey:NSHTTPCookieValue];
        [qcookieProperties setObject:@".qunar.com" forKey:NSHTTPCookieDomain];
        [qcookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
        [qcookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
        
        NSHTTPCookie *qcookie = [NSHTTPCookie cookieWithProperties:qcookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qcookie];
        
        NSMutableDictionary *vcookieProperties = [NSMutableDictionary dictionary];
        [vcookieProperties setObject:@"_v" forKey:NSHTTPCookieName];
        [vcookieProperties setObject:[QIMUUIDTools vcookie] forKey:NSHTTPCookieValue];
        [vcookieProperties setObject:@".qunar.com" forKey:NSHTTPCookieDomain];
        [vcookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
        [vcookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
        
        NSHTTPCookie *vcookie = [NSHTTPCookie cookieWithProperties:vcookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:vcookie];
        
        NSMutableDictionary *tcookieProperties = [NSMutableDictionary dictionary];
        [tcookieProperties setObject:@"_t" forKey:NSHTTPCookieName];
        [tcookieProperties setObject:[QIMUUIDTools tcookie] forKey:NSHTTPCookieValue];
        [tcookieProperties setObject:@".qunar.com" forKey:NSHTTPCookieDomain];
        [tcookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
        [tcookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
        
        NSHTTPCookie *tcookie = [NSHTTPCookie cookieWithProperties:tcookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:tcookie];
        
        NSArray *arrCookies = [NSArray arrayWithObjects:qcookie, vcookie, tcookie, nil];
        NSDictionary *dictCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:arrCookies];
        return dictCookies;
    } else {
        //QTalk 默认q_ckey
        NSMutableDictionary *qckeyCookieProperties = [NSMutableDictionary dictionary];
        int time = [[NSDate date] timeIntervalSince1970];
        NSString *qckey = [self getWlanKeyByTime:time];
        [qckeyCookieProperties setObject:qckey forKey:NSHTTPCookieValue];
        [qckeyCookieProperties setObject:@"q_ckey" forKey:NSHTTPCookieName];
        [qckeyCookieProperties setObject:@".qunar.com" forKey:NSHTTPCookieDomain];
        [qckeyCookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
        [qckeyCookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
        
        NSHTTPCookie *qckeyCookie = [NSHTTPCookie cookieWithProperties:qckeyCookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qckeyCookie];
        
        NSArray *arrCookies = [NSArray arrayWithObjects:qckeyCookie, nil];
        NSDictionary *dictCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:arrCookies];
        return dictCookies;
    }
    return nil;
}

// 更新导航配置
- (void)updateNavigationConfig {
    //赋值deviceUUID
    [[XmppImManager sharedInstance] setDeviceUUID:[QIMUUIDTools deviceUUID]];
    [[XmppImManager sharedInstance] setProtocolType:ProtocolType_Protobuf];
    [[XmppImManager sharedInstance] setDomain:self.imLoginDomain];
    [[XmppImManager sharedInstance] setHostName:self.imLoginXmppHost];
    [[XmppImManager sharedInstance] setPort:[self.imLoginProtobufPort intValue]];
    
    [[XmppImManager sharedInstance] setLoginType:self.imLoginType];
    QIMWarnLog(@"\n ProtocolType : %d \n Domain : %@\n LoginType : %lu\n HostAddress : %@\n Port : %d\n ", [[XmppImManager sharedInstance] protocolType], [[XmppImManager sharedInstance] domain], (unsigned long)self.imLoginType, [[XmppImManager sharedInstance] hostName], [[XmppImManager sharedInstance] port]);
}

- (void)checkClientConfig {
    
    NSString *title = @"";
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
        title = @"qchat";
    } else if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQTalk) {
        title = @"qtalk";
    } else {
        title = @"startalk";
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/config/check_config.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSURL *requestUrl = [NSURL URLWithString:url];
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];

    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    
    NSMutableDictionary *bodyProperties = [NSMutableDictionary dictionary];
    [bodyProperties setObject:[[QIMAppInfo sharedInstance] AppBuildVersion] forKey:@"v"];
    [bodyProperties setObject:title forKey:@"ver"];
    [bodyProperties setObject:@"ios" forKey:@"p"];
    NSInteger clientVersion = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kCheckConfigVersion] integerValue];
    [bodyProperties setObject:[NSString stringWithFormat:@"%lld", (clientVersion > 0) ? clientVersion : 0] forKey:@"cv"];
    [bodyProperties setQIMSafeObject:[[QIMAppSetting sharedInstance] currentLanguage] forKey:@"language"];
    
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPBody:[[QIMJSONSerializer sharedInstance] serializeObject:bodyProperties error:nil]];
    [request setHTTPRequestHeaders:cookieProperties];
    
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSDictionary *resDic = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
            if (resDic.count > 0) {
                NSInteger errcode = [[resDic objectForKey:@"errcode"] integerValue];
                if (errcode == 0) {
                    if (nil == self.clientConfigDic) {
                        self.clientConfigDic = [NSMutableDictionary dictionaryWithCapacity:3];
                    }
                    NSDictionary *dataDic = [resDic objectForKey:@"data"];
                    if (dataDic.count) {
                        self.clientConfigDic = [NSMutableDictionary dictionaryWithDictionary:dataDic];
                        [[QIMUserCacheManager sharedInstance] setUserObject:self.clientConfigDic forKey:kNewClinetConfigDic];
                        NSInteger cvVersion = [dataDic objectForKey:@"version"];
                        [[QIMUserCacheManager sharedInstance] setUserObject:@(cvVersion) forKey:kCheckConfigVersion];
                    }
                }
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (NSArray *)trdExtendInfo {
    return [self.clientConfigDic objectForKey:@"trdextendmsg"];
}

- (NSString *)getCompany {
    return [self.clientConfigDic objectForKey:@"company"];
}

- (NSString *)aaCollectionUrlHost {
    NSDictionary *otherConfig = [self.clientConfigDic objectForKey:@"otherconfig"];
    return [otherConfig objectForKey:@"aacollectionurl"];
}

- (NSString *)redPackageUrlHost {
    NSDictionary *otherConfig = [self.clientConfigDic objectForKey:@"otherconfig"];
    return [otherConfig objectForKey:@"redpackageurl"];
}

- (NSString *)redPackageBalanceUrl {
    NSDictionary *otherConfig = [self.clientConfigDic objectForKey:@"otherconfig"];
    return [otherConfig objectForKey:@"balanceurl"];
}

- (NSString *)myRedpackageUrl {
    NSDictionary *otherConfig = [self.clientConfigDic objectForKey:@"otherconfig"];
    return [otherConfig objectForKey:@"myredpackageurl"];
}

#pragma mark get user agent

- (NSString *)getDefaultUserAgentString {
    @synchronized (self) {

        if (!self.defaultUserAgent) {

            NSBundle *bundle = [NSBundle bundleForClass:[self class]];

            // Attempt to find a name for this application
            NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            if (!appName) {
                appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
            }

            NSData *latin1Data = [appName dataUsingEncoding:NSUTF8StringEncoding];
            appName = [[NSString alloc] initWithData:latin1Data encoding:NSISOLatin1StringEncoding];

            if (!appName) {
                return nil;
            }

            NSString *appVersion = nil;
            NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
            if (marketingVersionNumber && developmentVersionNumber) {
                if ([marketingVersionNumber isEqualToString:developmentVersionNumber]) {
                    appVersion = marketingVersionNumber;
                } else {
                    appVersion = [NSString stringWithFormat:@"%@ rv:%@",marketingVersionNumber,developmentVersionNumber];
                }
            } else {
                appVersion = (marketingVersionNumber ? marketingVersionNumber : developmentVersionNumber);
            }

            NSString *deviceName;
            NSString *OSName;
            NSString *OSVersion;
            NSString *locale = [[NSLocale currentLocale] localeIdentifier];

            #if TARGET_OS_IPHONE
                UIDevice *device = [UIDevice currentDevice];
                deviceName = [device model];
                OSName = [device systemName];
                OSVersion = [device systemVersion];

            #else
                deviceName = @"Macintosh";
                OSName = @"Mac OS X";

                // From http://www.cocoadev.com/index.pl?DeterminingOSVersion
                OSErr err;
                SInt32 versionMajor, versionMinor, versionBugFix;
                err = Gestalt(gestaltSystemVersionMajor, &versionMajor);
                if (err != noErr) return nil;
                err = Gestalt(gestaltSystemVersionMinor, &versionMinor);
                if (err != noErr) return nil;
                err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix);
                if (err != noErr) return nil;
                OSVersion = [NSString stringWithFormat:@"%u.%u.%u", versionMajor, versionMinor, versionBugFix];
            #endif

            // Takes the form "My Application 1.0 (Macintosh; Mac OS X 10.5.7; en_GB)"
            self.defaultUserAgent = [NSString stringWithFormat:@"%@ %@ (%@; %@ %@; %@)", appName, appVersion, deviceName, OSName, OSVersion, locale];
        }
        return self.defaultUserAgent;
    }
    return nil;
}

//新消息提醒
- (BOOL)isNewMsgNotify {
    BOOL state = [[QIMManager sharedInstance] getLocalMsgNotifySettingWithIndex:QIMMSGSETTINGSOUND_INAPP];
    return state;
}

- (void)setNewMsgNotify:(BOOL)flag {
    [self setMsgNotifySettingWithIndex:QIMMSGSETTINGSOUND_INAPP WithSwitchOn:flag withCallBack:nil];
}

//新消息震动
- (BOOL)isNewMsgVibrate {
    BOOL state = [[QIMManager sharedInstance] getLocalMsgNotifySettingWithIndex:QIMMSGSETTINGVIBRATE_INAPP];
    return state;
}

- (void)setNewMsgVibrate:(BOOL)flag {
    [self setMsgNotifySettingWithIndex:QIMMSGSETTINGVIBRATE_INAPP WithSwitchOn:flag withCallBack:nil];
}

//相册是否发送原图
- (BOOL)pickerPixelOriginal {
    NSNumber *flagNum = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"pickerPixelOriginal"];
    if (flagNum == nil) {
        flagNum = @(YES);
        [self setPickerPixelOriginal:YES];
    }
    return [flagNum boolValue];
}

- (void)setPickerPixelOriginal:(BOOL)flag {
    [[QIMUserCacheManager sharedInstance] setUserObject:@(flag) forKey:@"pickerPixelOriginal"];
}

//OPS发现页RN调试
- (NSString *)opsFoundRNDebugUrl {
    NSString *opsFoundRNDebugUrl = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"opsFoundRNDebugUrl"];
    return opsFoundRNDebugUrl;
}

- (void)setOpsFoundRNDebugUrl:(NSString *)opsFoundRNDebugUrl {
    [[QIMUserCacheManager sharedInstance] setUserObject:opsFoundRNDebugUrl forKey:@"opsFoundRNDebugUrl"];
}

//qtalk发现页测试地址
- (NSString *)qtalkFoundRNDebugUrl {
    NSString *qtalkFoundRNDebugUrl = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"qtalkFoundRNDebugUrl"];
    return qtalkFoundRNDebugUrl;
}

- (void)setQtalkFoundRNDebugUrl:(NSString *)qtalkFoundRNDebugUrl {
    [[QIMUserCacheManager sharedInstance] setUserObject:qtalkFoundRNDebugUrl forKey:@"qtalkFoundRNDebugUrl"];
}

//qtalk搜索测试地址
- (NSString *)qtalkSearchRNDebugUrl {
    NSString *qtalkSearchRNDebugUrl = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"qtalkSearchRNDebugUrl"];
    return qtalkSearchRNDebugUrl;
}

- (void)setQtalkSearchRNDebugUrl:(NSString *)qtalkSearchRNDebugUrl {
    [[QIMUserCacheManager sharedInstance] setUserObject:qtalkSearchRNDebugUrl forKey:@"qtalkSearchRNDebugUrl"];
}

//是否优先展示对方个性签名
- (BOOL)moodshow {
    NSNumber *flagNum = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"moodshow"];
    if (flagNum == nil) {
        flagNum = @(YES);
        [self setMoodshow:YES];
    }
    return [flagNum boolValue];
}

- (void)setMoodshow:(BOOL)flag {
    [[QIMUserCacheManager sharedInstance] setUserObject:@(flag) forKey:@"moodshow"];
}

//是否展示水印
- (BOOL)waterMarkState {
    NSNumber *flagNum = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"waterMarkState"];
    if (flagNum == nil) {
        flagNum = @(YES);
        [self setWaterMarkState:YES];
    }
    return [flagNum boolValue];
}

- (void)setWaterMarkState:(BOOL)flag {
    [[QIMUserCacheManager sharedInstance] setUserObject:@(flag) forKey:@"waterMarkState"];
}

//艾特消息
- (NSArray *)getHasAtMeByJid:(NSString *)jid {
    
    __block NSArray *array = nil;
    dispatch_block_t block = ^{
        if (!_hasAtMeDic) {
            _hasAtMeDic = [[IMDataManager qimDB_SharedInstance] qimDB_getTotalAtMessageDic];
        }
        array = [_hasAtMeDic objectForKey:jid];
    };
    
    if (dispatch_get_specific(_atMeCacheTag))
        block();
    else
        dispatch_sync(_atMeCacheQueue, block);
    return array;
}

- (void)updateAtMeMessageWithJid:(NSString *)groupId withMsgIds:(NSArray *)msgIds withReadState:(QIMAtMsgReadState)readState {
    dispatch_block_t block = ^{
        NSArray *groupAtArray = [_hasAtMeDic objectForKey:groupId];
        NSMutableArray *groupAtTempArray = [NSMutableArray arrayWithArray:groupAtArray];
        for (NSInteger i = 0; i < groupAtArray.count; i++) {
            NSDictionary *atMsgDic = [groupAtArray objectAtIndex:i];
            NSString *MsgId = [atMsgDic objectForKey:@"MsgId"];
            for (NSString *msgId in msgIds) {
                if ([MsgId isEqualToString:msgId]) {
                    [groupAtTempArray removeObjectAtIndex:i];
                }
            }
        }
        [_hasAtMeDic setQIMSafeObject:groupAtTempArray forKey:groupId];
//        [_hasAtMeDic removeObjectForKey:groupId];
        [[IMDataManager qimDB_SharedInstance] qimDB_UpdateAtMessageReadStateWithGroupId:groupId withMsgIds:msgIds withReadState:readState];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAtMeChange object:groupId];
        });
    };
    
    if (dispatch_get_specific(_atMeCacheTag)) {
        block();
    } else {
        dispatch_sync(_atMeCacheQueue, block);
    }
}

- (void)clearAtMeMessageWithJid:(NSString *)groupId {
    dispatch_block_t block = ^{
        [_hasAtMeDic removeObjectForKey:groupId];
        [[IMDataManager qimDB_SharedInstance] qimDB_UpdateAtMessageReadStateWithGroupId:groupId withReadState:QIMAtMsgHasReadState];
        dispatch_async(dispatch_get_main_queue(), ^{

            [[NSNotificationCenter defaultCenter] postNotificationName:kAtMeChange object:groupId];
        });
    };

    if (dispatch_get_specific(_atMeCacheTag)) {
        block();
    } else {
        dispatch_sync(_atMeCacheQueue, block);
    }
}

- (void)addOfflineAtMeMessageByJid:(NSString *)groupId withType:(QIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime {
    dispatch_block_t block = ^{
        _hasAtMeDic = nil;
        [[IMDataManager qimDB_SharedInstance] qimDB_insertAtMessageWithGroupId:groupId withType:atType withMsgId:msgId withMsgTime:msgTime];
        dispatch_async(dispatch_get_main_queue(), ^{

            [[NSNotificationCenter defaultCenter] postNotificationName:kAtMeChange object:groupId];
        });
    };
    
    if (dispatch_get_specific(_atMeCacheTag)) {
        block();
    } else {
        dispatch_sync(_atMeCacheQueue, block);
    }
}

- (void)addAtMeMessageByJid:(NSString *)groupId withType:(QIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime {
    dispatch_block_t block = ^{
        
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[_hasAtMeDic objectForKey:groupId]];
        if (arr == nil) {
            
            arr = [NSMutableArray arrayWithArray:[[IMDataManager qimDB_SharedInstance] qimDB_getAtMessageWithGroupId:groupId]];
            NSMutableDictionary *atMessageDic = [NSMutableDictionary dictionaryWithCapacity:3];
            [atMessageDic setQIMSafeObject:groupId forKey:@"GroupId"];
            [atMessageDic setQIMSafeObject:msgId forKey:@"MsgId"];
            [atMessageDic setQIMSafeObject:@(atType) forKey:@"Type"];
            [atMessageDic setQIMSafeObject:@(msgTime) forKey:@"MsgDate"];
            [atMessageDic setQIMSafeObject:@(QIMAtMsgNotReadState) forKey:@"ReadState"];
            [arr addObject:atMessageDic];
            [_hasAtMeDic setObject:arr forKey:groupId];
        } else {
            NSMutableDictionary *atMessageDic = [NSMutableDictionary dictionaryWithCapacity:3];
            [atMessageDic setQIMSafeObject:groupId forKey:@"GroupId"];
            [atMessageDic setQIMSafeObject:msgId forKey:@"MsgId"];
            [atMessageDic setQIMSafeObject:@(atType) forKey:@"Type"];
            [atMessageDic setQIMSafeObject:@(msgTime) forKey:@"MsgDate"];
            [atMessageDic setQIMSafeObject:@(QIMAtMsgNotReadState) forKey:@"ReadState"];
            [arr addObject:atMessageDic];
            [_hasAtMeDic setObject:arr forKey:groupId];
        }
        [[IMDataManager qimDB_SharedInstance] qimDB_insertAtMessageWithGroupId:groupId withType:atType withMsgId:msgId withMsgTime:msgTime];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAtMeChange object:groupId];
        });
    };
    
    if (dispatch_get_specific(_atMeCacheTag)) {
        block();
    } else {
        dispatch_sync(_atMeCacheQueue, block);
    }
}

#pragma mark - 输入框草稿
- (NSDictionary *)getNotSendTextByJid:(NSString *)jid {
    
    return [_notSendTextDic objectForKey:jid];
}

- (void)setNotSendText:(NSString *)text inputItems:(NSArray *)inputItems ForJid:(NSString *)jid {
    
    if (!jid) {
        
        return;
    }
    if (text.length > 0) {
        
        [_notSendTextDic setQIMSafeObject:@{@"text": text ? text : @"", @"inputItems": inputItems ? inputItems : [NSArray array]} forKey:jid];
        [[QIMUserCacheManager sharedInstance] setUserObject:_notSendTextDic forKey:kNotSendTextDic];
    } else {
        
        [_notSendTextDic removeObjectForKey:jid];
        [[QIMUserCacheManager sharedInstance] setUserObject:_notSendTextDic forKey:kNotSendTextDic];
    }
}

- (void)getQChatTokenWithBusinessLineName:(NSString *)businessLineName withCallBack:(QIMKitGetQChatTokenSuccessBlock)callback {
    
    NSString *desturl = [[QIMNavConfigManager sharedInstance] getQChatGetTKUrl];
    NSDictionary *params = @{@"macCode": [[QIMAppInfo sharedInstance] macAddress], @"plat": (businessLineName.length > 0) ? businessLineName : @"app"};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    [self sendTPPOSTRequestWithUrl:desturl withRequestBodyData:data withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *resultDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[resultDic objectForKey:@"ret"] boolValue];
        if (ret) {
            if (callback) {
                callback([resultDic objectForKey:@"data"]);
            }
        } else {
            if (callback) {
                callback(nil);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(nil);
        }
    }];
}

- (NSDictionary *)getQVTForQChat {
    
    NSDictionary *qvtInfoDic = [[QIMUserCacheManager sharedInstance] userObjectForKey:kQVTCookie];
    return qvtInfoDic;
}

- (void)removeQVTForQChat {
    
    [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:kQVTCookie];
}

- (NSString *)getDownloadFilePath {
    
    return _downLoadFile;
}

- (void)clearcache {
    QIMWarnLog(@"清除cache");
    [_lastLoginTimeDic removeAllObjects];
}

- (void)setStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType withCallback:(QIMKitUpdateRemoteClientConfig)callback {
    
    NSDictionary *dict = @{@"topType":@(1), @"chatType":@(chatType)};
    NSString *value = [[QIMJSONSerializer sharedInstance] serializeObject:dict];
    [[QIMManager sharedInstance] updateRemoteClientConfigWithType:QIMClientConfigTypeKStickJidDic WithSubKey:combineJid WithConfigValue:value WithDel:NO withCallback:callback];
}

- (void)removeStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType withCallback:(QIMKitUpdateRemoteClientConfig)callback {
    NSDictionary *infoDic = @{@"chatType":@(chatType), @"topType":@(0)};
    NSString *infoStr = [[QIMJSONSerializer sharedInstance] serializeObject:infoDic];
    [self updateRemoteClientConfigWithType:QIMClientConfigTypeKStickJidDic WithSubKey:combineJid WithConfigValue:infoStr WithDel:YES withCallback:callback];
}

- (BOOL)isStickWithCombineJid:(NSString *)combineJid {
    if (!combineJid.length) {
        return NO;
    }
    if (!self.stickJidDic) {
        self.stickJidDic = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    __block BOOL result = NO;
    NSInteger stickState = [[self.stickJidDic objectForKey:combineJid] integerValue];
    if (stickState == 0) {
        NSInteger tempStickState = [[QIMManager sharedInstance] getClientConfigDeleteFlagWithType:QIMClientConfigTypeKStickJidDic WithSubKey:combineJid];
        if (tempStickState == 0) {
            stickState = YES;
            dispatch_block_t block = ^{
                
                [self.stickJidDic setQIMSafeObject:@(1) forKey:combineJid];
            };
            if (dispatch_get_specific(self.cacheTag))
                block();
            else
                dispatch_sync(self.cacheQueue, block);
        } else {
            stickState = NO;
            dispatch_block_t block = ^{
                
                [self.stickJidDic setQIMSafeObject:@(-1) forKey:combineJid];
            };
            if (dispatch_get_specific(self.cacheTag))
                block();
            else
                dispatch_sync(self.cacheQueue, block);
        }
    } else if (stickState == -1) {
        stickState = NO;
    } else {
        stickState = NSNotFound;
    }
    result = stickState;
    return result;
}

- (NSDictionary *)stickList {
    
    return [[QIMManager sharedInstance] getClientConfigDicWithType:QIMClientConfigTypeKStickJidDic];
}

- (void)setMsgNotifySettingWithIndex:(QIMMSGSETTING)setting WithSwitchOn:(BOOL)switchOn withCallBack:(QIMKitSetMsgNotifySettingSuccessBlock)callback{
    /*
http://url/push/qtapi/token/setmsgsettings.qunar?username=hubo.hu&domain=ejabhost1&os=android&version=205&index=1&status=0‘
    
    参数：
    username=hubo.hu
    domain=ejabhost1
    os=android
    version=205
    index=1//开关标记
    status=0//开关状态  0：关 1、开
*/
    NSString *str = [NSString stringWithFormat:@"%@/push/qtapi/token/setmsgsettings.qunar?username=%@&domain=%@&os=ios&version=%@&index=%@&status=%@", [[QIMNavConfigManager sharedInstance] javaurl], [QIMManager getLastUserName], [[QIMNavConfigManager sharedInstance] domain], [[QIMAppInfo sharedInstance] AppBuildVersion], @(setting), @(switchOn)];
    [self sendTPGetRequestWithUrl:str withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSInteger localPushFlag = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"MsgSettings"] integerValue];
            localPushFlag = localPushFlag ^ setting;
            [[QIMUserCacheManager sharedInstance] setUserObject:@(localPushFlag) forKey:@"MsgSettings"];
            if (callback) {
                callback(YES);
            }
        } else {
            if (callback) {
                callback(NO);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(NO);
        }
    }];
}

- (BOOL)getLocalMsgNotifySettingWithIndex:(QIMMSGSETTING)setting {
    NSInteger localPushFlag = 0;
    if (![[QIMUserCacheManager sharedInstance] containsObjectForKey:@"MsgSettings"]) {
        localPushFlag = QIMMSGSETTINGPUSH_SWITCH;
    } else {
        localPushFlag = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"MsgSettings"] integerValue];
    }
    BOOL state = (setting & localPushFlag);
    return state;
}

- (void)getMsgNotifyRemoteSettings {
    NSString *str = [NSString stringWithFormat:@"%@/push/qtapi/token/getmsgsettings.qunar?username=%@&domain=%@&os=ios&version=%@", [[QIMNavConfigManager sharedInstance] javaurl], [QIMManager getLastUserName], [[QIMNavConfigManager sharedInstance] domain], [[QIMAppInfo sharedInstance] AppBuildVersion]];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:str]];
    [request setHTTPRequestHeaders:cookieProperties];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *responseData = response.data;
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
                    NSDictionary *pushStateDic = [result objectForKey:@"data"];
                    NSInteger pushFlag = [[pushStateDic objectForKey:@"push_flag"] integerValue];
                    [[QIMUserCacheManager sharedInstance] setUserObject:@(pushFlag) forKey:@"MsgSettings"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyRNAppSettingView object:nil];
                    });
                }
            });
        }
    } failure:^(NSError *error) {
        QIMErrorLog(@"请求客户端消息设置失败 : %@", error);
    }];
}

- (void)sendQChatOnlineNotification {
    NSString *str = [NSString stringWithFormat:@"%@/%@", [[QIMNavConfigManager sharedInstance] qcHost], @"css/online"];
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:str]];
    [QIMHTTPClient sendRequest:request complete:nil failure:nil];
}

- (void)sendNoPush {
    QIMErrorLog(@"注销Token");
    [[QIMAppInfo sharedInstance] setPushToken:nil];
}

- (void)sendServer:(NSString *)notificationToken withUsername:(NSString *)username withParamU:(NSString *)paramU withParamK:(NSString *)paramK WithDelete:(BOOL)deleteFlag withCallback:(QIMKitRegisterPushTokenSuccessBlock)callback {
    
    QIMVerboseLog(@"准备向帆哥服务器发送Push Token . Token : %@, 用户名 : %@, U = %@, K = %@", notificationToken, username, paramU, paramK);
    if (paramK.length <= 0 || !paramK) {
        paramK = [self updateRemoteLoginKey];
    }
    NSArray *userInfo = [username componentsSeparatedByString:@"@"];
    BOOL sendServerSuccess = NO;
    NSString *url = @"";
    if ([[QIMNavConfigManager sharedInstance] newPush] == NO) {
        url = [NSString stringWithFormat:@"%@/push/qtapi/token/setpersonmackey.qunar?username=%@&domain=%@&mac_key=%@&platname=%@_%@_%@&pkgname=%@&os=%@&version=%@&show_content=%@", [[QIMNavConfigManager sharedInstance] javaurl], [userInfo objectAtIndex:0], [userInfo objectAtIndex:1], notificationToken, [[[QIMAppInfo sharedInstance] deviceName] stringByReplacingOccurrencesOfString:@" " withString:@""], [[[NSLocale preferredLanguages][0] componentsSeparatedByString:@"-"] firstObject], [[NSLocale currentLocale] countryCode], [[NSBundle mainBundle] bundleIdentifier], @"ios", [[QIMAppInfo sharedInstance] AppBuildVersion], @(YES)];
    } else {
        url = [NSString stringWithFormat:@"%@/qtapi/token/setpersonmackey.qunar?username=%@&domain=%@&mackey=%@&os=%@&version=%@", [[QIMNavConfigManager sharedInstance] javaurl], [userInfo objectAtIndex:0], [userInfo objectAtIndex:1], notificationToken, @"ios", [[QIMAppInfo sharedInstance] AppBuildVersion]];
    }
    if (deleteFlag) {
        url = [url stringByReplacingOccurrencesOfString:@"set" withString:@"del"];
    }
    QIMVerboseLog(@"帆哥更新Token地址 : %@", url);
    [self sendTPGetRequestWithUrl:url withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        NSInteger ret = [[result objectForKey:@"ret"] integerValue];
        NSString *errmsg = [result objectForKey:@"errmsg"];
        if (errcode == 0 && ret) {
            QIMVerboseLog(@"=== 向帆哥服务器发送PushToken成功 === %@", result);
            if (callback) {
                callback(YES);
            }
        } else {
            if (callback) {
                callback(NO);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callback) {
            callback(NO);
        }
    }];
}

- (void)sendPushTokenWithMyToken:(NSString *)myToken WithDeleteFlag:(BOOL)deleteFlag withCallback:(QIMKitRegisterPushTokenSuccessBlock)callback {
    if ([QIMManager getLastUserName].length > 0) {
        if (self.remoteKey.length <= 0) {
            [self updateRemoteLoginKey];
        }
        if (self.remoteKey.length > 0) {
            [self sendServer:myToken
                withUsername:[self getLastJid]
                  withParamU:[self getLastJid]
                  withParamK:self.remoteKey
                  WithDelete:deleteFlag
                withCallback:callback];
        }
    }
}

- (void)checkClearCache {
    NSInteger clearCacheVersion = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kClearCacheCheck] integerValue];
    if (clearCacheVersion < kClearCacheVersion) {
        QIMErrorLog(@"clearCacheVersion : %lu", clearCacheVersion);
        [self clearcache];
        [[QIMUserCacheManager sharedInstance] setUserObject:@(kClearCacheVersion) forKey:kClearCacheCheck];
    }
}

- (void)findNewestClient {
    NSInteger updateAppVersion = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"updateAppVersion"] integerValue];
    if (updateAppVersion > 0 && updateAppVersion > [[[QIMAppInfo sharedInstance] AppBuildVersion] integerValue]) {
        
    } else {
        updateAppVersion = [[[QIMAppInfo sharedInstance] AppBuildVersion] integerValue];
    }
    NSString *destUrl = [NSString stringWithFormat:@"%@/nck/client/get_version.qunar?clientname=%@&ver=%ld&u=%@&d=%@", [[QIMNavConfigManager sharedInstance] newerHttpUrl], @"qtalk_ios", updateAppVersion, [QIMManager getLastUserName], [[QIMManager sharedInstance] getDomain]];

    [[QIMManager sharedInstance] sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
        if (ret && errcode==0) {
            NSDictionary *data = [responseDic objectForKey:@"data"];
            if ([data isKindOfClass:[NSDictionary class]] && data.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyUpdateAppVersion object:data];
                });
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

- (void)checkMsTimeInterval:(long long *)time {
    NSString *timeStr = [NSString stringWithFormat:@"%lld", *time];
    if (timeStr.length <= 10) {
        *time = (*time) * 1000;
    }
}

@end
