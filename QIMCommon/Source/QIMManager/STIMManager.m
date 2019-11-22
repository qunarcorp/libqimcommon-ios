 //
//  IMManager.m
//  qunarChatMac
//
//  Created by 平 薛 on 14-11-24.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import "STIMManager.h"
#import "STIMManager+Calendar.h"
#import "STIMManager+MiddleVirtualAccountManager.h"
#import "STIMManager+ClientConfig.h"
#import "STIMManager+Request.h"
#import "STIMManager+Collection.h"
#import "STIMManager+Consult.h"
#import "STIMManager+DB.h"
#import "STIMManager+UserMedal.h"
#import "STIMManager+PublicNavUserManager.h"
#import "STIMManager+Friend.h"
#import "STIMManager+Group.h"
#import "STIMManager+GroupMessage.h"
#import "STIMManager+Helper.h"
#import "STIMManager+KeyChain.h"
#import "STIMManager+Login.h"
#import "STIMManager+Message.h"
#import "STIMManager+MySelfStatus.h"
#import "STIMManager+NetWork.h"
#import "STIMManager+PublicRobot.h"
#import "STIMManager+resetLoginInfo.h"
#import "STIMManager+Session.h"
#import "STIMManager+SingleMessage.h"
#import "STIMManager+SystemMessage.h"
#import "STIMManager+UserVcard.h"
#import "STIMManager+Found.h"
#import "STIMManager+Search.h"
#import "STIMManager+XmppImManagerEvent.h"

#import "XmppImManager.h"

#import "STIMNotificationKeys.h"

#import "STIMJSONSerializer.h"

#import "STIMFileManager.h"
#import "STIMDESHelper.h"

#import <SystemConfiguration/CaptiveNetwork.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonCrypto.h>

#import "STIMUUIDTools.h"
#import "STIMAppSetting.h"
#import "STIMNetworkObserver.h"

#import "ASIDataCompressor.h"
#import "ASIDataDecompressor.h"
//#import "Database.h"

#import "STIMAppInfo.h"
#import "STIMUserCacheManager.h"
#import "STIMNavConfigManager.h"
#import "ASIHTTPRequest.h"
#import "STIMVoiceNoReadStateManager.h"

//Categories
#import "NSData+STIMBase64.h"
#import "NSString+STIMBase64.h"
#import "NSDate+STIMCategory.h"

#import "NSDateFormatter+STIMCategory.h"
#import "NSDate+STIMCategory.h"
#import "UIImage+STIMUtility.h"
#import "NSString+STIMUtility.h"
#import "NSMutableDictionary+STIMSafe.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif
#import "STIMHttpRequestMonitor.h"
#import "STIMWatchDog.h"

static STIMManager *__IMManager = nil;

@implementation STIMManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __IMManager = [[STIMManager alloc] init];
        [__IMManager initManager];
    });
    if (!__IMManager) {
        __IMManager = [[STIMManager alloc] init];
        [__IMManager initManager];
    }
    return __IMManager;
}

- (void)clearSTIMManager {
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
    
    [STIMNetworkObserver Instance];
    [self initAppCacheConfig];
    [[XmppImManager sharedInstance] setProductType:[[STIMAppInfo sharedInstance] appType]];
    [[XmppImManager sharedInstance] setAppVersion:[[STIMAppInfo sharedInstance] AppBuildVersion]];
    [[XmppImManager sharedInstance] setSystemVersion:[[STIMAppInfo sharedInstance] SystemVersion]];
    [[XmppImManager sharedInstance] setPlatform:[[STIMAppInfo sharedInstance] Platform]];
    [[XmppImManager sharedInstance] setDeviceName:[[STIMAppInfo sharedInstance] deviceName]];
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
        NSDictionary *dic = [[STIMUserCacheManager sharedInstance] userObjectForKey:kStickJidDic];
        if (dic) {
            [_stickJidDic setDictionary:dic];
        }
    }
    
    {
        _conversationParamDic = [NSMutableDictionary dictionary];
        NSDictionary *dic = [[STIMUserCacheManager sharedInstance] userObjectForKey:kConversationParamDic];
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
        NSDictionary *dic = [[STIMUserCacheManager sharedInstance] userObjectForKey:kUserBigHeaderDic];
        if (dic) {
            [_userBigHeaderDic setDictionary:dic];
        }
    }
    _hotCommentUUIdsDic = [NSMutableDictionary dictionaryWithCapacity:2];
    _userNormalHeaderDic = [NSMutableDictionary dictionaryWithCapacity:5];
    
    _userInfoDic = [NSMutableDictionary dictionaryWithCapacity:5];
    
    _notSendTextDic = [NSMutableDictionary dictionary];
    {
        NSDictionary *dic = [[STIMUserCacheManager sharedInstance] userObjectForKey:kNotSendTextDic];
        [_notSendTextDic setDictionary:dic];
    }
    
    self.clientConfigDic = [NSMutableDictionary dictionary];
    {
        NSDictionary *dic = [[STIMUserCacheManager sharedInstance] userObjectForKey:kNewClinetConfigDic];
        if (dic) {
            self.clientConfigDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        }
    }
    
    _chatIdInfoDic = [NSMutableDictionary dictionary];
    {
        NSDictionary *dic = [[STIMUserCacheManager sharedInstance] userObjectForKey:kChannelInfoDic];
        if (dic) {
            [_chatIdInfoDic setDictionary:dic];
        }
    }
    if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeQChat) {
        _channelInfoDic = [NSMutableDictionary dictionary];
        {
            NSDictionary *dic = [[STIMUserCacheManager sharedInstance] userObjectForKey:kChannelInfoDic];
            if (dic) {
                [_channelInfoDic setDictionary:dic];
            }
        }
        
        _appendInfoDic = [NSMutableDictionary dictionary];
        {
            NSDictionary *dic = [[STIMUserCacheManager sharedInstance] userObjectForKey:kAppendInfoDic];
            if (dic) {
                [_appendInfoDic setDictionary:dic];
            }
        }
    }
    _soundName = [[STIMManager sharedInstance] getClientNotificationSoundName];
}

@end

@implementation STIMManager (RegisterEvent)

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
    STIMVerboseLog(@"初始化一下日志统计组件");
    Class autoTrackerDataManager = NSClassFromString(@"STIMAutoTrackerDataManager");
    [autoTrackerDataManager performSelector:@selector(stIMDB_sharedLogDBInstanceWithDBFullJid:) withObject:[[STIMManager sharedInstance] getLastJid]];
    
    NSOperationQueue *loginComplateQueue = [[NSOperationQueue alloc] init];
    [loginComplateQueue setMaxConcurrentOperationCount:1];
    loginComplateQueue.name = @"loginComplateQueue";
    STIMVerboseLog(@"self.loginComplateQueue State : %d", loginComplateQueue.isSuspended);
    STIMVerboseLog(@"self.loginComplateQueue Opertions1 : %@", loginComplateQueue.operations);
    [loginComplateQueue cancelAllOperations];
    STIMVerboseLog(@"self.loginComplateQueue Opertions2 : %@", loginComplateQueue.operations);

    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loginComplateOperation) object:nil];
    [operation setCompletionBlock:^{
        STIMVerboseLog(@"loginComplateOperation执行完事");
    }];
    [loginComplateQueue addOperation:operation];
    STIMVerboseLog(@"self.loginComplateQueue Opertions3 : %@", loginComplateQueue.operations);
}

- (void)loginComplateOperation {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginState object:[NSNumber numberWithBool:YES]];
    [self updateAppWorkState:AppWorkState_Updating];
    self.notNeedCheckNetwotk = NO;
    self.needTryRelogin = YES;
    STIMVerboseLog(@"<Method: %s, Set _needTryRelogin == YES>", __func__);
    //重置消息是否最新Flag
    _latestGroupMessageFlag = YES;
    _latestSingleMessageFlag = YES;
    _latestSystemMessageFlag = YES;
    
    [[STIMUserCacheManager sharedInstance] setCacheName:[[STIMManager sharedInstance] getLastJid]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *userName = [[STIMUserCacheManager sharedInstance] userObjectForKey:kLastUserId];
        NSString *userFullJid = [userName stringByAppendingFormat:@"@%@", [[XmppImManager sharedInstance] domain]];
        [[STIMUserCacheManager sharedInstance] setUserObject:userFullJid forKey:@"kFullUserJid"];
        STIMVerboseLog(@"LoginComplate 之后的userFullJid : %@", userFullJid);
        NSString *tempUserToken = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"kTempUserToken"];
//        [[STIMUserCacheManager sharedInstance] setUserObject:tempUserToken?tempUserToken:@"" forKey:@"userToken"];
        [self updateLastUserToken:tempUserToken];
        STIMVerboseLog(@"LoginComplate 之后的tempUserToken : %@", tempUserToken);
#warning NavDict NavConfig
        NSDictionary *currentLoginNavConfig = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"NavConfig"];
        NSDictionary *currentNavDict = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"QC_CurrentNavDict"];
        NSDictionary *navDict = @{@"NavConfig":currentLoginNavConfig?currentLoginNavConfig:@{}, @"NavUrl":currentNavDict?currentNavDict : @{}};
        [self addUserCacheWithUserId:userName WithUserFullJid:userFullJid WithNavDict:navDict];
        
        NSString *oldLoginUser = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"LastestLoginUser"];
        if (oldLoginUser && ![oldLoginUser isEqualToString:[[STIMManager sharedInstance] getLastJid]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                STIMVerboseLog(@"抛出通知 : kNotifySwichUserSuccess");
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySwichUserSuccess object:@(YES)];
            });
        }
        [[STIMUserCacheManager sharedInstance] setUserObject:[[STIMManager sharedInstance] getLastJid] forKey:@"LastestLoginUser"];
    });
    STIMVerboseLog(@"userDocuments : %@", UserDocumentsPath);
    STIMVerboseLog(@"userPath : %@", UserPath);
    //防止数据库及Beta环境本地路径出错
    _imageCachePath = [UserCachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/imageCache/"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_imageCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_imageCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    _downLoadFile = [UserCachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/imageCache/"]];

    if (![[NSFileManager defaultManager] fileExistsAtPath:_downLoadFile]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_downLoadFile withIntermediateDirectories:YES attributes:nil error:nil];
    }

    STIMVerboseLog(@"开始获取单人历史记录2");
    CFAbsoluteTime startTime1 = [[STIMWatchDog sharedInstance] startTime];
    [self updateOfflineMessagesV2];
    STIMVerboseLog(@"获取单人历史记录2loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime1]);
    STIMVerboseLog(@"获取单人历史记录结束2");

    STIMVerboseLog(@"开始获取消息已读状态2");
    CFAbsoluteTime startTime2 = [[STIMWatchDog sharedInstance] startTime];
    [self getReadFlag];
    STIMVerboseLog(@"获取消息已读状态2loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime2]);
    STIMVerboseLog(@"获取消息已读状态结束2");

    dispatch_async(dispatch_get_main_queue(), ^{
        STIMVerboseLog(@"强制刷一下单聊会话框界面的消息开始2");
        [[NSNotificationCenter defaultCenter] postNotificationName:kSingleChatMsgReloadNotification object:nil];
        STIMVerboseLog(@"强制刷一下单聊会话框界面的消息结束2");
    });

    STIMVerboseLog(@"开始获取群历史记录2");
    CFAbsoluteTime startTime3 = [[STIMWatchDog sharedInstance] startTime];
    [self updateOfflineGroupMessages];
    STIMVerboseLog(@"获取群历史记录2loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime3]);
    STIMVerboseLog(@"获取群历史记录结束2");

    dispatch_async(dispatch_get_main_queue(), ^{
        STIMVerboseLog(@"强制刷新列表页");
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:@"ForceRefresh"];
        STIMVerboseLog(@"强制刷新列表页结束");
        
        STIMVerboseLog(@"强制刷一下群聊会话框界面的消息开始2");
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupChatMsgReloadNotification object:nil];
        STIMVerboseLog(@"强制刷一下群聊会话框界面的消息结束2");
    });
    [self updateAppWorkState:AppWorkState_Login];
    STIMVerboseLog(@"主页Title已经更新为登录完成");
    
    STIMVerboseLog(@"开始获取群阅读指针2");
    CFAbsoluteTime startTime4 = [[STIMWatchDog sharedInstance] startTime];
    [self updateMucReadMark];
    STIMVerboseLog(@"获取群阅读指针2loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime4]);
    STIMVerboseLog(@"获取群阅读指针结束2");
    dispatch_async(dispatch_get_main_queue(), ^{
        STIMVerboseLog(@"获取阅读指针之后再次强制刷新列表页");
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:@"ForceRefresh"];
        STIMVerboseLog(@"获取阅读指针之后再次强制刷新列表页结束");
    });
    STIMVerboseLog(@"同步消息完成耗时 : %lf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime1]);

    STIMVerboseLog(@"开始获取系统历史记录2");
    CFAbsoluteTime startTime5 = [[STIMWatchDog sharedInstance] startTime];
    [self updateOfflineSystemNoticeMessages];
    STIMVerboseLog(@"获取系统历史记录2loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime5]);
    STIMVerboseLog(@"获取系统历史记录结束2");
    
    [[IMDataManager stIMDB_SharedInstance] stIMDB_updateMessageFromState:STIMMessageSendState_Waiting ToState:STIMMessageSendState_Faild];
    STIMVerboseLog(@"开始同步服务端漫游的个人配置2");
    CFAbsoluteTime startTime6 = [[STIMWatchDog sharedInstance] startTime];
    [self getRemoteClientConfig];
    STIMVerboseLog(@"同步服务端漫游的个人配置2loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime6]);
    STIMVerboseLog(@"同步服务端漫游的个人配置完成2");
    
    if ([[STIMAppInfo sharedInstance] appType] != STIMProjectTypeQChat) {
        STIMVerboseLog(@"开始获取我的关联账户2");
        CFAbsoluteTime startTime7 = [[STIMWatchDog sharedInstance] startTime];
        [self getRemoteCollectionAccountList];
        STIMVerboseLog(@"获取我的关联账户2loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime7]);
        
        STIMVerboseLog(@"开始同步公众号列表2");
        CFAbsoluteTime startTime8 = [[STIMWatchDog sharedInstance] startTime];
        [self updatePublicNumberList];
        STIMVerboseLog(@"同步公众号列表2loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime8]);
        STIMVerboseLog(@"同步公众号列表完成2");
    }
    
    STIMVerboseLog(@"开始Check组织架构2");
    CFAbsoluteTime startTime9 = [[STIMWatchDog sharedInstance] startTime];
    [self updateOrganizationalStructure];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotifyNotificationReloadOrganizationalStructure" object:nil];
    });
    STIMVerboseLog(@"Check组织架构2loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime9]);
    STIMVerboseLog(@"Check组织架构结束2");

    STIMVerboseLog(@"开始请求增量群列表");
    CFAbsoluteTime startTime10 = [[STIMWatchDog sharedInstance] startTime];
    [self quickJoinAllGroup];
    STIMVerboseLog(@"快速入群完成2loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime10]);
    STIMVerboseLog(@"快速入群完成2");

    STIMVerboseLog(@"开始获取增量群名片");
    [self getIncrementGroupCards];
    STIMVerboseLog(@"获取增量群名片完成");

    STIMVerboseLog(@"开始TCP发送已送达消息状态2");
    CFAbsoluteTime startTime11 = [[STIMWatchDog sharedInstance] startTime];
    [self sendRecevieMessageState];
    STIMVerboseLog(@"TCP发送已送达消息状态2loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime11]);
    STIMVerboseLog(@"TCP发送已送达消息状态结束2");
    
    STIMVerboseLog(@"开始同步消息推送设置2");
    CFAbsoluteTime startTime12 = [[STIMWatchDog sharedInstance] startTime];
    [self getMsgNotifyRemoteSettings];
    STIMVerboseLog(@"同步消息推送设置2loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime12]);
    STIMVerboseLog(@"同步同步消息推送设置2");
    
    [self checkClientConfig];

    STIMVerboseLog(@"开始获取加密会话密码箱2");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotifyNotificationGetRemoteEncrypt" object:nil];
    });
    STIMVerboseLog(@"开始获取加密会话密码箱2结束");
    
    CFAbsoluteTime startTime13 = [[STIMWatchDog sharedInstance] startTime];
    [self sendPushTokenWithMyToken:[[STIMAppInfo sharedInstance] getPushToken] WithDeleteFlag:NO];
    STIMVerboseLog(@"注册Token1loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime13]);
    
    // 更新好友列表
    CFAbsoluteTime startTime14 = [[STIMWatchDog sharedInstance] startTime];
    [self updateFriendList];
    STIMVerboseLog(@"更新好友列表loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime14]);
    
    CFAbsoluteTime startTime15 = [[STIMWatchDog sharedInstance] startTime];
    [self updateFriendInviteList];
    STIMVerboseLog(@"邀请好友申请loginComplate耗时 : %llf", [[STIMWatchDog sharedInstance] escapedTimewithStartTime:startTime15]);
    
    if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeQChat) {
        STIMVerboseLog(@"客服获取快捷回复");
        [self getRemoteQuickReply];
    };
    
    if ([[STIMNavConfigManager sharedInstance] showOA] == YES) {
        STIMVerboseLog(@"开始获取行程区域");
        [self getRemoteAreaList];
        STIMVerboseLog(@"结束获取行程区域");
        
        STIMVerboseLog(@"开始获取用户行程列表");
        [self getRemoteUserTripList];
        STIMVerboseLog(@"结束获取用户行程列表");
    }
    [self updateMyCard];

    if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeQChat) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            if ([self isMerchant]) {
                //客服发送上线通知
                STIMVerboseLog(@"客服发送上线通知");
                [self sendQChatOnlineNotification];
            }
        });
    }
    
    if ([[STIMAppInfo sharedInstance] appType] != STIMProjectTypeQChat) {
        
        STIMVerboseLog(@"登录之后请求一下驼圈入口开关");
        [self getCricleCamelEntrance];
        STIMVerboseLog(@"登录之后请求一下驼圈视频配置");
        [self getCricleCamelVideoConfig];
        
        STIMVerboseLog(@"登录之后获取一下驼圈提醒开关");
        [self getRemoteWorkMomentSwitch];
        
        STIMVerboseLog(@"登录之后请求一下驼圈未读消息");
        [self getupdateRemoteWorkNoticeMsgs];
        
    
        STIMVerboseLog(@"登录之后请求热线账户列表");
        [self getRemoteHotlineShopList];
        
        STIMVerboseLog(@"登录之后获取发现页应用列表");
        [self getRemoteFoundNavigation];
        
        STIMVerboseLog(@"登录之后获取勋章列表");
        [self getRemoteMedalList];
        
        STIMVerboseLog(@"登录之后获取我的勋章列表");
        [self getRemoteUserMedalListWithUserId:[[STIMManager sharedInstance] getLastJid]];
    }
    if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeQTalk) {
        STIMVerboseLog(@"登录之后请求一下骆驼帮未读数");
        
        [[STIMManager sharedInstance] getExploreNotReaderCount];
    }
    
    if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeStartalk && [[STIMAppInfo sharedInstance] applicationState] == STIMApplicationStateLaunch) {
        STIMVerboseLog(@"请求新版本");
//        [self findNewestClient];
    }

    STIMVerboseLog(@"登录之后主动上报日志");
    Class autoTracker = NSClassFromString(@"STIMAutoTrackerOperation");
    id autoTrackerObject = [[autoTracker alloc] init];
    [autoTrackerObject performSelectorInBackground:@selector(uploadTracerData) withObject:nil];
}

- (void)generateClientConfigUpgradeArrayWithType:(STIMClientConfigType)type WithArray:(id)valueArr {
    if (!self.clientConfigUpgradeArray) {
        self.clientConfigUpgradeArray = [NSMutableArray arrayWithCapacity:3];
    }
    switch (type) {
        case STIMClientConfigTypeKMarkupNames: {
            NSDictionary *valueDic = (NSDictionary *)valueArr;
            for (NSString *xmppId in [valueDic allKeys]) {
                if (xmppId.length > 0) {
                    NSString *remarkName = [valueDic objectForKey:xmppId];
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
                    [dict setSTIMSafeObject:[self transformClientConfigKeyWithType:type] forKey:@"key"];
                    [dict setSTIMSafeObject:remarkName forKey:@"value"];
                    [dict setSTIMSafeObject:xmppId forKey:@"subkey"];
                    [self.clientConfigUpgradeArray addObject:dict];
                }
            }
        }
            break;
        case STIMClientConfigTypeKCollectionCacheKey: {
            NSArray *valueArray = (NSArray *)valueArr;
            for (NSDictionary *dic in valueArray) {
                NSString *configKey = [self transformClientConfigKeyWithType:type];
                NSString *configValue = dic[@"httpUrl"];
                NSString *subKey = [[STIMFileManager sharedInstance] md5fromUrl:configValue];
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
                [dict setSTIMSafeObject:configKey forKey:@"key"];
                [dict setSTIMSafeObject:configValue forKey:@"value"];
                [dict setSTIMSafeObject:subKey forKey:@"subkey"];
                [self.clientConfigUpgradeArray addObject:dict];
            }
        }
            break;
        case STIMClientConfigTypeKStickJidDic: {
            NSString *valueStr = (NSString *)valueArr;
            NSDictionary *valueDic = [[STIMJSONSerializer sharedInstance] deserializeObject:valueStr error:nil];
            for (NSString *xmppId in [valueDic allKeys]) {
                if (xmppId.length <= 0) {
                    continue;
                }
                NSString *combineJid = [NSString stringWithFormat:@"%@<>%@", xmppId, xmppId];
                ChatType chatType = [xmppId containsString:@"conference."] ? ChatType_GroupChat : ChatType_SingleChat;
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
                NSDictionary *chatTypeDict = @{@"chatType":@(chatType)};
                [dict setSTIMSafeObject:[self transformClientConfigKeyWithType:type] forKey:@"key"];
                [dict setSTIMSafeObject:[[STIMJSONSerializer sharedInstance] serializeObject:chatTypeDict] forKey:@"value"];
                [dict setSTIMSafeObject:combineJid forKey:@"subkey"];
                [self.clientConfigUpgradeArray addObject:dict];
            }
        }
            break;
        case STIMClientConfigTypeKNotificationSetting: {
            
        }
            break;
        case STIMClientConfigTypeKConversationParamDic: {
            
        }
            break;
        case STIMClientConfigTypeKQuickResponse: {
            
        }
            break;
        case STIMClientConfigTypeKChatColorInfo: {
            NSDictionary *valueDict = (NSDictionary *)valueArr;
            NSString *configKey = [self transformClientConfigKeyWithType:type];
            NSString *configValue = [[STIMJSONSerializer sharedInstance] serializeObject:valueDict];
            NSString *subKey = [[STIMManager sharedInstance] getLastJid];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
            [dict setSTIMSafeObject:configKey forKey:@"key"];
            [dict setSTIMSafeObject:configValue forKey:@"value"];
            [dict setSTIMSafeObject:subKey forKey:@"subkey"];
            [self.clientConfigUpgradeArray addObject:dict];
        }
            break;
        case STIMClientConfigTypeKCurrentFontInfo: {
            NSDictionary *valueDict = (NSDictionary *)valueArr;
            NSString *configKey = [self transformClientConfigKeyWithType:type];
            NSString *configValue = [[STIMJSONSerializer sharedInstance] serializeObject:valueDict];
            NSString *subKey = [[STIMManager sharedInstance] getLastJid];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
            [dict setSTIMSafeObject:configKey forKey:@"key"];
            [dict setSTIMSafeObject:configValue forKey:@"value"];
            [dict setSTIMSafeObject:subKey forKey:@"subkey"];
            [self.clientConfigUpgradeArray addObject:dict];
        }
            break;
        case STIMClientConfigTypeKNoticeStickJidDic: {
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
                    [dict setSTIMSafeObject:[self transformClientConfigKeyWithType:STIMClientConfigTypeKNoticeStickJidDic] forKey:@"key"];
                    [dict setSTIMSafeObject:@"0" forKey:@"value"];
                    [dict setSTIMSafeObject:groupId forKey:@"subkey"];
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

@implementation STIMManager (Common)

//获取组织架构
- (void)updateOrganizationalStructure {
    NSString *destUrl = [NSString stringWithFormat:@"%@/update/getUpdateUsers.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSInteger userMaxVersion = [[IMDataManager stIMDB_SharedInstance] stIMDB_getUserCacheDataWithKey:kGetUpdateUsersV2Version withType:7];
    NSDictionary *versionDic = @{@"version":@(userMaxVersion)};
    NSData *versionData = [[STIMJSONSerializer sharedInstance] serializeObject:versionDic error:nil];
    [[STIMManager sharedInstance] sendTPPOSTRequestWithUrl:destUrl withRequestBodyData:versionData withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if ([responseDic isKindOfClass:[NSDictionary class]]) {
            BOOL ret = [[responseDic objectForKey:@"ret"] boolValue];
            NSInteger errcode = [[responseDic objectForKey:@"errcode"] integerValue];
            if (ret && errcode == 0) {
                NSDictionary *dataDic = [responseDic objectForKey:@"data"];
                long long maxVersion = [[dataDic objectForKey:@"version"] longLongValue];
                [[IMDataManager stIMDB_SharedInstance] stIMDB_UpdateUserCacheDataWithKey:kGetUpdateUsersV2Version withType:7 withValue:@"新版组织架构时间戳" withValueInt:maxVersion];
                NSArray *updateUserList = [dataDic objectForKey:@"update"];
                NSArray *userList = [dataDic objectForKey:@"update"];
                [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertOrgansUserInfos:userList];
                
                NSArray *deleteUserList = [dataDic objectForKey:@"delete"];
                [[IMDataManager stIMDB_SharedInstance] stIMDB_clearUserListForList:deleteUserList];
            } else {
                STIMErrorLog(@"请求新版本组织架构失败了", [responseDic objectForKey:@"errmsg"]);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

@end

@implementation STIMManager (CommonConfig)

- (void)setIsMerchant:(BOOL)isMerchant {
    _isLoadMerchant = YES;
    [[STIMUserCacheManager sharedInstance] setUserObject:@(isMerchant) forKey:@"isMerchant"];
    _isMerchant = isMerchant;
}

- (BOOL)isMerchant {
    if (YES == _isLoadMerchant) {
        return _isMerchant;
    } else {
        NSNumber *isMerchantCacheNumber = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"isMerchant"];
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
    return [[[STIMUserCacheManager sharedInstance] userObjectForKey:kLastUserId] lowercaseString];
}

- (void)updateLastTempUserToken:(NSString *)token {
    [[STIMUserCacheManager sharedInstance] setUserObject:token forKey:@"kTempUserToken"];
}

- (NSString *)getLastTempUserToken {
    return [[STIMUserCacheManager sharedInstance] userObjectForKey:@"kTempUserToken"];
}

- (void)updateLastUserToken:(NSString *)tempUserToken {
    [[STIMUserCacheManager sharedInstance] setUserObject:tempUserToken?tempUserToken:@"" forKey:@"userToken"];
}

- (NSString *)getLastUserToken {
    return [[STIMUserCacheManager sharedInstance] userObjectForKey:@"userToken"];
}

/**
 *  PWD
 *
 *  @return 无用
 */
- (NSString *)getLastPassword {
    return [[STIMUserCacheManager sharedInstance] userObjectForKey:kLastPassword];
}

/**
 *  JID  Ex: lilulucas.li@ejabhost1
 *
 *  @return JID
 */
- (NSString *)getLastJid {
    if ([STIMManager getLastUserName]) {
        return [[NSString stringWithFormat:@"%@@%@", [STIMManager getLastUserName], [[XmppImManager sharedInstance] domain]] lowercaseString];
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
    if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeQChat) {
        myNickName = [STIMManager getLastUserName];
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
                           [[STIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           [[XmppImManager sharedInstance] domain],
                           [k2 stimDB_getMD5],
                           time];
    
    
    NSString *newBase64Str = [newString stimDB_base64EncodedString];
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
    [properties setValue:[[STIMManager sharedInstance] thirdpartKeywithValue] forKey:NSHTTPCookieValue];
    [properties setValue:@"q_ckey" forKey:NSHTTPCookieName];
    [properties setValue:@".qunar" forKey:NSHTTPCookieDomain];
    [properties setValue:@"/" forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    return cookie;
}

- (NSString *)getWlanRequestURL {
    
    NSData *requestURLData = [STIMUUIDTools getRequestUrl];
    NSString *requestURL = [[NSString alloc] initWithData:requestURLData encoding:NSUTF8StringEncoding];
    if (requestURL.length > 0) {
        return requestURL;
    } else {
        if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeQChat) {
            return [[STIMNavConfigManager sharedInstance] newerHttpUrl];
        } else{
            return [[STIMNavConfigManager sharedInstance] newerHttpUrl];
        }
    }
}

- (NSString *)getWlanRequestDomain {

    NSData *requestDomainData = [STIMUUIDTools getRequestDoamin];
    NSString *requestDomain = [[NSString alloc] initWithData:requestDomainData encoding:NSUTF8StringEncoding];
    if (requestDomain.length > 0) {
        return requestDomain;
    } else {
        if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeQChat) {
            return @"ejabhost2";
        } else {
            return @"ejabhost1";
        }
    }
    return nil;
}

- (NSString *)getWlanKeyByTime:(int)time {

     NSString *key = [NSString stringWithFormat:@"%@%d", [STIMUUIDTools deviceUUID], time];
     STIMVerboseLog(@"快捷回复使用的key : %@", key);
     NSString *str = [NSString stringWithFormat:@"u=%@@%@&k=%@", [[STIMUUIDTools loginUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self getWlanRequestDomain], [[key stimDB_getMD5] lowercaseString]];
    /*
     if ([[self getWlanRequestDomain] isEqualToString:@"ejabhost1"] || [[self getWlanRequestDomain] isEqualToString:@"ejabhost2"]) {
     str = [NSString stringWithFormat:@"u=%@&k=%@", [[STIMUUIDTools loginUserName] ? [STIMUUIDTools loginUserName] : [STIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[key stimDB_getMD5] lowercaseString]];
     }
    */
     STIMVerboseLog(@"快捷回复Base64之前 : %@", str);
     return [[str dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}

- (NSDictionary *)loadWlanCookie {
    
    if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeQChat) {
        NSMutableDictionary *qcookieProperties = [NSMutableDictionary dictionary];
        [qcookieProperties setObject:@"_q" forKey:NSHTTPCookieName];
        [qcookieProperties setObject:[STIMUUIDTools qcookie] forKey:NSHTTPCookieValue];
        [qcookieProperties setObject:@".qunar.com" forKey:NSHTTPCookieDomain];
        [qcookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
        [qcookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
        
        NSHTTPCookie *qcookie = [NSHTTPCookie cookieWithProperties:qcookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:qcookie];
        
        NSMutableDictionary *vcookieProperties = [NSMutableDictionary dictionary];
        [vcookieProperties setObject:@"_v" forKey:NSHTTPCookieName];
        [vcookieProperties setObject:[STIMUUIDTools vcookie] forKey:NSHTTPCookieValue];
        [vcookieProperties setObject:@".qunar.com" forKey:NSHTTPCookieDomain];
        [vcookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
        [vcookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
        
        NSHTTPCookie *vcookie = [NSHTTPCookie cookieWithProperties:vcookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:vcookie];
        
        NSMutableDictionary *tcookieProperties = [NSMutableDictionary dictionary];
        [tcookieProperties setObject:@"_t" forKey:NSHTTPCookieName];
        [tcookieProperties setObject:[STIMUUIDTools tcookie] forKey:NSHTTPCookieValue];
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
    [[XmppImManager sharedInstance] setDeviceUUID:[STIMUUIDTools deviceUUID]];
    [[XmppImManager sharedInstance] setProtocolType:ProtocolType_Protobuf];
    [[XmppImManager sharedInstance] setDomain:self.imLoginDomain];
    [[XmppImManager sharedInstance] setHostName:self.imLoginXmppHost];
    [[XmppImManager sharedInstance] setPort:[self.imLoginProtobufPort intValue]];
    
    [[XmppImManager sharedInstance] setLoginType:self.imLoginType];
    STIMWarnLog(@"\n ProtocolType : %d \n Domain : %@\n LoginType : %lu\n HostAddress : %@\n Port : %d\n ", [[XmppImManager sharedInstance] protocolType], [[XmppImManager sharedInstance] domain], (unsigned long)self.imLoginType, [[XmppImManager sharedInstance] hostName], [[XmppImManager sharedInstance] port]);
}

- (void)checkClientConfig {
    
    NSString *title = @"";
    if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeQChat) {
        title = @"qchat";
    } else if ([[STIMAppInfo sharedInstance] appType] == STIMProjectTypeQTalk) {
        title = @"qtalk";
    } else {
        title = @"startalk";
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/config/check_config.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSURL *requestUrl = [NSURL URLWithString:url];
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:requestUrl];
    
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];

    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];
    
    NSMutableDictionary *bodyProperties = [NSMutableDictionary dictionary];
    [bodyProperties setObject:[[STIMAppInfo sharedInstance] AppBuildVersion] forKey:@"v"];
    [bodyProperties setObject:title forKey:@"ver"];
    [bodyProperties setObject:@"ios" forKey:@"p"];
    NSInteger clientVersion = [[[STIMUserCacheManager sharedInstance] userObjectForKey:kCheckConfigVersion] integerValue];
    [bodyProperties setObject:[NSString stringWithFormat:@"%lld", (clientVersion > 0) ? clientVersion : 0] forKey:@"cv"];
    [bodyProperties setSTIMSafeObject:[[STIMAppSetting sharedInstance] currentLanguage] forKey:@"language"];
    
    [request setHTTPMethod:STIMHTTPMethodPOST];
    [request setHTTPBody:[[STIMJSONSerializer sharedInstance] serializeObject:bodyProperties error:nil]];
    [request setHTTPRequestHeaders:cookieProperties];
    
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            NSDictionary *resDic = [[STIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
            if (resDic.count > 0) {
                NSInteger errcode = [[resDic objectForKey:@"errcode"] integerValue];
                if (errcode == 0) {
                    if (nil == self.clientConfigDic) {
                        self.clientConfigDic = [NSMutableDictionary dictionaryWithCapacity:3];
                    }
                    NSDictionary *dataDic = [resDic objectForKey:@"data"];
                    if (dataDic.count) {
                        self.clientConfigDic = [NSMutableDictionary dictionaryWithDictionary:dataDic];
                        [[STIMUserCacheManager sharedInstance] setUserObject:self.clientConfigDic forKey:kNewClinetConfigDic];
                        NSInteger cvVersion = [dataDic objectForKey:@"version"];
                        [[STIMUserCacheManager sharedInstance] setUserObject:@(cvVersion) forKey:kCheckConfigVersion];
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

            // If we couldn't find one, we'll give up (and ASIHTTPRequest will use the standard CFNetwork user agent)
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
                // We won't bother to check for systems prior to 10.4, since ASIHTTPRequest only works on 10.5+
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
    BOOL state = [[STIMManager sharedInstance] getLocalMsgNotifySettingWithIndex:STIMMSGSETTINGSOUND_INAPP];
    return state;
}

- (void)setNewMsgNotify:(BOOL)flag {
    [self setMsgNotifySettingWithIndex:STIMMSGSETTINGSOUND_INAPP WithSwitchOn:flag];
}

//新消息震动
- (BOOL)isNewMsgVibrate {
    BOOL state = [[STIMManager sharedInstance] getLocalMsgNotifySettingWithIndex:STIMMSGSETTINGVIBRATE_INAPP];
    return state;
}

- (void)setNewMsgVibrate:(BOOL)flag {
    [self setMsgNotifySettingWithIndex:STIMMSGSETTINGVIBRATE_INAPP WithSwitchOn:flag];
}

//相册是否发送原图
- (BOOL)pickerPixelOriginal {
    NSNumber *flagNum = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"pickerPixelOriginal"];
    if (flagNum == nil) {
        flagNum = @(YES);
        [self setPickerPixelOriginal:YES];
    }
    return [flagNum boolValue];
}

- (void)setPickerPixelOriginal:(BOOL)flag {
    [[STIMUserCacheManager sharedInstance] setUserObject:@(flag) forKey:@"pickerPixelOriginal"];
}

//OPS发现页RN调试
- (NSString *)opsFoundRNDebugUrl {
    NSString *opsFoundRNDebugUrl = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"opsFoundRNDebugUrl"];
    return opsFoundRNDebugUrl;
}

- (void)setOpsFoundRNDebugUrl:(NSString *)opsFoundRNDebugUrl {
    [[STIMUserCacheManager sharedInstance] setUserObject:opsFoundRNDebugUrl forKey:@"opsFoundRNDebugUrl"];
}

//qtalk发现页测试地址
- (NSString *)qtalkFoundRNDebugUrl {
    NSString *qtalkFoundRNDebugUrl = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"qtalkFoundRNDebugUrl"];
    return qtalkFoundRNDebugUrl;
}

- (void)setQtalkFoundRNDebugUrl:(NSString *)qtalkFoundRNDebugUrl {
    [[STIMUserCacheManager sharedInstance] setUserObject:qtalkFoundRNDebugUrl forKey:@"qtalkFoundRNDebugUrl"];
}

//qtalk搜索测试地址
- (NSString *)qtalkSearchRNDebugUrl {
    NSString *qtalkSearchRNDebugUrl = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"qtalkSearchRNDebugUrl"];
    return qtalkSearchRNDebugUrl;
}

- (void)setQtalkSearchRNDebugUrl:(NSString *)qtalkSearchRNDebugUrl {
    [[STIMUserCacheManager sharedInstance] setUserObject:qtalkSearchRNDebugUrl forKey:@"qtalkSearchRNDebugUrl"];
}

//是否优先展示对方个性签名
- (BOOL)moodshow {
    NSNumber *flagNum = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"moodshow"];
    if (flagNum == nil) {
        flagNum = @(YES);
        [self setMoodshow:YES];
    }
    return [flagNum boolValue];
}

- (void)setMoodshow:(BOOL)flag {
    [[STIMUserCacheManager sharedInstance] setUserObject:@(flag) forKey:@"moodshow"];
}

//是否展示水印
- (BOOL)waterMarkState {
    NSNumber *flagNum = [[STIMUserCacheManager sharedInstance] userObjectForKey:@"waterMarkState"];
    if (flagNum == nil) {
        flagNum = @(YES);
        [self setWaterMarkState:YES];
    }
    return [flagNum boolValue];
}

- (void)setWaterMarkState:(BOOL)flag {
    [[STIMUserCacheManager sharedInstance] setUserObject:@(flag) forKey:@"waterMarkState"];
}

//艾特消息
- (NSArray *)getHasAtMeByJid:(NSString *)jid {
    
    __block NSArray *array = nil;
    dispatch_block_t block = ^{
        if (!_hasAtMeDic) {
            _hasAtMeDic = [[IMDataManager stIMDB_SharedInstance] stIMDB_getTotalAtMessageDic];
        }
        array = [_hasAtMeDic objectForKey:jid];
    };
    
    if (dispatch_get_specific(_atMeCacheTag))
        block();
    else
        dispatch_sync(_atMeCacheQueue, block);
    return array;
}

- (void)updateAtMeMessageWithJid:(NSString *)groupId withMsgIds:(NSArray *)msgIds withReadState:(STIMAtMsgReadState)readState {
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
        [_hasAtMeDic setSTIMSafeObject:groupAtTempArray forKey:groupId];
//        [_hasAtMeDic removeObjectForKey:groupId];
        [[IMDataManager stIMDB_SharedInstance] stIMDB_UpdateAtMessageReadStateWithGroupId:groupId withMsgIds:msgIds withReadState:readState];
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
        [[IMDataManager stIMDB_SharedInstance] stIMDB_UpdateAtMessageReadStateWithGroupId:groupId withReadState:STIMAtMsgHasReadState];
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

- (void)addOfflineAtMeMessageByJid:(NSString *)groupId withType:(STIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime {
    dispatch_block_t block = ^{
        _hasAtMeDic = nil;
        [[IMDataManager stIMDB_SharedInstance] stIMDB_insertAtMessageWithGroupId:groupId withType:atType withMsgId:msgId withMsgTime:msgTime];
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

- (void)addAtMeMessageByJid:(NSString *)groupId withType:(STIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime {
    dispatch_block_t block = ^{
        
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[_hasAtMeDic objectForKey:groupId]];
        if (arr == nil) {
            
            arr = [NSMutableArray arrayWithArray:[[IMDataManager stIMDB_SharedInstance] stIMDB_getAtMessageWithGroupId:groupId]];
            NSMutableDictionary *atMessageDic = [NSMutableDictionary dictionaryWithCapacity:3];
            [atMessageDic setSTIMSafeObject:groupId forKey:@"GroupId"];
            [atMessageDic setSTIMSafeObject:msgId forKey:@"MsgId"];
            [atMessageDic setSTIMSafeObject:@(atType) forKey:@"Type"];
            [atMessageDic setSTIMSafeObject:@(msgTime) forKey:@"MsgDate"];
            [atMessageDic setSTIMSafeObject:@(STIMAtMsgNotReadState) forKey:@"ReadState"];
            [arr addObject:atMessageDic];
            [_hasAtMeDic setObject:arr forKey:groupId];
        } else {
            NSMutableDictionary *atMessageDic = [NSMutableDictionary dictionaryWithCapacity:3];
            [atMessageDic setSTIMSafeObject:groupId forKey:@"GroupId"];
            [atMessageDic setSTIMSafeObject:msgId forKey:@"MsgId"];
            [atMessageDic setSTIMSafeObject:@(atType) forKey:@"Type"];
            [atMessageDic setSTIMSafeObject:@(msgTime) forKey:@"MsgDate"];
            [atMessageDic setSTIMSafeObject:@(STIMAtMsgNotReadState) forKey:@"ReadState"];
            [arr addObject:atMessageDic];
            [_hasAtMeDic setObject:arr forKey:groupId];
        }
        [[IMDataManager stIMDB_SharedInstance] stIMDB_insertAtMessageWithGroupId:groupId withType:atType withMsgId:msgId withMsgTime:msgTime];
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
        
        [_notSendTextDic setSTIMSafeObject:@{@"text": text ? text : @"", @"inputItems": inputItems ? inputItems : [NSArray array]} forKey:jid];
        [[STIMUserCacheManager sharedInstance] setUserObject:_notSendTextDic forKey:kNotSendTextDic];
    } else {
        
        [_notSendTextDic removeObjectForKey:jid];
        [[STIMUserCacheManager sharedInstance] setUserObject:_notSendTextDic forKey:kNotSendTextDic];
    }
}

- (NSDictionary *)getQChatTokenWithBusinessLineName:(NSString *)businessLineName {
    
    NSString *desturl = [[STIMNavConfigManager sharedInstance] getQChatGetTKUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:desturl]];
    NSDictionary *params = @{@"macCode": [[STIMAppInfo sharedInstance] macAddress], @"plat": (businessLineName.length > 0) ? businessLineName : @"app"};
    NSData *data = [[STIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    [request appendPostData:data];
    [request startSynchronous];
    if ([request responseStatusCode] == 200) {
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            return [result objectForKey:@"data"];
        }
    }
    return nil;
}

- (NSDictionary *)getQVTForQChat {
    
    NSDictionary *qvtInfoDic = [[STIMUserCacheManager sharedInstance] userObjectForKey:kQVTCookie];
    return qvtInfoDic;
}

- (void)removeQVTForQChat {
    
    [[STIMUserCacheManager sharedInstance] removeUserObjectForKey:kQVTCookie];
}

- (NSString *)getDownloadFilePath {
    
    return _downLoadFile;
}

- (void)clearcache {
    STIMWarnLog(@"清除cache");
    [_lastLoginTimeDic removeAllObjects];
}

- (BOOL)setStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType {
    
    NSDictionary *dict = @{@"topType":@(1), @"chatType":@(chatType)};
    NSString *value = [[STIMJSONSerializer sharedInstance] serializeObject:dict];
    return [[STIMManager sharedInstance] updateRemoteClientConfigWithType:STIMClientConfigTypeKStickJidDic WithSubKey:combineJid WithConfigValue:value WithDel:NO];
}

- (BOOL)removeStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType {
    NSDictionary *infoDic = @{@"chatType":@(chatType), @"topType":@(0)};
    NSString *infoStr = [[STIMJSONSerializer sharedInstance] serializeObject:infoDic];
    return [self updateRemoteClientConfigWithType:STIMClientConfigTypeKStickJidDic WithSubKey:combineJid WithConfigValue:infoStr WithDel:YES];
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
        NSInteger tempStickState = [[STIMManager sharedInstance] getClientConfigDeleteFlagWithType:STIMClientConfigTypeKStickJidDic WithSubKey:combineJid];
        if (tempStickState == 0) {
            stickState = YES;
            dispatch_block_t block = ^{
                
                [self.stickJidDic setSTIMSafeObject:@(1) forKey:combineJid];
            };
            if (dispatch_get_specific(self.cacheTag))
                block();
            else
                dispatch_sync(self.cacheQueue, block);
        } else {
            stickState = NO;
            dispatch_block_t block = ^{
                
                [self.stickJidDic setSTIMSafeObject:@(-1) forKey:combineJid];
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
    
    return [[STIMManager sharedInstance] getClientConfigDicWithType:STIMClientConfigTypeKStickJidDic];
}

- (BOOL)setMsgNotifySettingWithIndex:(STIMMSGSETTING)setting WithSwitchOn:(BOOL)switchOn {
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
    NSString *str = [NSString stringWithFormat:@"%@/push/qtapi/token/setmsgsettings.qunar?username=%@&domain=%@&os=ios&version=%@&index=%@&status=%@", [[STIMNavConfigManager sharedInstance] javaurl], [STIMManager getLastUserName], [[STIMNavConfigManager sharedInstance] domain], [[STIMAppInfo sharedInstance] AppBuildVersion], @(setting), @(switchOn)];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:str]];
    [request setRequestMethod:@"GET"];
    [request setUseCookiePersistence:NO];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setRequestHeaders:cookieProperties];
    [request startSynchronous];
    NSError *error = [request error];
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        if (ret && errcode == 0) {
            NSInteger localPushFlag = [[[STIMUserCacheManager sharedInstance] userObjectForKey:@"MsgSettings"] integerValue];
            localPushFlag = localPushFlag ^ setting;
            [[STIMUserCacheManager sharedInstance] setUserObject:@(localPushFlag) forKey:@"MsgSettings"];
            return YES;
        }
    }
    return NO;
}

- (BOOL)getLocalMsgNotifySettingWithIndex:(STIMMSGSETTING)setting {
    NSInteger localPushFlag = 0;
    if (![[STIMUserCacheManager sharedInstance] containsObjectForKey:@"MsgSettings"]) {
        localPushFlag = STIMMSGSETTINGPUSH_SWITCH;
    } else {
        localPushFlag = [[[STIMUserCacheManager sharedInstance] userObjectForKey:@"MsgSettings"] integerValue];
    }
    BOOL state = (setting & localPushFlag);
    return state;
}

- (void)getMsgNotifyRemoteSettings {
    NSString *str = [NSString stringWithFormat:@"%@/push/qtapi/token/getmsgsettings.qunar?username=%@&domain=%@&os=ios&version=%@", [[STIMNavConfigManager sharedInstance] javaurl], [STIMManager getLastUserName], [[STIMNavConfigManager sharedInstance] domain], [[STIMAppInfo sharedInstance] AppBuildVersion]];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:str]];
    [request setHTTPRequestHeaders:cookieProperties];
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *responseData = response.data;
                NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
                    NSDictionary *pushStateDic = [result objectForKey:@"data"];
                    NSInteger pushFlag = [[pushStateDic objectForKey:@"push_flag"] integerValue];
                    [[STIMUserCacheManager sharedInstance] setUserObject:@(pushFlag) forKey:@"MsgSettings"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyRNAppSettingView object:nil];
                    });
                }
            });
        }
    } failure:^(NSError *error) {
        STIMErrorLog(@"请求客户端消息设置失败 : %@", error);
    }];
}

- (void)sendQChatOnlineNotification {
    NSString *str = [NSString stringWithFormat:@"%@/%@", [[STIMNavConfigManager sharedInstance] qcHost], @"css/online"];
    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:str]];
    [STIMHTTPClient sendRequest:request complete:nil failure:nil];
}

- (void)sendNoPush {
    STIMErrorLog(@"注销Token");
    [[STIMAppInfo sharedInstance] setPushToken:nil];
}

- (BOOL)sendServer:(NSString *)notificationToken withUsername:(NSString *)username withParamU:(NSString *)paramU withParamK:(NSString *)paramK WithDelete:(BOOL)deleteFlag {
    
    STIMVerboseLog(@"准备向帆哥服务器发送Push Token . Token : %@, 用户名 : %@, U = %@, K = %@", notificationToken, username, paramU, paramK);
    if (paramK.length <= 0 || !paramK) {
        paramK = [self updateRemoteLoginKey];
    }
    NSArray *userInfo = [username componentsSeparatedByString:@"@"];
    BOOL sendServerSuccess = NO;
    NSString *url = @"";
    if ([[STIMNavConfigManager sharedInstance] newPush] == NO) {
        url = [NSString stringWithFormat:@"%@/push/qtapi/token/setpersonmackey.qunar?username=%@&domain=%@&mac_key=%@&platname=%@_%@_%@&pkgname=%@&os=%@&version=%@&show_content=%@", [[STIMNavConfigManager sharedInstance] javaurl], [userInfo objectAtIndex:0], [userInfo objectAtIndex:1], notificationToken, [[[STIMAppInfo sharedInstance] deviceName] stringByReplacingOccurrencesOfString:@" " withString:@""], [[[NSLocale preferredLanguages][0] componentsSeparatedByString:@"-"] firstObject], [[NSLocale currentLocale] countryCode], [[NSBundle mainBundle] bundleIdentifier], @"ios", [[STIMAppInfo sharedInstance] AppBuildVersion], @(YES)];
    } else {
        url = [NSString stringWithFormat:@"%@/qtapi/token/setpersonmackey.qunar?username=%@&domain=%@&mackey=%@&os=%@&version=%@", [[STIMNavConfigManager sharedInstance] javaurl], [userInfo objectAtIndex:0], [userInfo objectAtIndex:1], notificationToken, @"ios", [[STIMAppInfo sharedInstance] AppBuildVersion]];
    }
    if (deleteFlag) {
        url = [url stringByReplacingOccurrencesOfString:@"set" withString:@"del"];
    }
    STIMVerboseLog(@"帆哥更新Token地址 : %@", url);
    NSURL *requestUrl = [[NSURL alloc] initWithString:url];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request setUseCookiePersistence:NO];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setRequestHeaders:cookieProperties];
    request.timeOutSeconds = 2;
    STIMWarnLog(@"=== 开始向帆哥服务器发送PushToken请求 === ");
    [request startSynchronous];
    STIMWarnLog(@"=== 结束向帆哥服务器发送PushToken请求 === ");
    NSError *error = [request error];
    NSDictionary *result = nil;
    NSString *errmsg = nil;
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        result = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        NSInteger ret = [[result objectForKey:@"ret"] integerValue];
        errmsg = [result objectForKey:@"errmsg"];
        if (errcode == 0) {
            if (ret == 1) {
                STIMVerboseLog(@"=== 向帆哥服务器发送PushToken成功 === %@", result);
                sendServerSuccess = YES;
            }
        }
    }
    if (!sendServerSuccess) {
        STIMErrorLog(@"=== 向帆哥服务器发送PushToken失败 === %@,  %@ ", error, errmsg);
    }
    return sendServerSuccess;
}

- (BOOL)sendPushTokenWithMyToken:(NSString *)myToken WithDeleteFlag:(BOOL)deleteFlag {
    if ([STIMManager getLastUserName].length > 0) {
        if (self.remoteKey.length <= 0) {
            [self updateRemoteLoginKey];
        }
        if (self.remoteKey.length > 0) {
            BOOL result = [self sendServer:myToken
                              withUsername:[self getLastJid]
                                withParamU:[self getLastJid]
                                withParamK:self.remoteKey
                                WithDelete:deleteFlag];
            
            if (result) {
                STIMVerboseLog(@"更新后的PushToken为%@", myToken);
            } else {
                STIMErrorLog(@"更新PushToken失败");
            }
            return result;
        }
    }
    return NO;
}

- (void)checkClearCache {
    NSInteger clearCacheVersion = [[[STIMUserCacheManager sharedInstance] userObjectForKey:kClearCacheCheck] integerValue];
    if (clearCacheVersion < kClearCacheVersion) {
        STIMErrorLog(@"clearCacheVersion : %lu", clearCacheVersion);
        [self clearcache];
        [[STIMUserCacheManager sharedInstance] setUserObject:@(kClearCacheVersion) forKey:kClearCacheCheck];
    }
}

- (void)findNewestClient {
    NSInteger updateAppVersion = [[[STIMUserCacheManager sharedInstance] userObjectForKey:@"updateAppVersion"] integerValue];
    if (updateAppVersion > 0 && updateAppVersion > [[[STIMAppInfo sharedInstance] AppBuildVersion] integerValue]) {
        
    } else {
        updateAppVersion = [[[STIMAppInfo sharedInstance] AppBuildVersion] integerValue];
    }
    NSString *destUrl = [NSString stringWithFormat:@"%@/nck/client/get_version.qunar?clientname=%@&ver=%ld&u=%@&d=%@", [[STIMNavConfigManager sharedInstance] newerHttpUrl], @"qtalk_ios", updateAppVersion, [STIMManager getLastUserName], [[STIMManager sharedInstance] getDomain]];

    [[STIMManager sharedInstance] sendTPGetRequestWithUrl:destUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *responseDic = [[STIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
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
