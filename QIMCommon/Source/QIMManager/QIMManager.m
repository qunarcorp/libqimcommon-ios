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

#import "ASIDataCompressor.h"
#import "ASIDataDecompressor.h"
#import "Database.h"

#import "QIMAppInfo.h"
#import "QIMUserCacheManager.h"
#import "QIMNavConfigManager.h"
#import "ASIHTTPRequest.h"
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
    _userProfilePath = nil;
    _userVcard = nil;
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
    
    _configPath = nil;
    
    _webName = nil;
    
    _clinetConfigDic = nil;
    
    _shareLocationDic = nil;
    _shareLocationFromIdDic = nil;
    _shareLocationUserDic = nil;
    
    
    _userResourceDic = nil;

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
//    updateMaxRosterListTime
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMaxRosterListTime:) name:@"updateMaxRosterListTime" object:nil];
}

- (dispatch_queue_t)cacheQueue {
    return _cacheQueue;
}

- (void*)cacheTag {
    return _cacheTag;
}

- (void)initAppCacheConfig {
    self.update_chat_card = dispatch_queue_create("update_chat_card", DISPATCH_QUEUE_SERIAL);
    self.loginComplateQueue = [[NSOperationQueue alloc] init];
    self.loginComplateQueue.maxConcurrentOperationCount = 1;
    self.loginComplateQueue.name = @"loginComplateQueue";
//    self.loginComplateQueue = dispatch_queue_create("loginComplateQueue", 0);
    self.update_group_member_queue = dispatch_queue_create("Update Group Member Info Queue", DISPATCH_QUEUE_SERIAL);
    self.load_group_offline_msg_queue = dispatch_queue_create("Load Group Offline Msg Queue", DISPATCH_QUEUE_SERIAL);
    self.load_user_state_queue = dispatch_queue_create("Load User State", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    self.receive_msg_queue = dispatch_queue_create("Receive Msg", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    self.load_user_header = dispatch_queue_create("Load User Header", DISPATCH_QUEUE_PRIORITY_DEFAULT);
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
    _hasAtMeDic = [[NSMutableDictionary alloc] init];
    _hasAtAllDic = [[NSMutableDictionary alloc] init];
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
    
    _userNormalHeaderDic = [NSMutableDictionary dictionaryWithCapacity:5];
    
    _userInfoDic = [NSMutableDictionary dictionaryWithCapacity:5];
    
    _notSendTextDic = [NSMutableDictionary dictionary];
    {
        NSDictionary *dic = [[QIMUserCacheManager sharedInstance] userObjectForKey:kNotSendTextDic];
        [_notSendTextDic setDictionary:dic];
    }
    
    _clinetConfigDic = [NSMutableDictionary dictionary];
    {
        NSDictionary *dic = [[QIMUserCacheManager sharedInstance] userObjectForKey:kNewClinetConfigDic];
        if (dic) {
            [_clinetConfigDic setDictionary:dic];
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
}

@end

@implementation QIMManager (RegisterEvent)

- (void)refreshSwitchAccount:(NSDictionary *)notify {
//    [self checkClientConfig];
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
            [[QIMUserCacheManager sharedInstance] setUserObject:tempUserToken?tempUserToken:@"" forKey:@"userToken"];
            QIMVerboseLog(@"LoginComplate 之后的tempUserToken : %@", tempUserToken);
#warning NavDict NavConfig
            NSDictionary *currentLoginNavConfig = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"NavConfig"];
            NSDictionary *navDict = @{@"NavConfig":currentLoginNavConfig?currentLoginNavConfig:@{}, @"NavUrl":[[QIMUserCacheManager sharedInstance] userObjectForKey:@"QC_CurrentNavDict"]};
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
        
        _userProfilePath = [UserDocumentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@/profile/", [self getLastJid], UserPath]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_userProfilePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_userProfilePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        _userVcard = [UserDocumentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@/userVcard/", [self getLastJid], UserPath]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_userVcard]) {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:_userVcard withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        _downLoadFile = [UserCachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/imageCache/"]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:_downLoadFile]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_downLoadFile withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        _groupHeaderImageCachePath = [UserCachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/imageCache/"]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_groupHeaderImageCachePath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_groupHeaderImageCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        _configPath = [UserDocumentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@/config", [self getLastJid], UserPath]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:_configPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_configPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        QIMVerboseLog(@"开始获取单人历史记录2");
        CFAbsoluteTime startTime1 = [[QIMWatchDog sharedInstance] startTime];
        [self updateOfflineMessagesV2];
        QIMVerboseLog(@"获取单人历史记录2loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime1]);
        QIMVerboseLog(@"获取单人历史记录结束2");

        QIMVerboseLog(@"开始获取消息已读状态2");
        CFAbsoluteTime startTime2 = [[QIMWatchDog sharedInstance] startTime];
        [self getReadFlag];
        QIMVerboseLog(@"获取消息已读状态2loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime2]);
        QIMVerboseLog(@"获取消息已读状态结束2");

        dispatch_async(dispatch_get_main_queue(), ^{
            QIMVerboseLog(@"强制刷一下单聊会话框界面的消息开始2");
            [[NSNotificationCenter defaultCenter] postNotificationName:kSingleChatMsgReloadNotification object:nil];
            QIMVerboseLog(@"强制刷一下单聊会话框界面的消息结束2");
        });

        QIMVerboseLog(@"开始获取群历史记录2");
        CFAbsoluteTime startTime3 = [[QIMWatchDog sharedInstance] startTime];
        [self updateOfflineGroupMessages];
        QIMVerboseLog(@"获取群历史记录2loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime3]);
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
        QIMVerboseLog(@"获取群阅读指针2loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime4]);
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
        QIMVerboseLog(@"获取系统历史记录2loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime5]);
        QIMVerboseLog(@"获取系统历史记录结束2");
        
        // 更新未发送的消息状态为失败
        [[IMDataManager sharedInstance] updateMessageFromState:MessageState_Waiting ToState:MessageState_Faild];
        QIMVerboseLog(@"开始同步服务端漫游的个人配置2");
        CFAbsoluteTime startTime6 = [[QIMWatchDog sharedInstance] startTime];
        [self getRemoteClientConfig];
        QIMVerboseLog(@"同步服务端漫游的个人配置2loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime6]);
        QIMVerboseLog(@"同步服务端漫游的个人配置完成2");
        
        if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQTalk) {
            QIMVerboseLog(@"开始获取我的关联账户2");
            CFAbsoluteTime startTime7 = [[QIMWatchDog sharedInstance] startTime];
            [self getRemoteCollectionAccountList];
            QIMVerboseLog(@"获取我的关联账户2loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime7]);
            
            QIMVerboseLog(@"开始同步公众号列表2");
            CFAbsoluteTime startTime8 = [[QIMWatchDog sharedInstance] startTime];
            [self updatePublicNumberList];
            QIMVerboseLog(@"同步公众号列表2loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime8]);
            QIMVerboseLog(@"同步公众号列表完成2");
        }
        
        QIMVerboseLog(@"开始Check组织架构2");
        CFAbsoluteTime startTime9 = [[QIMWatchDog sharedInstance] startTime];
        [self checkRosterListWithForceUpdate:NO];
        QIMVerboseLog(@"Check组织架构2loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime9]);
        QIMVerboseLog(@"Check组织架构结束2");
    
        QIMVerboseLog(@"开始请求增量群列表");
        CFAbsoluteTime startTime10 = [[QIMWatchDog sharedInstance] startTime];
        [self quickJoinAllGroup];
        QIMVerboseLog(@"快速入群完成2loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime10]);
        QIMVerboseLog(@"快速入群完成2");
            
        QIMVerboseLog(@"开始TCP发送已送达消息状态2");
        CFAbsoluteTime startTime11 = [[QIMWatchDog sharedInstance] startTime];
        [self sendRecevieMessageState];
        QIMVerboseLog(@"TCP发送已送达消息状态2loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime11]);
        QIMVerboseLog(@"TCP发送已送达消息状态结束2");
        
        QIMVerboseLog(@"开始同步消息推送设置2");
        CFAbsoluteTime startTime12 = [[QIMWatchDog sharedInstance] startTime];
        [self getMsgNotifyRemoteSettings];
        QIMVerboseLog(@"同步消息推送设置2loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime12]);
        QIMVerboseLog(@"同步同步消息推送设置2");
            
        //24 小时拿一次
        long long checkConfigVersion = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kCheckConfigVersion] longLongValue];
        if (checkConfigVersion != [[QIMNavConfigManager sharedInstance] checkConfigVersion]) {
            [self checkClientConfig];
        }
    
        QIMVerboseLog(@"开始获取加密会话密码箱2");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotifyNotificationGetRemoteEncrypt" object:nil];
        });
        QIMVerboseLog(@"开始获取加密会话密码箱2结束");
        
        CFAbsoluteTime startTime13 = [[QIMWatchDog sharedInstance] startTime];
        [self sendPushTokenWithMyToken:[[QIMAppInfo sharedInstance] pushToken] WithDeleteFlag:NO];
        QIMVerboseLog(@"注册Token1loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime13]);
        
        // 更新好友列表
        CFAbsoluteTime startTime14 = [[QIMWatchDog sharedInstance] startTime];
        [self updateFriendList];
        QIMVerboseLog(@"更新好友列表loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime14]);
        
        CFAbsoluteTime startTime15 = [[QIMWatchDog sharedInstance] startTime];
        [self updateFriendInviteList];
        QIMVerboseLog(@"邀请好友申请loginComplate耗时 : %lf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime15]);
        
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
        
        if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQTalk) {
            QIMVerboseLog(@"登录之后请求一下骆驼帮未读数");

            [[QIMManager sharedInstance] getExploreNotReaderCount];
        }
    
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQTalk) {
        QIMVerboseLog(@"登录之后请求热线账户列表");
        [self getHotlineShopList];
    }
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

- (void)synchServerTime {
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/getservertime?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            _serverTimeDiff = [[NSDate date] timeIntervalSince1970] - response.responseString.longLongValue;
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)updateUserSuoXie {
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
        return;
    } else {
        NSString *destUrl = [NSString stringWithFormat:@"%@/getusersuoxie?c=qtalk&u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        
        QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
        [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
            if (response.code == 200) {
                NSError *error = nil;
                id value = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:&error];
                if (error == nil && value) {
                    [[IMDataManager sharedInstance] bulkUpdateUserSearchIndexs:value];
                }
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)updateMaxRosterListTime:(NSNotification *)notify {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        long long time = [notify.object longLongValue];
        NSString *jid = [[QIMManager sharedInstance] getLastJid];
        NSString *updateTime = [NSString stringWithFormat:@"%lld", time];
        NSArray *configArray = @[@{@"subkey":jid?jid:@"", @"configinfo":updateTime}];
        [[IMDataManager sharedInstance] qimDB_bulkInsertConfigArrayWithConfigKey:[self transformClientConfigKeyWithType:QIMClientConfigTypeKLocalIncrementUpdateTime] WithConfigVersion:0 ConfigArray:configArray];
    });
}

- (NSData *)updateRosterList {
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
        
    } else {
        
        NSTimeInterval temp_t1 = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval temp_t2 = 0;
        NSString *destUrl = [NSString stringWithFormat:@"%@/get_increment_users?c=qtalk&u=%@&k=%@&p=iphone&v=%@&d=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion], [XmppImManager sharedInstance].domain];
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        long long maxIncrementUpdateTime = [[[IMDataManager sharedInstance] qimDB_getConfigInfoWithConfigKey:@"kLocalIncrementUpdateTime" WithSubKey:[[QIMManager sharedInstance] getLastJid] WithDeleteFlag:NO] longLongValue];
        [params setQIMSafeObject:@(maxIncrementUpdateTime) forKey:@"version"];
        [params setQIMSafeObject:[XmppImManager sharedInstance].domain forKey:@"domain"];
        
        NSData *postData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
        
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
        [request setRequestMethod:@"POST"];
        [request setPostBody:postData];
        [request setAllowCompressedResponse:YES];
        [request setShouldCompressRequestBody:YES];
        [request startSynchronous];
        
        temp_t2 = [[NSDate date] timeIntervalSince1970];
        if ([request responseStatusCode] == 200) {
            
            NSError *error = [request error];
            if (!error) {
                NSData *responseData = [request responseData];
                NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
                BOOL ret = [[result objectForKey:@"ret"] boolValue];
                if (ret) {
                    NSArray *resultArray = [result objectForKey:@"data"];
//                        [[IMDataManager sharedInstance] clearUserListForList:resultArray];
                        [[IMDataManager sharedInstance] bulkInsertUserInfosNotSaveDescInfo:resultArray];
                    dispatch_block_t block = ^{
                        for (NSDictionary *infoDic in resultArray) {
                            [_friendDescDic setObject:[infoDic objectForKey:@"D"] forKey:[infoDic objectForKey:@"U"]];
                        }
                    };
                    
                    if (dispatch_get_specific(_cacheTag))
                        block();
                    else
                        dispatch_sync(_cacheQueue, block);
                    return [[QIMJSONSerializer sharedInstance] serializeObject:resultArray error:nil];
                }
                return nil;
            }
        }
    }
    return nil;
}


- (void)decodeTreeWithDic:(NSDictionary *)rosterDic WithRosterList:(NSMutableArray *)rosterList WithDescInfo:(NSMutableString *)descInfo {
    NSString *groupName = [rosterDic objectForKey:@"D"];
    [descInfo appendFormat:@"%@/", groupName];
    NSArray *userListArray = [rosterDic objectForKey:@"UL"];
    for (NSDictionary *userDic in userListArray) {
        NSString *userName = [userDic objectForKey:@"N"];
        if ([userName isEqual:[NSNull null]] || userName.length <= 0) {
            userName = [userDic objectForKey:@"W"];
        }
        [rosterList addObject:@{@"U": [userDic objectForKey:@"U"], @"N": userName, @"D": descInfo}];
    }
    NSArray *subSectorArray = [rosterDic objectForKey:@"SD"];
    for (NSDictionary *subRosterDic in subSectorArray) {
        [self decodeTreeWithDic:subRosterDic WithRosterList:rosterList WithDescInfo:descInfo];
    }
    
}

- (void)updateQChatUserList:(NSDictionary *)deps {
    NSMutableArray *rosterList = [NSMutableArray array];
    NSMutableString *descInfo = [NSMutableString string];
    [self decodeTreeWithDic:deps WithRosterList:rosterList WithDescInfo:descInfo];
    [[IMDataManager sharedInstance] bulkInsertUserInfos:rosterList];
}

- (NSData *)updateOrganizationalStructure {
    
    /* ---------------QTalk--------------
     参数    含义
     UL    用户列表
     N    用户姓名
     U    用户rtx_id
     S    用户在线状态，0离线，6在线（后续状态会进行扩展，1 离开；5 繁忙），改用户状态默认为5min更新一次，如需要获取即时状态请使用别的接口
     D    用户部门列表
     SD    子部门列表，子部门同样包含D，U, SD，该结构目前最深为5层,SD可为空。
     Fp    Rtxid拼音 及缩写，以 | 分割
     Sp    Rtx汉字部分拼音及缩写，以 | 分割
     --------------------------------------
     
     -----------------QChat---------------
     id
     dep_name
     pid
     other_flag
     sub
     person
     uin
     nickname
     strid
     online_status
     department_id
     -------------------------------------
     */
    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
        [self updateMyCard];
        if (self.isMerchant == NO) {
            return nil;
        }
        NSError *errol = nil;
        NSString *postDataStr = [NSString stringWithFormat:@"strid=%@&u=%@&k=%@", [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey];
        NSMutableData *tempPostData = [NSMutableData dataWithData:[postDataStr dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/get_dep_info?p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMAppInfo sharedInstance] AppBuildVersion]]];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
        [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded;"];
        [request setRequestMethod:@"POST"];
        [request setPostBody:tempPostData];
        [request startSynchronous];
        
        NSError *error = [request error];
        if (([request responseStatusCode] == 200) && !error) {
            NSString *organizationStr = [request responseString];
            NSDictionary *organizationDic = [[QIMJSONSerializer sharedInstance] deserializeObject:organizationStr error:&error];
            [self updateQChatUserList:organizationDic];
            
            dispatch_block_t block = ^{
                [_friendDescDic removeAllObjects];
                [_friendDescDic setObject:@"QChatStaff" forKey:@"D"];
                [_friendDescDic setQIMSafeObject:[organizationDic objectForKey:@"SD"] forKey:@"SD"];
            };
            
            if (dispatch_get_specific(_cacheTag))
                block();
            else
                dispatch_sync(_cacheQueue, block);
            
            _friendInfoDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"QChatStaff",@"D",[organizationDic objectForKey:@"SD"],@"SD",nil];
            
            return [organizationStr dataUsingEncoding:NSUTF8StringEncoding];
        }
        return nil;
    } else {
        
        if ([[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"appstore"] ||
            [[[QIMManager getLastUserName] lowercaseString] isEqualToString:@"ctrip"]) {
            return nil;
        }
        NSString *destUrl = [NSString stringWithFormat:@"%@/getdeps?u=%@&k=%@&p=iphone&v=%@&d=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion], [[XmppImManager sharedInstance] domain]];
        
        NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
        [request setShouldCompressRequestBody:YES];
        [request setAllowCompressedResponse:YES];
        [request startSynchronous];
        
        NSError *error = [request error];
        if (!error && [request responseStatusCode] == 200) {
            NSData *responseData = [request responseData];
            NSError *errol = nil;
            id value = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:&errol];
            if (errol == nil && value) {
                
                dispatch_block_t block = ^{
                    [_friendDescDic removeAllObjects];
                    [_friendDescDic setObject:@"Qunarstaff" forKey:@"D"];
                    [_friendDescDic setObject:value forKey:@"SD"];
                };
                
                if (dispatch_get_specific(_cacheTag))
                    block();
                else
                    dispatch_sync(_cacheQueue, block);
                
                _friendInfoDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Qunarstaff",@"D",value,@"SD",nil];
            }
            return responseData;
        }
    }
    return nil;
}

//获取组织架构
- (void)checkRosterListWithForceUpdate:(BOOL)forceUpdate {

    if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
        NSString *osFile = [_configPath stringByAppendingPathComponent:@"os.bin"];
        NSString *rsFile = [_configPath stringByAppendingPathComponent:@"rs.bin"];
        
        if ([[IMDataManager sharedInstance] checkExitsUser] == NO || forceUpdate) {
            QIMWarnLog(@"qchat本地数据库之前没有IM_User, 重新拉取组织架构");
            NSError *error = nil;
            { //Roster List
                NSData *data = [self updateRosterList];
                data = [[QIMDESHelper sharedInstance] DESEncrypt:data WithKey:[QIMManager getLastUserName]];
                [[ASIDataCompressor compressData:data error:&error] writeToFile:rsFile atomically:YES];
                //获取搜索的拼音索引
                [self updateUserSuoXie];
            }
            //获取组织架构图
            
            NSData *data = [self updateOrganizationalStructure];
            data = [[QIMDESHelper sharedInstance] DESEncrypt:data WithKey:[QIMManager getLastUserName]];
            [[ASIDataCompressor compressData:data error:&error] writeToFile:osFile atomically:YES];
            [[QIMUserCacheManager sharedInstance] setUserObject:@([[NSDate date] timeIntervalSince1970]) forKey:kGetRostListVersion];
        } else {
            long long getRostListVersion = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetRostListVersion] longLongValue];
            NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
            QIMWarnLog(@"qchat拉取组织架构当前时间 : %f \n qchat上次拉取组织架构时间 : %lld", nowTime, getRostListVersion);
            if (nowTime - getRostListVersion >= 24 * 60 * 60 || forceUpdate) {
                QIMWarnLog(@"qchat拉取组织架构 时间戳 允许重新拉取");
                NSError *error = nil;
                { //Roster List
                    NSData *data = [self updateRosterList];
                    data = [[QIMDESHelper sharedInstance] DESEncrypt:data WithKey:[QIMManager getLastUserName]];
                    [[ASIDataCompressor compressData:data error:&error] writeToFile:rsFile atomically:YES];
                    //获取搜索的拼音索引
                    [self updateUserSuoXie];
                }
                //获取组织架构图
                
                NSData *data = [self updateOrganizationalStructure];
                data = [[QIMDESHelper sharedInstance] DESEncrypt:data WithKey:[QIMManager getLastUserName]];
                [[ASIDataCompressor compressData:data error:&error] writeToFile:osFile atomically:YES];
                [[QIMUserCacheManager sharedInstance] setUserObject:@([[NSDate date] timeIntervalSince1970]) forKey:kGetRostListVersion];
            }
            
            if (_friendDescDic.count <= 0) { // Roster List
                NSError *error = nil;
                BOOL isNeedUpdate = NO;
                NSData *data = [NSData dataWithContentsOfFile:rsFile];
                if (data.length <= 0) {
                    isNeedUpdate = YES;
                } else {
                    data = [ASIDataDecompressor uncompressData:data error:&error];
                    if (data == nil) {
                        isNeedUpdate = YES;
                    } else {
                        data = [[QIMDESHelper sharedInstance] DESDecrypt:data WithKey:[QIMManager getLastUserName]];
                        if (data.length <= 0) {
                            isNeedUpdate = YES;
                        } else {
                            NSArray *resultArray = [[QIMJSONSerializer sharedInstance] deserializeObject:data error:nil];
                            if (resultArray == nil) {
                                isNeedUpdate = YES;
                            } else {
                                for (NSDictionary *infoDic in resultArray) {
                                    [_friendDescDic setObject:[infoDic objectForKey:@"D"] forKey:[infoDic objectForKey:@"U"]];
                                }
                            }
                        }
                    }
                }
                if (isNeedUpdate) {
                    NSError *error = nil;
                    NSData *data = [self updateRosterList];
                    data = [[QIMDESHelper sharedInstance] DESEncrypt:data WithKey:[QIMManager getLastUserName]];
                    [[ASIDataCompressor compressData:data error:&error] writeToFile:rsFile atomically:YES];
                }
            }
            
            if (_friendInfoDic.count <= 0) { // 组织架构
                NSError *error = nil;
                BOOL isNeedUpdate = NO;
                NSData *data = [NSData dataWithContentsOfFile:osFile];
                if (data.length <= 0) {
                    isNeedUpdate = YES;
                } else {
                    data = [ASIDataDecompressor uncompressData:data error:&error];
                    if (data.length <= 0) {
                        isNeedUpdate = YES;
                    } else {
                        data = [[QIMDESHelper sharedInstance] DESDecrypt:data WithKey:[QIMManager getLastUserName]];
                        if (data.length <= 0) {
                            isNeedUpdate = YES;
                        } else {
                            NSError *error = nil;
                            id value = [[QIMJSONSerializer sharedInstance] deserializeObject:data error:&error];
                            if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
                                value = [value objectForKey:@"SD"];
                            }
                            if (error == nil && value) {
                                
                                _friendInfoDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"QChatStaff",@"D",value,@"SD",nil];
                            } else {
                                isNeedUpdate = YES;
                            }
                        }
                    }
                }
                if (isNeedUpdate) {
                    NSError *error = nil;
                    NSData *data = [self updateOrganizationalStructure];
                    data = [[QIMDESHelper sharedInstance] DESEncrypt:data WithKey:[QIMManager getLastUserName]];
                    [[ASIDataCompressor compressData:data error:&error] writeToFile:osFile atomically:YES];
                }
            }
        }
    } else {
        NSString *osFile = [_configPath stringByAppendingPathComponent:@"os.bin"];
        NSString *rsFile = [_configPath stringByAppendingPathComponent:@"rs.bin"];
        
        if ([[IMDataManager sharedInstance] checkExitsUser] == NO || forceUpdate) {
            QIMWarnLog(@"qtalk本地数据库之前没有IM_User, 重新拉取组织架构");
            NSError *error = nil;
            { //Roster List
                NSData *data = [self updateRosterList];
                data = [[QIMDESHelper sharedInstance] DESEncrypt:data WithKey:[QIMManager getLastUserName]];
                [[ASIDataCompressor compressData:data error:&error] writeToFile:rsFile atomically:YES];
                //获取搜索的拼音索引
                [self updateUserSuoXie];
            }
            //获取组织架构图
            
            NSData *data = [self updateOrganizationalStructure];
            data = [[QIMDESHelper sharedInstance] DESEncrypt:data WithKey:[QIMManager getLastUserName]];
            [[ASIDataCompressor compressData:data error:&error] writeToFile:osFile atomically:YES];
            [[QIMUserCacheManager sharedInstance] setUserObject:@([[NSDate date] timeIntervalSince1970]) forKey:kGetRostListVersion];
        } else {
            long long getRostListVersion = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kGetRostListVersion] longLongValue];
            NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
            QIMWarnLog(@"qtalk拉取组织架构当前时间 : %f \n qtalk上次拉取组织架构时间 : %lld", nowTime, getRostListVersion);
            if (nowTime - getRostListVersion >= 24 * 60 * 60 || forceUpdate) {
                QIMWarnLog(@"qtalk拉取组织架构 时间戳 允许重新拉取");
                NSError *error = nil;
                { //Roster List
                    NSData *data = [self updateRosterList];
                    data = [[QIMDESHelper sharedInstance] DESEncrypt:data WithKey:[QIMManager getLastUserName]];
                    [[ASIDataCompressor compressData:data error:&error] writeToFile:rsFile atomically:YES];
                    //获取搜索的拼音索引
                    [self updateUserSuoXie];
                }
                //获取组织架构图
                
                NSData *data = [self updateOrganizationalStructure];
                data = [[QIMDESHelper sharedInstance] DESEncrypt:data WithKey:[QIMManager getLastUserName]];
                [[ASIDataCompressor compressData:data error:&error] writeToFile:osFile atomically:YES];
                [[QIMUserCacheManager sharedInstance] setUserObject:@([[NSDate date] timeIntervalSince1970]) forKey:kGetRostListVersion];
            }
            
            if (_friendDescDic.count <= 0) { // Roster List
                NSError *error = nil;
                BOOL isNeedUpdate = NO;
                NSData *data = [NSData dataWithContentsOfFile:rsFile];
                if (data.length <= 0) {
                    isNeedUpdate = YES;
                } else {
                    data = [ASIDataDecompressor uncompressData:data error:&error];
                    if (data == nil) {
                        isNeedUpdate = YES;
                    } else {
                        data = [[QIMDESHelper sharedInstance] DESDecrypt:data WithKey:[QIMManager getLastUserName]];
                        if (data == nil) {
                            isNeedUpdate = YES;
                        } else {
                            NSArray *resultArray = [[QIMJSONSerializer sharedInstance] deserializeObject:data error:nil];
                            if (resultArray == nil) {
                                isNeedUpdate = YES;
                            } else {
                                for (NSDictionary *infoDic in resultArray) {
                                    [_friendDescDic setObject:[infoDic objectForKey:@"D"] forKey:[infoDic objectForKey:@"U"]];
                                }
                                
                            }
                        }
                    }
                }
                if (isNeedUpdate) {
                    NSError *error = nil;
                    NSData *data = [self updateRosterList];
                    data = [[QIMDESHelper sharedInstance] DESEncrypt:data WithKey:[QIMManager getLastUserName]];
                    [[ASIDataCompressor compressData:data error:&error] writeToFile:rsFile atomically:YES];
                }
            }
            
            if (_friendInfoDic.count <= 0) { // 组织架构
                NSError *error = nil;
                BOOL isNeedUpdate = NO;
                NSData *data = [NSData dataWithContentsOfFile:osFile];
                if (data.length <= 0) {
                    isNeedUpdate = YES;
                } else {
                    data = [ASIDataDecompressor uncompressData:data error:&error];
                    if (data == nil) {
                        isNeedUpdate = YES;
                    } else {
                        data = [[QIMDESHelper sharedInstance] DESDecrypt:data WithKey:[QIMManager getLastUserName]];
                        if (data == nil) {
                            isNeedUpdate = YES;
                        } else {
                            NSError *error = nil;
                            id value = [[QIMJSONSerializer sharedInstance] deserializeObject:data error:&error];
                            if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
                                value = [value objectForKey:@"SD"];
                            }
                            if (error == nil && value) {
                                
                                _friendInfoDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Qunarstaff",@"D",value,@"SD",nil];
                                
                            } else {
                                isNeedUpdate = YES;
                            }
                        }
                    }
                }
                if (isNeedUpdate) {
                    NSError *error = nil;
                    NSData *data = [self updateOrganizationalStructure];
                    data = [[QIMDESHelper sharedInstance] DESEncrypt:data WithKey:[QIMManager getLastUserName]];
                    [[ASIDataCompressor compressData:data error:&error] writeToFile:osFile atomically:YES];
                }
            }
        }
    }
}

@end

@implementation QIMManager (CommonConfig)

- (void)setIsMerchant:(BOOL)isMerchant {
    _isMerchant = isMerchant;
}

- (BOOL)isMerchant {
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
        NSDictionary *myProfile = [self getUserInfoByUserId:[self getLastJid]];
        if (myProfile.count) {
            NSString *nickName = [myProfile objectForKey:@"Name"];
            if (nickName) {
                myNickName = nickName;
            }
        }
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
            return @"https://qcweb.qunar.com/api";
        } else{
            return @"https://qtapi.qunar.com";
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
     if ([[self getWlanRequestDomain] isEqualToString:@"ejabhost1"] || [[self getWlanRequestDomain] isEqualToString:@"ejabhost2"]) {
     str = [NSString stringWithFormat:@"u=%@&k=%@", [[QIMUUIDTools loginUserName] ? [QIMUUIDTools loginUserName] : [QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[key qim_getMD5] lowercaseString]];
     }
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
    
    NSString *title = [[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat ? @"qchat" : @"qtalk";
    
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
    
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPBody:[[QIMJSONSerializer sharedInstance] serializeObject:bodyProperties error:nil]];
    [request setHTTPRequestHeaders:cookieProperties];
    
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSDictionary *resDic = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
            if (resDic.count > 0) {
                NSInteger errcode = [[resDic objectForKey:@"errcode"] integerValue];
                if (errcode == 0) {
                    if (!self->_clinetConfigDic) {
                        self->_clinetConfigDic = [NSMutableDictionary dictionaryWithCapacity:5];
                    }
                    NSDictionary *dataDic = [resDic objectForKey:@"data"];
                    [self->_clinetConfigDic setDictionary:dataDic];
                    [[QIMUserCacheManager sharedInstance] setUserObject:self->_clinetConfigDic forKey:kNewClinetConfigDic];
                    NSInteger cvVersion = [dataDic objectForKey:@"version"];
                    [[QIMUserCacheManager sharedInstance] setUserObject:@(cvVersion) forKey:kCheckConfigVersion];
                }
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (NSArray *)trdExtendInfo {
    return [_clinetConfigDic objectForKey:@"trdextendmsg"];
}

- (NSString *)getCompany {
    return [_clinetConfigDic objectForKey:@"company"];
}

- (NSString *)aaCollectionUrlHost {
    NSDictionary *otherConfig = [_clinetConfigDic objectForKey:@"otherconfig"];
    return [otherConfig objectForKey:@"aacollectionurl"];
}

- (NSString *)redPackageUrlHost {
    NSDictionary *otherConfig = [_clinetConfigDic objectForKey:@"otherconfig"];
    return [otherConfig objectForKey:@"redpackageurl"];
}

- (NSString *)redPackageBalanceUrl {
    NSDictionary *otherConfig = [_clinetConfigDic objectForKey:@"otherconfig"];
    return [otherConfig objectForKey:@"balanceurl"];
}

- (NSString *)myRedpackageUrl {
    NSDictionary *otherConfig = [_clinetConfigDic objectForKey:@"otherconfig"];
    return [otherConfig objectForKey:@"myredpackageurl"];
}

- (NSString *)getClientIp {
    return @"0.0.0.0";
}

//新消息提醒
- (BOOL)isNewMsgNotify {
    BOOL state = [[QIMManager sharedInstance] getLocalMsgNotifySettingWithIndex:QIMMSGSETTINGSOUND_INAPP];
    return state;
}

- (void)setNewMsgNotify:(BOOL)flag {
    [self setMsgNotifySettingWithIndex:QIMMSGSETTINGSOUND_INAPP WithSwitchOn:flag];
}

//新消息震动
- (BOOL)isNewMsgVibrate {
    BOOL state = [[QIMManager sharedInstance] getLocalMsgNotifySettingWithIndex:QIMMSGSETTINGVIBRATE_INAPP];
    return state;
}

- (void)setNewMsgVibrate:(BOOL)flag {
    [self setMsgNotifySettingWithIndex:QIMMSGSETTINGVIBRATE_INAPP WithSwitchOn:flag];
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

- (NSArray *)getHasAtMeByJid:(NSString *)jid {
    
    __block NSArray *array = nil;
    dispatch_block_t block = ^{
        
        array = [_hasAtMeDic objectForKey:jid];
    };
    
    if (dispatch_get_specific(_atMeCacheTag))
        block();
    else
        dispatch_sync(_atMeCacheQueue, block);
    return array;
}

- (void)addAtMeByJid:(NSString *)jid WithNickName:(NSString *)nickName {
    
    dispatch_block_t block = ^{
        
        NSMutableArray *arr = [_hasAtMeDic objectForKey:jid];
        if (arr == nil) {
            
            arr = [[NSMutableArray alloc] init];
            [_hasAtMeDic setObject:arr forKey:jid];
        }
        [arr addObject:nickName];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAtMeChange object:jid];
        });
    };
    
    if (dispatch_get_specific(_atMeCacheTag))
        block();
    else
        dispatch_sync(_atMeCacheQueue, block);
}

- (void)removeAtMeByJid:(NSString *)jid {
    
    dispatch_block_t block = ^{
        
        [_hasAtMeDic removeObjectForKey:jid];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAtMeChange object:jid];
        });
    };
    
    if (dispatch_get_specific(_atMeCacheTag))
        block();
    else
        dispatch_sync(_atMeCacheQueue, block);
}

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

- (NSDictionary *)getQChatTokenWithBusinessLineName:(NSString *)businessLineName {
    
    NSString *desturl = @"https://qcweb.qunar.com/api/http_gettk";
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:desturl]];
    NSDictionary *params = @{@"macCode": [[QIMAppInfo sharedInstance] macAddress], @"plat": (businessLineName.length > 0) ? businessLineName : @"app"};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    [request addRequestHeader:@"content-type" value:@"application/json"];
    [request appendPostData:data];
    [request startSynchronous];
    if ([request responseStatusCode] == 200) {
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            return [result objectForKey:@"data"];
        }
    }
    return nil;
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

- (BOOL)setStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType {
    
    NSDictionary *dict = @{@"topType":@(1), @"chatType":@(chatType)};
    NSString *value = [[QIMJSONSerializer sharedInstance] serializeObject:dict];
    return [[QIMManager sharedInstance] updateRemoteClientConfigWithType:QIMClientConfigTypeKStickJidDic WithSubKey:combineJid WithConfigValue:value WithDel:NO];
}

- (BOOL)removeStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType {
    NSDictionary *infoDic = @{@"chatType":@(chatType), @"topType":@(0)};
    NSString *infoStr = [[QIMJSONSerializer sharedInstance] serializeObject:infoDic];
    return [self updateRemoteClientConfigWithType:QIMClientConfigTypeKStickJidDic WithSubKey:combineJid WithConfigValue:infoStr WithDel:YES];
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

- (void)addAtALLByJid:(NSString *)jid WithMsgId:(NSString *)msgId WihtMsg:(Message *)message WithNickName:(NSString *)nickName {
    if (msgId.length > 0 && message.message.length > 0 && nickName.length > 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setQIMSafeObject:msgId forKey:@"MsgId"];
        [dic setQIMSafeObject:nickName forKey:@"NickName"];
        [dic setQIMSafeObject:message.message forKey:@"Content"];
        [dic setQIMSafeObject:message forKey:@"Msg"];
        [_hasAtAllDic setObject:dic forKey:jid];
        //Comment by lilulucas.li 6.7
//        QIMVerboseLog(@"抛出通知 addAtALLByJid:WithMsgId:WihtMsg:WithNickName: kAtALLChange");
//        [[NSNotificationCenter defaultCenter] postNotificationName:kAtALLChange object:jid];
    }
}

- (void)removeAtAllByJid:(NSString *)jid {
    [_hasAtAllDic removeObjectForKey:jid];
    dispatch_async(dispatch_get_main_queue(), ^{
        QIMVerboseLog(@"抛出通知 removeAtAllByJid: kAtALLChange");
        [[NSNotificationCenter defaultCenter] postNotificationName:kAtALLChange object:jid];
        QIMVerboseLog(@"抛出通知 removeAtAllByJid:  kNotificationSessionListUpdate");
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSessionListUpdate object:jid];
    });
}

- (NSDictionary *)getAtAllInfoByJid:(NSString *)jid {
    return [_hasAtAllDic objectForKey:jid];
}

- (BOOL)setMsgNotifySettingWithIndex:(QIMMSGSETTING)setting WithSwitchOn:(BOOL)switchOn {
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
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:str]];
    [request setRequestMethod:@"GET"];
    [request setUseCookiePersistence:NO];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setRequestHeaders:cookieProperties];
    [request startSynchronous];
    NSError *error = [request error];
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSInteger localPushFlag = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"MsgSettings"] integerValue];
            localPushFlag = localPushFlag ^ setting;
            [[QIMUserCacheManager sharedInstance] setUserObject:@(localPushFlag) forKey:@"MsgSettings"];
            return YES;
        }
    }
    return NO;
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

- (BOOL)sendServer:(NSString *)notificationToken withUsername:(NSString *)username withParamU:(NSString *)paramU withParamK:(NSString *)paramK WithDelete:(BOOL)deleteFlag {
    
    QIMVerboseLog(@"准备向帆哥服务器发送Push Token . Token : %@, 用户名 : %@, U = %@, K = %@", notificationToken, username, paramU, paramK);
    if (paramK.length <= 0 || !paramK) {
        paramK = [self updateRemoteLoginKey];
    }
    NSArray *userInfo = [username componentsSeparatedByString:@"@"];
    BOOL sendServerSuccess = NO;
    NSString *url = @"";
    if ([[QIMNavConfigManager sharedInstance] newPush] == NO) {
        url = [NSString stringWithFormat:@"%@/push/qtapi/token/setpersonmackey.qunar?username=%@&domain=%@&mac_key=%@&platname=%@&pkgname=%@&os=%@&version=%@&show_content=%@", [[QIMNavConfigManager sharedInstance] javaurl], [userInfo objectAtIndex:0], [userInfo objectAtIndex:1], notificationToken, [[[QIMAppInfo sharedInstance] deviceName] stringByReplacingOccurrencesOfString:@" " withString:@""], [[NSBundle mainBundle] bundleIdentifier], @"ios", [[QIMAppInfo sharedInstance] AppBuildVersion], @(YES)];
    } else {
        url = [NSString stringWithFormat:@"%@/qtapi/token/setpersonmackey.qunar?username=%@&domain=%@&mackey=%@&os=%@&version=%@", [[QIMNavConfigManager sharedInstance] javaurl], [userInfo objectAtIndex:0], [userInfo objectAtIndex:1], notificationToken, @"ios", [[QIMAppInfo sharedInstance] AppBuildVersion]];
    }
    if (deleteFlag) {
        url = [url stringByReplacingOccurrencesOfString:@"set" withString:@"del"];
    }
    QIMVerboseLog(@"帆哥更新Token地址 : %@", url);
    NSURL *requestUrl = [[NSURL alloc] initWithString:url];
    
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request setUseCookiePersistence:NO];
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [request setRequestHeaders:cookieProperties];
    request.timeOutSeconds = 2;
    QIMWarnLog(@"=== 开始向帆哥服务器发送PushToken请求 === ");
    [request startSynchronous];
    QIMWarnLog(@"=== 结束向帆哥服务器发送PushToken请求 === ");
    NSError *error = [request error];
    NSDictionary *result = nil;
    NSString *errmsg = nil;
    if (([request responseStatusCode] == 200) && !error) {
        NSData *responseData = [request responseData];
        result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        NSInteger errcode = [[result objectForKey:@"errcode"] integerValue];
        NSInteger ret = [[result objectForKey:@"ret"] integerValue];
        errmsg = [result objectForKey:@"errmsg"];
        if (errcode == 0) {
            if (ret == 1) {
                QIMVerboseLog(@"=== 向帆哥服务器发送PushToken成功 === %@", result);
                sendServerSuccess = YES;
            }
        }
    }
    if (!sendServerSuccess) {
        QIMErrorLog(@"=== 向帆哥服务器发送PushToken失败 === %@,  %@ ", error, errmsg);
    }
    return sendServerSuccess;
}

- (BOOL)sendPushTokenWithMyToken:(NSString *)myToken WithDeleteFlag:(BOOL)deleteFlag {
    if ([QIMManager getLastUserName].length > 0) {
        NSString *myKey = [[QIMManager sharedInstance] remoteKey];
        if (!myKey) {
            myKey = [self updateRemoteLoginKey];
        }
        if (myKey.length > 0) {
            BOOL result = [self sendServer:myToken
                              withUsername:[self getLastJid]
                                withParamU:[self getLastJid]
                                withParamK:myKey
                                WithDelete:deleteFlag];
            
            if (result) {
                QIMVerboseLog(@"更新后的PushToken为%@", myToken);
            } else {
                QIMErrorLog(@"更新PushToken失败");
            }
            return result;
        }
    }
    return NO;
}

- (void)checkClearCache {
    NSInteger clearCacheVersion = [[[QIMUserCacheManager sharedInstance] userObjectForKey:kClearCacheCheck] integerValue];
    if (clearCacheVersion < kClearCacheVersion) {
        QIMErrorLog(@"clearCacheVersion : %lu", clearCacheVersion);
        [self clearcache];
        [[QIMUserCacheManager sharedInstance] setUserObject:@(kClearCacheVersion) forKey:kClearCacheCheck];
    }
}

#warning 以下逻辑暂时都没有用到

//用户在线状态
- (void)updateUserStatus {
    NSArray *xmppIdList = [[IMDataManager sharedInstance] selectXmppIdFromSessionList];
    if (xmppIdList.count <= 0) {
        return;
    }
    BOOL needRefreshUI = NO;
    NSMutableDictionary *xmppIdDic = [NSMutableDictionary dictionary];
    for (NSString *xmppId in xmppIdList) {
        NSArray *coms = [xmppId componentsSeparatedByString:@"@"];
        NSString *userId = [coms firstObject];
        NSString *domain = [coms lastObject];
        if (domain && userId) {
            NSMutableArray *users = [xmppIdDic objectForKey:domain];
            if (users == nil) {
                users = [NSMutableArray array];
                [xmppIdDic setObject:users forKey:domain];
            }
            [users addObject:userId];
        }
    }
    NSMutableArray *params = [NSMutableArray array];
    for (NSString *domain in xmppIdDic.allKeys) {
        NSArray *users = [xmppIdDic objectForKey:domain];
        [params addObject:@{@"domain": domain, @"users": users}];
    }
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:params error:nil];
    NSString *destUrl = [NSString stringWithFormat:@"%@/domain/get_user_status?u=%@&k=%@&platform=iphone&version=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    [request addRequestHeader:@"Content-type" value:@"application/json;"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:[NSMutableData dataWithData:requestData]];
    [request startSynchronous];
    
    NSError *error = [request error];
    NSDictionary *result = nil;
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        [_onlineTables removeAllObjects];
        BOOL ret = [[result objectForKey:@"ret"] boolValue];
        if (ret) {
            NSArray *list = [result objectForKey:@"data"];
            __block NSMutableArray *needRefreshUseIds = [NSMutableArray arrayWithCapacity:10];
            for (NSDictionary *dataDic in list) {
                NSString *domain = [dataDic objectForKey:@"domain"];
                NSArray *userList = [dataDic objectForKey:@"ul"];
                for (NSDictionary *userDic in userList) {
                    NSString *userId = [userDic objectForKey:@"u"];
                    NSString *state = [userDic objectForKey:@"o"];
                    NSString *xmppId = [userId stringByAppendingFormat:@"@%@", domain];
                    if ([[[IMDataManager sharedInstance] getSessionListXMPPIDWithSingleChatType:ChatType_SingleChat] containsObject:xmppId]) {
                        [needRefreshUseIds addObject:xmppId];
                        needRefreshUI = YES;
                    }
                    if (state.length > 0 && [userId stringByAppendingFormat:@"@%@", domain].length > 0) {
                        [_onlineTables setObject:state forKey:[userId stringByAppendingFormat:@"@%@", domain]];
                    }
                }
            }
            if (needRefreshUI) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyUserOnlineStateUpdate object:needRefreshUseIds];
                });
            }
        }
    }
}

- (void)loadOnlineUsers {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadOnlineUsers) object:nil];
    dispatch_async(_load_user_state_queue, ^{
        if ([self isLogin]) {
            [self updateUserStatus];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(loadOnlineUsers) withObject:nil afterDelay:120];
        });
    });
}

- (void)loadOnlineList {
    
    // 应该考虑多domain的情况，但是因为server在下状态的时候未能提供这个信息，所以先写在这里
    dispatch_async(_load_user_state_queue, ^{
        NSMutableString *userString = [[NSMutableString alloc] initWithCapacity:10];
        int index = 0;
        NSArray *list = [[IMDataManager sharedInstance] selectUserIdList];
        for (NSString *user in list) {
            [userString appendString:user];
            if (index < list.count - 1) {
                [userString appendString:@","];
            }
            index++;
        }
        NSDictionary *result = [self userStatusWithUserStrings:userString];
        NSArray *userStatus = [result objectForKey:@"data"];
        for (NSDictionary *info in userStatus) {
            NSString *u = [info objectForKey:@"U"];
            int status = [[info objectForKey:@"S"] intValue];
            if (status == 0) {
                [_onlineTables setObject:@"offline" forKey:u];
            } else {
                [_onlineTables setObject:@"available" forKey:u];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyUserOnlineStateUpdate object:nil];
        });
        
        if ([self isLogin]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(loadOnlineList) withObject:nil afterDelay:5];
            });
        }
    });
}

- (NSMutableDictionary *)userStatusWithUserStrings:(NSString *)userString {
    NSString *destUrl = [NSString stringWithFormat:@"%@/getuserstatus?u=%@&k=%@&p=iphone&v=%@", [[QIMNavConfigManager sharedInstance] httpHost], [[QIMManager getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], self.remoteKey, [[QIMAppInfo sharedInstance] AppBuildVersion]];
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:requestUrl];
    NSString *body = [NSString stringWithFormat:@"users=%@", userString];
    NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
    [request appendPostData:data];
    [request setAllowCompressedResponse:YES];
    [request setShouldCompressRequestBody:YES];
    [request startSynchronous];
    
    NSError *error = [request error];
    NSMutableDictionary *result = nil;
    if ([request responseStatusCode] == 200 && !error) {
        NSData *responseData = [request responseData];
        result = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
    }
    return result;
}

- (NSString *)userOnlineStatus:(NSString *)sid {
    return [_onlineTables objectForKey:sid];
}

- (BOOL)isUserOnline:(NSString *)userId {
    
    if (userId) {
        
        NSString *tempUserId = [userId copy];
        if (_channelInfoDic) {
            NSString *channelInfo = [_channelInfoDic objectForKey:tempUserId];
            if (channelInfo.length > 0) {
                return YES;
            }
        } else {
            if (_onlineTables.count && _onlineTables) {
//                判断用户是否在在线数组里
                NSString *onlineState = [_onlineTables objectForKey:tempUserId];
                if (onlineState.length > 0) {
                    if ([onlineState isEqualToString:@"online"]) {
                        return YES;
                    } else if ([onlineState isEqualToString:@"away"]) {
                        return NO;
                    } else {
                        return NO;
                    }
                } else {
                    return NO;
                }
            }
        }
    }
    return NO;
}

- (UserPrecenseStatus)getUserPrecenseStatus:(NSString *)jid {
    
    return [self getUserPrecenseStatus:jid status:nil];
}

- (UserPrecenseStatus)getUserPrecenseStatus:(NSString *)jid status:(NSString **)status {
    /*
    NSDictionary *infoDic = [[XmppUserPresence sharedInstance] userPresenceStatus:jid];
    NSString *show = [infoDic objectForKey:@"show"];
    if (status) {
        
        *status = [infoDic objectForKey:@"status"];
    }
    if ([show isEqualToString:@"away"]) {
        
        return UserPrecenseStatus_Away;
    } else if ([show isEqualToString:@"dnd"]) {
        
        return UserPrecenseStatus_Dnd;
    }
     */
    return UserPrecenseStatus_None;
}

@end
