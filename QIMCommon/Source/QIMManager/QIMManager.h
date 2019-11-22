#import <Foundation/Foundation.h>
#import "QIMCommonEnum.h"
#import "IMDataManager.h"
#import "IMDataManager+QIMSession.h"
#import "IMDataManager+QIMSearchKeyHistory.h"
#import "IMDataManager+QIMCalendar.h"
#import "IMDataManager+QIMDBClientConfig.h"
#import "IMDataManager+QIMDBQuickReply.h"
#import "IMDataManager+QIMNote.h"
#import "IMDataManager+QIMDBGroup.h"
#import "IMDataManager+QIMDBFriend.h"
#import "IMDataManager+QIMDBMessage.h"
#import "IMDataManager+QIMFoundList.h"
#import "IMDataManager+QIMDBCollectionMessage.h"
#import "IMDataManager+QIMDBPublicNumber.h"
#import "IMDataManager+QIMDBUser.h"
#import "IMDataManager+WorkFeed.h"
#import "IMDataManager+QIMUserMedal.h"
#import "YYDispatchQueuePool.h"

#define DEFAULT_MSG_NUM 450
#define DEFAULT_CHATMSG_NUM 1000
#define DEFAULT_GROUPMSG_NUM 1500

@class UserInfo,QIMMessageModel;
@interface QIMManager : NSObject

#pragma mark - Definition Queue

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t receive_msg_queue;
@property (nonatomic, strong) dispatch_queue_t receive_msgSendState_queue;
@property (nonatomic, strong) dispatch_queue_t receive_notify_queue;
@property (nonatomic, strong) dispatch_queue_t receive_msgReadState_queue;    //接收消息阅读状态Queue
@property (nonatomic, strong) dispatch_queue_t load_user_state_queue;
//@property (nonatomic, strong) NSOperationQueue *loginComplateQueue;
//@property (nonatomic, strong) NSInvocationOperation *loginComplateOperation;
//@property (nonatomic, strong) dispatch_queue_t loginComplateQueue;
@property (nonatomic, strong) dispatch_queue_t load_history_msg;
@property (nonatomic, strong) dispatch_queue_t load_offlineSingleHistory_msg;
@property (nonatomic, strong) dispatch_queue_t load_offlineGroupHistory_msg;
@property (nonatomic, strong) dispatch_queue_t load_offlineSystemHistory_msg;
@property (nonatomic, strong) dispatch_queue_t load_customEvent_queue;
@property (nonatomic, strong) dispatch_queue_t lastQueue;

@property (nonatomic, strong) YYDispatchQueuePool *load_user_header;
@property (nonatomic, strong) YYDispatchQueuePool *load_session_content;
@property (nonatomic, strong) YYDispatchQueuePool *load_session_name;
@property (nonatomic, strong) YYDispatchQueuePool *load_session_unreadcount;
@property (nonatomic, strong) YYDispatchQueuePool *load_groupDB_VCard;
@property (nonatomic, strong) YYDispatchQueuePool *load_msgNickName;
@property (nonatomic, strong) YYDispatchQueuePool *load_msgMedalList;
@property (nonatomic, strong) YYDispatchQueuePool *load_msgHeaderImage;

@property (nonatomic, strong) dispatch_queue_t update_group_member_queue;
@property (nonatomic, strong) dispatch_queue_t load_group_offline_msg_queue;
@property (nonatomic, strong) dispatch_queue_t update_chat_card;
@property (nonatomic, strong) dispatch_queue_t update_group_card;
@property (nonatomic, strong) dispatch_queue_t cacheQueue;            // cache 线程
@property (nonatomic, strong) dispatch_queue_t atMeCacheQueue;

#else
@property (nonatomic, assign) dispatch_queue_t receive_msg_queue;
@property (nonatomic, assign) dispatch_queue_t receive_msgSendState_queue;  //接收消息发送状态Queue
@property (nonatomic, assign) dispatch_queue_t receive_notify_queue;    //接收Presence Queue
@property (nonatomic, assign) dispatch_queue_t receive_msgReadState_queue;    //接收消息阅读状态Queue
@property (nonatomic, assign) dispatch_queue_t load_user_state_queue;
//@property (nonatomic, assign) NSOperationQueue *loginComplateQueue;
//@property (nonatomic, assign) NSInvocationOperation *loginComplateOperation;
//@property (nonatomic, assign) dispatch_queue_t loginComplateQueue;
@property (nonatomic, assign) dispatch_queue_t load_history_msg;
@property (nonatomic, assign) dispatch_queue_t load_offlineSingleHistory_msg;
@property (nonatomic, assign) dispatch_queue_t load_offlineGroupHistory_msg;
@property (nonatomic, assign) dispatch_queue_t load_offlineSystemHistory_msg;
@property (nonatomic, assign) dispatch_queue_t load_customEvent_queue;
@property (nonatomic, assign) dispatch_queue_t load_user_header;
@property (nonatomic, assign) dispatch_queue_t load_session_content;
@property (nonatomic, assign) dispatch_queue_t update_group_member_queue;
@property (nonatomic, assign) dispatch_queue_t load_group_offline_msg_queue;
@property (nonatomic, assign) dispatch_queue_t update_chat_card;
@property (nonatomic, assign) dispatch_queue_t update_group_card;
@property (nonatomic, assign) dispatch_queue_t cacheQueue;            // cache 线程
@property (nonatomic, strong) dispatch_queue_t atMeCacheQueue;

#endif

@property (nonatomic, strong) NSString *defaultUserAgent;   //默认的UA
@property (nonatomic) void *cacheTag;             // cache 线程锁

@property (nonatomic) void *atMeCacheTag;

@property (nonatomic, assign) BOOL isIPad;

@property (nonatomic, copy) NSString *remoteKey;
@property (nonatomic, assign) int serverTimeDiff;

@property (nonatomic, assign) BOOL isLoadMerchant;                         //是否为最新设置的客服状态
@property (nonatomic, assign) BOOL isMerchant;                             //是否为客服

@property (nonatomic, strong) NSMutableDictionary *userMarkupNameDic;    //用户备注信息
@property (nonatomic, strong) NSMutableDictionary *stickJidDic;          //置顶Id列表

//Group
@property (nonatomic, strong) NSMutableDictionary *notMindGroupDic;       //接收但不提醒消息的群

//Cookie
@property (nonatomic, strong) NSHTTPCookie *ucookie;
@property (nonatomic, strong) NSHTTPCookie *kcookie;

@property (nonatomic, copy) NSString *imageCachePath;                   //图片缓存地址
@property (nonatomic, copy) NSString *downLoadFile;                     //文件下载路径

@property (nonatomic, strong) NSString *currentSessionUserId;
@property (nonatomic, assign) BOOL isStartPushNotify;                    //是否开始Push通知
@property (nonatomic, assign) BOOL ismyOnlinePushFlag;                   //是否开启在线也收Push通知
@property (nonatomic, strong) NSMutableDictionary *friendDescDic;
@property (nonatomic, strong) NSMutableDictionary *friendInfoDic;        //好友昵称信息
@property (nonatomic, strong) NSMutableDictionary *groupInfoDic;
// 落地了
@property (nonatomic, strong) NSMutableDictionary *notReadMsgDic;        //未读消息数
@property (nonatomic, strong) NSMutableDictionary *notReadMsgByGroupDic;  //未读群消息

@property (nonatomic, strong) NSMutableArray *groupList;
@property (nonatomic, strong) NSMutableDictionary *onlineTables;         // session 在线状态列表
@property (nonatomic, strong) NSMutableDictionary *userBigHeaderDic;      //用户高清头像字典
@property (nonatomic, strong) NSMutableDictionary *userNormalHeaderDic;   //用户普通头像字典
@property (nonatomic, strong) NSMutableDictionary *userInfoDic;           //用户内存化名片信息

@property (nonatomic, strong) NSString *soundName;

@property (nonatomic, strong) NSMutableDictionary *hasAtMeDic;           //At 字典
@property (nonatomic, strong) NSMutableDictionary *hasAtAllDic;          //At All
@property (nonatomic, strong) NSMutableDictionary *conversationParamDic;         //会话参数
@property (nonatomic, strong) NSMutableDictionary *notSendTextDic;       //为发送的文本
@property (nonatomic, strong) NSMutableDictionary *timeStempDic;
@property (nonatomic, strong) NSMutableDictionary *chatIdInfoDic;        //会话ChatId 字典
@property (nonatomic, strong) NSMutableArray *myGroupList;                //已存在群列表
@property (nonatomic, strong) NSMutableArray *updateGroupList;            //群增量列表
@property (nonatomic, strong) NSMutableArray *updateGroupIdList;          //群增量Id列表
@property (nonatomic, assign) NSTimeInterval lastMaxGroupVersion;          //最后群时间
@property (nonatomic, strong) NSMutableDictionary *channelInfoDic;       //渠道信息
@property (nonatomic, strong) NSMutableDictionary *appendInfoDic;         //各业务线或部门追加信息
@property (nonatomic, strong) NSMutableArray *clientConfigUpgradeArray;   //个人配置升级 2018.7.13

//Login
@property (nonatomic, assign) BOOL isBackgroundLogin;   //是否是后台登录，YES 是后台重新登录，NO 是前台人工登录
@property (nonatomic, assign) BOOL willCancelLogin;
@property (nonatomic, assign) BOOL needTryRelogin;      //是否需要重试登录
@property (nonatomic, assign) BOOL notNeedCheckNetwotk;    //是否需要检查网络，防止登录失败也一直刷


@property (nonatomic, copy) NSString *imLoginDomain;  //Domain
@property (nonatomic, assign) QTLoginType imLoginType; //登录方式
@property (nonatomic, copy) NSString *imLoginXmppHost;    //Host Name
@property (nonatomic, copy) NSString *imLoginPort;  //xmpp端口
@property (nonatomic, copy) NSString *imLoginProtobufPort;   //Pb端口


// userList

@property (nonatomic, strong) QIMMessageModel *msg;    //获取历史消息用的模型
@property (nonatomic, strong) NSMutableArray *memberMessageArray;

@property (nonatomic, strong) NSMutableSet *sendFileMessageSet;

@property (nonatomic, strong) NSMutableDictionary *lastReceiveGroupMsgTimeDic;

@property (nonatomic, strong) NSMutableDictionary *groupHeaderImageDic;

@property (nonatomic, copy) NSString *groupHeaderImageCachePath; //群头像缓存地址
@property (nonatomic, strong) NSMutableArray *emptyHeaderArray;    //头像缓存空的时候
@property (nonatomic, strong) NSMutableArray *emptyVCardArray;     //名片获取空

@property (nonatomic, strong) NSMutableDictionary *lastLoginTimeDic;

@property (nonatomic, assign) NSTimeInterval lastSingleReadFlagMsgTime;     //拉取单人已读未读消息时间戳
@property (nonatomic, assign) NSTimeInterval lastSingleMsgTime;     //拉取单人消息时间戳
@property (nonatomic, assign) NSTimeInterval lastGroupMsgTime;      //拉取群组消息时间戳
@property (nonatomic, assign) NSTimeInterval lastSystemMsgTime;     //拉取HeadLine消息时间戳
@property (nonatomic, assign) NSTimeInterval lastMaxMucReadMarkTime;   //拉取群阅读指针时间戳
@property (nonatomic, assign) NSTimeInterval lastWorkFeedMsgMsgTime;     //拉取驼圈消息时间戳

@property (nonatomic, strong) NSMutableDictionary *groupVCardDict;  //群聊名片缓存Dict
@property (nonatomic, strong) NSMutableDictionary *userVCardDict;   //用户名片缓存Dict
@property (nonatomic, strong) NSMutableDictionary *collectionUserVCardDict; //代收用户缓存Dict

@property (nonatomic, strong) NSMutableDictionary *hotCommentUUIdsDic;     //驼圈热门评论UUIds

@property (nonatomic, assign) BOOL latestGroupMessageFlag;  //是否还能继续拉群消息
@property (nonatomic, assign) BOOL latestSingleMessageFlag;  //是否还能继续拉群消息
@property (nonatomic, assign) BOOL latestSystemMessageFlag;  //是否还能继续拉群消息

@property (nonatomic, assign) BOOL getSingleHistoryFailed;      //拉取单人消息失败
@property (nonatomic, assign) BOOL getGroupHistoryFailed;       //拉取群组下消息失败
@property (nonatomic, assign) BOOL getSystemHistoryFailed;      //拉取HeadLine消息失败

@property (atomic, strong) NSMutableSet *msgCompensateReadSet;   //消息已读状态补偿逻辑

@property (atomic, strong) NSMutableArray *notReaderIndexPathList;   //SessionView 未读IndexPath数组

@property (nonatomic, copy) NSString *webName;                  //Qunar账户webName

@property (nonatomic, strong) NSMutableDictionary *clientConfigDic;     //CheckConfig缓存

@property (atomic, strong) NSMutableDictionary *shareLocationDic;
@property (atomic, strong) NSMutableDictionary *shareLocationFromIdDic;
@property (atomic, strong) NSMutableDictionary *shareLocationUserDic;


@property (nonatomic, strong) NSMutableDictionary *userResourceDic;     //用户Resources

@property (nonatomic, strong) NSMutableArray *middleVirtualAccounts;

+ (instancetype)sharedInstance;

- (void)initUserDicts;

- (void)clearQIMManager;

- (NSMutableDictionary *)timeStempDic;

- (dispatch_queue_t)cacheQueue;

- (void*)cacheTag;


- (NSString *)getImagerCache;

- (NSString *)updateRemoteLoginKey;

- (void)generateClientConfigUpgradeArrayWithType:(QIMClientConfigType)type WithArray:(id)valueArr;

@end

@interface QIMManager (Common)

- (NSData *)updateOrganizationalStructure;

@end


@interface QIMManager (CommonConfig)

/**
 UK，登录之后服务器下发下来，用作旧接口的验证
 */
- (NSString *)remoteKey;

- (NSString *)myRemotelogginKey;


/**
 第三方认证的key - Ckey/q_ckey
 */
- (NSString *) thirdpartKeywithValue;


/**
 客服状态
 */
- (BOOL)isMerchant;

/**
 *  UserName Ex: lilulucas.li
 *
 *  @return UserName
 */
+ (NSString *)getLastUserName;


/**
 更新最后一个登录用户的临时Token

 @param token 用户token
 */
- (void)updateLastTempUserToken:(NSString *)token;

/**
 获取最后一个登录用户的临时Token

 @return 用户token
 */
- (NSString *)getLastTempUserToken;

/**
 更新最后一个登录用户的token

 @param tempUserToken 用户token
 */
- (void)updateLastUserToken:(NSString *)tempUserToken;


/**
 获取最后一个登录用户的token

 @return 用户token
 */
- (NSString *)getLastUserToken;

/**
 *  PWD
 *
 *  @return 无用
 */
- (NSString *)getLastPassword;

/**
 *  JID  Ex: lilulucas.li@ejabhost1
 *
 *  @return JID
 */
- (NSString *)getLastJid;

/**
 *  nickName  Ex: 李露lucas
 *
 *  @return MyNickName
 */
- (NSString *)getMyNickName;

/**
 获取当前登录的domain
 */
- (NSString *)getDomain;

- (long long)getCurrentServerTime;


- (int)getServerTimeDiff;

- (NSHTTPCookie *)cookie;

- (NSString *)getWlanRequestURL;

- (NSString *)getWlanRequestDomain;

- (NSString *)getWlanKeyByTime:(int)time;

- (NSDictionary *)loadWlanCookie;

// 更新导航配置
- (void)updateNavigationConfig;

- (void)checkClientConfig;

- (NSArray *)trdExtendInfo;

- (NSString *)aaCollectionUrlHost;

- (NSString *)redPackageUrlHost;

- (NSString *)redPackageBalanceUrl;

- (NSString *)myRedpackageUrl;

#pragma mark get user agent
- (NSString *)getDefaultUserAgentString;

//新消息提醒
- (BOOL)isNewMsgNotify;

- (void)setNewMsgNotify:(BOOL)flag;

//新消息震动
- (BOOL)isNewMsgVibrate;

- (void)setNewMsgVibrate:(BOOL)flag;

//相册是否发送原图
- (BOOL)pickerPixelOriginal;

- (void)setPickerPixelOriginal:(BOOL)flag;

//OPS发现页RN调试
- (NSString *)opsFoundRNDebugUrl;

- (void)setOpsFoundRNDebugUrl:(NSString *)opsFoundRNDebugUrl;

//qtalk发现页测试地址
- (NSString *)qtalkFoundRNDebugUrl;

- (void)setQtalkFoundRNDebugUrl:(NSString *)qtalkFoundRNDebugUrl;

//qtalk搜索测试地址
- (NSString *)qtalkSearchRNDebugUrl;

- (void)setQtalkSearchRNDebugUrl:(NSString *)qtalkSearchRNDebugUrl;

//是否优先展示对方个性签名
- (BOOL)moodshow;

- (void)setMoodshow:(BOOL)flag;

//是否展示水印
- (BOOL)waterMarkState;

- (void)setWaterMarkState:(BOOL)flag;

//At消息
- (NSArray *)getHasAtMeByJid:(NSString *)jid ;

- (void)updateAtMeMessageWithJid:(NSString *)groupId withMsgIds:(NSArray *)msgIds withReadState:(QIMAtMsgReadState)readState;

- (void)clearAtMeMessageWithJid:(NSString *)groupId;

- (void)addOfflineAtMeMessageByJid:(NSString *)groupId withType:(QIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime;

- (void)addAtMeMessageByJid:(NSString *)groupId withType:(QIMAtType)atType withMsgId:(NSString *)msgId withMsgTime:(long long)msgTime;

//输入框草稿
- (NSDictionary *)getNotSendTextByJid:(NSString *)jid ;

- (void)setNotSendText:(NSString *)text inputItems:(NSArray *)inputItems ForJid:(NSString *)jid;

- (void)getQChatTokenWithBusinessLineName:(NSString *)businessLineName withCallBack:(QIMKitGetQChatTokenSuccessBlock)callback;

- (NSDictionary *)getQVTForQChat;

- (void)removeQVTForQChat;

- (NSString *)getDownloadFilePath;

- (void)clearcache;

- (void)setStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType withCallback:(QIMKitUpdateRemoteClientConfig)callback;

- (void)removeStickWithCombineJid:(NSString *)combineJid WithChatType:(ChatType)chatType withCallback:(QIMKitUpdateRemoteClientConfig)callback;

- (BOOL)isStickWithCombineJid:(NSString *)jid;

- (NSDictionary *)stickList;

- (void)setMsgNotifySettingWithIndex:(QIMMSGSETTING)setting WithSwitchOn:(BOOL)switchOn withCallBack:(QIMKitSetMsgNotifySettingSuccessBlock)callback;

- (BOOL)getLocalMsgNotifySettingWithIndex:(QIMMSGSETTING)setting;

- (void)getMsgNotifyRemoteSettings;

- (void)sendQChatOnlineNotification;

#pragma mark - kNotificationSetting

- (void)sendNoPush;

- (void)sendServer:(NSString *)notificationToken withUsername:(NSString *)username withParamU:(NSString *)paramU withParamK:(NSString *)paramK WithDelete:(BOOL)deleteFlag withCallback:(QIMKitRegisterPushTokenSuccessBlock)callback;

- (void)sendPushTokenWithMyToken:(NSString *)myToken WithDeleteFlag:(BOOL)deleteFlag withCallback:(QIMKitRegisterPushTokenSuccessBlock)callback;

- (void)findNewestClient;

- (void)checkClearCache;

- (void)checkMsTimeInterval:(NSInteger *)time;

@end
