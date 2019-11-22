//
//  STIMCommonEnum.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/30.
//

#ifndef STIMCommonEnum_h
#define STIMCommonEnum_h

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    STIMProjectTypeStartalk = 0,
    STIMProjectTypeQChat = 1,
    STIMProjectTypeQTalk = 2,
} STIMProjectType;

typedef enum : NSUInteger {
    STIMApplicationStateLaunch,  //应用重新启动
    STIMApplicationStateActive,  //应用从后台回到前台
} STIMApplicationState;

typedef enum {
    QDDealState_None = 0,
    QDDealState_True,
    QDDealState_Faild,
    QDDealState_TimeOut,
} QDDealState;

typedef enum {
    AdvertType_Touch = 1,
    AdvertType_Image = 2,
    AdvertType_Video = 3,
} AdvertType;

typedef enum {
    QTLoginTypeSms = 0,
    QTLoginTypePwd = 1,
    QTLoginTypeNewPwd = 2,
    QTLoginTypeNone = 3,
} QTLoginType;

typedef enum {
    AppWorkState_Logout = 0,
    AppWorkState_Logining = 1,
    AppWorkState_Updating = 2,
    AppWorkState_Login = 3,
    AppWorkState_NotNetwork = 4,
    AppWorkState_NetworkNotWork = 5,
    AppWorkState_ReLogining = 6,
    AppWorkState_Upgrading = 7, //升级数据中
} AppWorkState;

typedef enum {
    UserPrecenseStatus_Away,
    UserPrecenseStatus_Dnd,
    UserPrecenseStatus_None,
} UserPrecenseStatus;

typedef enum {
    PublicNumberType_Robot,
    PublicNumberType_News,
    PublicNumberType_System,
    PublicNumberType_Notice,
} PublicNumberType;

typedef enum {
    PublicNumberMsgType_None                = 0,
    PublicNumberMsgType_Text                = 1,
    PublicNumberMsgType_Voice               = 2,
    PublicNumberMsgType_Image               = 3,
    PublicNumberMsgType_SogoIcon            = 4,
    PublicNumberMsgType_File                = 5,
    PublicNumberMsgType_Action              = 6,
    PublicNumberMsgType_RichText            = 7,
    PublicNumberMsgType_ActionRichText      = 8,
    PublicNumberMsgType_ClientCookie        = 9,
    PublicNumberMsgType_PostBackCookie      = 10,
    MessageType_note                        = 11,
    PublicNumberMsgType_time                = 101,
    // 扩展消息类型
    PublicNumberMsgType_LocalShare          = 1 << 4,
    PublicNumberMsgType_SmallVideo          = 1 << 5,
    PublicNumberMsgType_SourceCode          = 1 << 6,
    PublicNumberMsgType_BurnAfterRead       = 1 << 7,
    
    MessageType_virtualRbt = 1 << 14,//callcenter 机器人消息
    MessageType_instruction = 1 << 15,//callcenter 指令类型
    
    MessageType_C2BGrabSingle = 2003,  //C2B抢单
    MessageType_C2BGrabSingleFeedBack = 2004, //C2B抢单返回
    MessageType_QCZhongbao  = 2005, //众包消息
    
    PublicNumberMsgType_Notice              = 1 << 27,
    PublicNumberMsgType_OrderNotify         = 1 << 28,
    
} PublicNumberMsgType;

typedef enum {
    ShareLocationType_Join = 1,
    ShareLocationType_Info = 2,
    ShareLocationType_Quit = 3,
} ShareLocationType;

typedef enum {
    STIMFileCacheTypeDefault,
    STIMFileCacheTypeColoction,
} STIMFileCacheType;

typedef enum ProtocolType{
    ProtocolType_Xmpp,
    ProtocolType_Protobuf,
} ProtocolType;

typedef enum {
    STIMGroupIdentityOwner       = 0,
    STIMGroupIdentityAdmin       = 1,
    STIMGroupIdentityNone       = 2,
} STIMGroupIdentity;

typedef enum {
    STIMVerifyMode_AllAgree = 3,    //全部同意
    STIMVerifyMode_Validation = 1,  //人工同意
    STIMVerifyMode_Question_Answer = 2,  //问题认证
    STIMVerifyMode_AllRefused = 0,  //全部拒绝
} STIMVerifyMode;

typedef enum {
    STIMTextBarExpandViewItemType_Photo               = 0,//相册
    STIMTextBarExpandViewItemType_Camer               = 1,//拍照
    STIMTextBarExpandViewItemType_QuickReply          = 2,//快捷回复
    STIMTextBarExpandViewItemType_VideoCall           = 3,//视频聊天
    STIMTextBarExpandViewItemType_Location            = 4,//发送位置
    STIMTextBarExpandViewItemType_BurnAfterReading    = 5,//阅后即焚
    STIMTextBarExpandViewItemType_MyFiles             = 6,//我的文件
    STIMTextBarExpandViewItemType_Shock               = 7,//窗口抖动
    STIMTextBarExpandViewItemType_ChatTransfer        = 8,//会话转移
    STIMTextBarExpandViewItemType_ShareCard           = 9,//分享名片
    STIMTextBarExpandViewItemType_RedPack             = 10,//红包
    STIMTextBarExpandViewItemType_AACollection        = 11,//AA收款
    STIMTextBarExpandViewItemType_SendProduct         = 12,//发送产品
    STIMTextBarExpandViewItemType_SendActivity        = 13,//发送活动
} STIMTextBarExpandViewItemType;

typedef enum {
    
    STIMMessageType_NewMsgTag   = -111,
    STIMMessageType_TransToUser = -33,
    STIMMessageType_PNote       = -11,
    STIMMessageType_CNote       = 11,
    STIMMessageType_Revoke      = -1,
    STIMMessageType_None        = 0,
    STIMMessageType_Text        = 1,
    STIMMessageType_Voice       = 2,
    STIMMessageType_Image       = 3,
    STIMMessageType_SogoIcon    = 4,
    STIMMessageType_File        = 5,
    STIMMessageType_Topic       = 6,
    
    STIMMessageType_Reply       = 9,
    STIMMessageType_Shock       = 10,
    STIMMessageType_NewAt       = 12,
    STIMMessageType_Markdown    = 13,
    STIMMessageType_GroupNotify = 15,
    STIMMessageType_ImageNew    = 30,
    STIMMessageType_RobotAnswer = 47,
    STIMMessageType_Time        = 101,
    // 扩展消息类型
    STIMMessageType_LocalShare  = 1 << 4,
    STIMMessageType_SmallVideo  = 1 << 5,
    STIMMessageType_SourceCode  = 1 << 6,
    STIMMessageType_BurnAfterRead = 1 << 7,
    STIMMessageType_CardShare = 1 << 8,
    STIMMessageTypeMeetingRemind = 257,
    STIMMessageTypeWorkMomentRemind = 258,
    STIMMessageTypeUserMedalRemind = 259,
    STIMMessageType_RedPack = 1 << 9,
    STIMMessageType_AA = (1 << 9) + 1,
    STIMMessageType_RedPackInfo = 1 << 10,
    STIMMessageType_AAInfo = (1 << 10)+ 1,
    STIMMessageType_product = 1 << 12,
    STIMMessageType_shareLocation = 1 << 13,
    
    // 第三方平台
    STIMMessageType_Consult = 2001,
    STIMMessageType_ConsultResult = 2002,
    STIMMessageType_MicroTourGuide = 3001,
    STIMMessageType_activity = 511,
    
    // 通用的第三方信息Cell 类似链接形式的消息气泡
    STIMMessageType_CommonTrdInfo = 666,
    STIMMessageType_CommonTrdInfoPer = 667,//desc显示完整的 666
    STIMMessageType_Forecast = 668,  //预测消息(666消息复制版，PC只显示body)
    STIMMessageType_ExProduct = 888,
    
    // 扩展机器人里的消息
    STIMMessageType_RichText            = 7,
    STIMMessageType_ActionRichText      = 8,
    STIMMessageType_Notice              = 1 << 27,
    
    STIMWebRTC_MsgType_Audio = 131072,
    STIMWebRTC_MsgType_Video = 65535,
    STIMMessageTypeRobotQuestionList = 65536,
    STIMMessageTypeRobotTurnToUser = 65537,
    STIMMessageTypeWebRtcMsgTypeVideoMeeting = 5001,
    STIMMessageTypeQChatRobotQuestionList = 65538,
    STIMMessageTypeWebRtcMsgTypeVideoGroup = 65534,
    STIMMessageType_WebRTC_Vedio = 65505,
    STIMMessageType_WebRTC_Audio = 65506,
    STIMMessageType_TransChatToCustomer = 1001,
    STIMMessageType_TransChatToCustomer_Feedback = 1003,
    STIMMessageType_TransChatToCustomerService = 1002,
    STIMMessageType_TransChatToCustomerService_Feedback = 1004,
    
    STIMMessageType_Encrypt = 404, //加密消息
    
} STIMMessageType;

typedef enum {
    MessageClassType_Normal = 0,
    MessageClassType_Info = 1,
    MessageClassType_Hidden = 2,
} MessageClassType;

typedef enum {
    ChatType_SingleChat        = 0,
    ChatType_GroupChat         = 1,
    ChatType_System            = 2,
    ChatType_PublicNumber      = 3,
    ChatType_Consult           = 4,
    ChatType_ConsultServer     = 5,
    ChatType_CollectionChat    = 6,
} ChatType;

typedef enum : NSUInteger {
    STIMAtTypeSP = 0,        //艾特指定人
    STIMAtTypeALL,           //艾特所有
} STIMAtType;

typedef enum : NSUInteger {
    STIMAtMessgaeNotRead = 0,    //艾特消息未读
    STIMAtMessgaeHasRead = 1,    //艾特消息已读
} STIMAtMessgaeReadState;

typedef enum : NSUInteger {
    STIMAtMsgNotReadState = 0,  //艾特消息未读
    STIMAtMsgHasReadState,      //艾特消息已读
} STIMAtMsgReadState;

typedef enum {
    MessageReadFlagDidSend = 3,
    MessageReadFlagDidRead = 4,
} MessageReadFlag;

typedef enum {
    STIMMessageRemoteReadStateNotSent = 0x00,       //发送到服务器
    STIMMessageRemoteReadStateDidSent = 0x01,         //已送达，对方已接受
    STIMMessageRemoteReadStateDidReaded = STIMMessageRemoteReadStateDidSent << 1,    //0x02已阅读，对方已读
    STIMMessageRemoteReadStateGroupReaded = 0x03,  //群消息已读
    STIMMessageRemoteReadStateDidOperated = 0x04,  //已操作
} STIMMessageRemoteReadState; //消息操作状态

typedef enum {
    STIMMessageReadFlagClearAllUnRead = 0,    //向服务器清空所有未读
    STIMMessageReadFlagGroupReaded = 2, //向服务器发送群消息已读
    STIMMessageReadFlagDidSend = 3,     //向服务器发送已送达
    STIMMessageReadFlagDidRead = 4,     //向服务器发送已阅读
    STIMMessageReadFlagDidControl = 7,  //向服务器发送已操作
} STIMMessageReadFlag;   //向服务器发送的标识符

typedef enum {
    STIMMessageSendState_Waiting    = 0x00,     //发送中
    STIMMessageSendState_Faild      = 0x01,     //发送失败
    STIMMessageSendState_Success    = 0x02,     //发送成功
} STIMMessageSendState; //消息发送状态

typedef enum {
    STIMMessageDirection_Sent = 0,   //发送的消息
    STIMMessageDirection_Received = 1,   //接收的消息
} STIMMessageDirection;  //消息接收方向

typedef enum {
    IMPlatform_UNKNOW   = 0,
    IMPlatform_Mac      = 1,
    IMPlatform_iOS      = 2,
    IMPlatform_PC       = 3,
    IMPlatform_Web      = 4,
    IMPlatform_Android  = 5,
} IMPlatform;

typedef enum : NSUInteger {
    STIMMSGSETTINGSHOW_CONTENT = 0x01,                               //通知显示消息详情
    STIMMSGSETTINGPUSH_ONLINE = STIMMSGSETTINGSHOW_CONTENT << 1,      //在线也接收通知
    STIMMSGSETTINGSOUND_INAPP = STIMMSGSETTINGPUSH_ONLINE << 1,       //通知提示音
    STIMMSGSETTINGVIBRATE_INAPP = STIMMSGSETTINGSOUND_INAPP << 1,     //通知震动提示
    STIMMSGSETTINGPUSH_SWITCH = STIMMSGSETTINGVIBRATE_INAPP << 1      //开启消息推送
} STIMMSGSETTING;  //APP消息通知设置

typedef enum : NSUInteger {
    STIMClientConfigTypeKMarkupNames = 0,        //用户备注（通用）
    STIMClientConfigTypeKCollectionCacheKey,     //收藏表情（通用）
    STIMClientConfigTypeKStickJidDic,            //置顶会话（通用）
    STIMClientConfigTypeKNotificationSetting,    //客户端通知中心设置（通用）
    STIMClientConfigTypeKConversationParamDic,   //众包需求（通用）
    STIMClientConfigTypeKQuickResponse,          //快捷回复（通用）
    STIMClientConfigTypeKChatColorInfo,          //消息气泡颜色
    STIMClientConfigTypeKCurrentFontInfo,        //客户端字体
    STIMClientConfigTypeKNoticeStickJidDic,      //会话提醒
    STIMClientConfigTypeKStarContact,            //星标联系人
    STIMClientConfigTypeKBlackList,              //黑名单
    STIMClientConfigTypeKLocalIncrementUpdateTime, //本地组织架构时间戳
    STIMClientConfigTypeKLocalMucRemarkUpdateTime, //本地群阅读指针时间戳
    STIMClientConfigTypeKLocalMucHistoryUpdateTime, //本地群历史时间戳
    STIMClientConfigTypeKLocalSingleHistoryUpdateTime, //本地单人历史时间戳
    STIMClientConfigTypeKLocalSystemHistoryUpdateTime, //本地系统历史时间戳
    STIMClientConfigTypeKLocalTripUpdateTime,     //本地行程更新时间戳
    STIMClientConfigTypeKNotificationSound,       //系统提示音
    STIMClientConfigTypeALL,                     //所有
} STIMClientConfigType;

typedef enum : NSUInteger {
    STIMAppConfigurationModeDebug = 0,
    STIMAppConfigurationModeBeta,
    STIMAppConfigurationModeRelease,
} STIMAppConfigurationMode;

typedef enum {
    QRCodeType_UserQR,
    QRCodeType_GroupQR,
    QRCodeType_RobotQR,
    QRCodeType_ClientNav,
} QRCodeType;

typedef enum : NSUInteger {
    STIMMessageErrCodeRefused = 406,
} STIMMessageErrCode;

typedef enum : NSUInteger {
    STIMCategoryNotifyMsgTypeOrganizational = 1,         //组织架构更新
    STIMCategoryNotifyMsgTypeSession = 2,                //打开新的会话
    STIMCategoryNotifyMsgTypeNavigation = 3,             //导航更新
    STIMCategoryNotifyMsgTypeOPSUnreadCount = 4,         //OPS未读数
    STIMCategoryNotifyMsgTypePersonalConfig = 6,         //个人配置更新
    STIMCategoryNotifyMsgTypeBigIM = 7,                  //大客户端
    STIMCategoryNotifyMsgTypeCalendar = 8,               //日历同步
    STIMCategoryNotifyMsgTypeOnline = 9,                 //其他客户端上线下线通知
    STIMCategoryNotifyMsgTypeAskLog = 10,                //自动收集日志
    STIMCategoryNotifyMsgTypeGlobalNotification = 98,    //全局通知
    STIMCategoryNotifyMsgTypeDesignatedNotification = 99, //指定通知
    STIMCategoryNotifyMsgTypeTickUser = 100,             //踢
    STIMCategoryNotifyMsgTypeTickUserWorkWorldNotice = 12, //驼圈
    STIMCategoryNotifyMsgTypeHotLineSync = 13,
    STIMCategoryNotifyMsgTypeMedalListUpdateNotice = 14, //勋章更新版本
    STIMCategoryNotifyMsgTypeUserMedalUpdateNotice = 15, //用户勋章更新版本
} STIMCategoryNotifyMsgType;

typedef enum : NSUInteger {
    STIMWorkFeedTypeMoment = 1,  //帖子
    STIMWorkFeedTypeComment = 2, //评论
} STIMWorkFeedType;

typedef enum : NSUInteger {
    STIMWorkMomentMediaTypeImage = 0,    //图片类型
    STIMWorkMomentMediaTypeVideo = 1,    //视频类型
} STIMWorkMomentMediaType;   //即将上传的媒体资源类型

typedef enum : NSUInteger {
    STIMWorkFeedNotifyTypePOST = 0,
    STIMWorkFeedNotifyTypeComment = 1,
    STIMWorkFeedNotifyTypeLike = 2,
    STIMWorkFeedNotifyTypePOSTAt = 3,
    STIMWorkFeedNotifyTypeCommentAt = 4,
    STIMWorkFeedNotifyTypeMyComment = 5,
} STIMWorkFeedNotifyType;

typedef enum : NSUInteger {
    STIMWorkFeedContentTypeText = 0,    //驼圈文本
    STIMWorkFeedContentTypeImage = 1,   //驼圈图片
    STIMWorkFeedContentTypeLink = 2,    //驼圈LinkUrl
    STIMWorkFeedContentTypeVideo = 3,   //驼圈视频
} STIMWorkFeedContentType;

typedef enum : NSUInteger {
    STIMSearchTypeAll,
    STIMSearchTypeWorkMoment,
} STIMSearchType;

typedef enum : NSUInteger {
    STIMGetMsgDirectionDown, //下拉，从下向上
    STIMGetMsgDirectionUp, //上翻，从上向下
} STIMGetMsgDirection;

static const NSString *STIMNavNameKey = @"title";
static const NSString *STIMNavUrlKey = @"NavUrl";

typedef void(^STIMKitGetPhoneNumberBlock)(NSString *phoneNumber);
typedef void(^STIMKitGetUserWorkInfoBlock)(NSDictionary *userWorkInfo);

typedef void(^STIMKitSendTPRequesSuccessedBlock)(NSData *responseData);
typedef void(^STIMKitSendTPRequesFailedBlock)(NSError *error);
typedef void(^STIMKitSendTPRequesProgressBlock)(float progressValue);

typedef void(^STIMKitUploadVideoRequestSuccessedBlock)(NSDictionary *videoDic);

typedef void(^STIMKitUploadVideoNewRequestSuccessedBlock)(NSDictionary *videoDic, BOOL needTrans);    //新版本上传视频callback

typedef void(^STIMKitUploadImageNewRequestProgessSuccessedBlock)(float progressValue);   //新版本上传图片进度callback

typedef void(^STIMKitUploadImageNewRequestSuccessedBlock)(NSString *imageUrl);    //新版本上传图片callback
typedef void(^STIMKitUploadFileNewRequestSuccessedBlock)(NSString *fileUrl);      //新版本上传文件callback
typedef void(^STIMKitUploadMyPhotoNewRequestSuccessedBlock)(NSString *imageUrl);      //新版本上传头像callback


typedef void(^STIMKitGetTripAreaAvailableRoomBlock)(NSArray *availableRooms);
typedef void(^STIMKitGetTripAreaAvailableRoomByCityIdBlock)(NSArray *availableRooms);    //根据城市Id获取可用区域
typedef void(^STIMKitGetTripAllCitysBlock)(NSArray *allCitys);   //获取所有城市
typedef void(^STIMKitGetTripMemberCheckBlock)(BOOL isConform);   //isConform 冲突
typedef void(^STIMKitCreateTripBlock)(BOOL success, NSString *errMsg);
typedef void(^STIMCloseSessionBlock)(NSString *closeMsg);

typedef void(^STIMKitUpdateMedalStatusCallBack)(BOOL success, NSString *errmsg);

typedef void(^STIMKitLikeMomentSuccessedBlock)(NSDictionary *responseDic);
typedef void(^STIMKitWorkCommentBlock)(NSArray *comments);
typedef void(^STIMKitWorkCommentDeleteSuccessBlock)(BOOL success, NSInteger superParentStatus);
typedef void(^STIMKitLikeContentSuccessedBlock)(NSDictionary *responseDic);
typedef void(^STIMKitGetMomentNewSuccessedBlock)(NSArray *moments);
typedef void(^STIMKitGetMomentHistorySuccessedBlock)(NSArray *moments);
typedef void(^STIMKitgetAnonymouseSuccessedBlock)(NSDictionary *anonymousDic);
typedef void(^STIMKitgetMomentDetailSuccessedBlock)(NSDictionary *momentDic);
typedef void(^STIMKitPushMomentSuccessedBlock)(BOOL successed);
typedef void(^STIMKitUpdateMomentNotifyConfigSuccessedBlock)(BOOL successed);
typedef void(^STIMKitSearchMomentBlock)(NSArray *result);

typedef void(^STIMKitgetPublicCompanySuccessedBlock)(NSArray *companies);

typedef void(^STIMKitSetMucVCardBlock)(BOOL successed);
typedef void(^STIMKitSearchRobotBlock)(NSArray *robotList);
typedef void(^STIMKitUpdateSignatureBlock)(BOOL successed);

typedef void(^STIMKitSearchSuccessBlock)(BOOL successed, NSString *responseJson);
typedef void(^STIMKitSearchFaildBlock)(BOOL successed, NSString *errmsg);

//Login
typedef void(^STIMKitGetUserTokenSuccessBlock)(NSDictionary *result);
typedef void(^STIMKitGetUserNewTokenSuccessBlock)(NSDictionary *result);
typedef void(^STIMKitGetVerifyCodeSuccessBlock)(NSDictionary *result);

#endif /* STIMCommonEnum_h */
