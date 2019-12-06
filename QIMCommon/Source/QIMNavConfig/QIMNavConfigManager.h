//
//  NavConfigManager.h
//  qunarChatIphone
//
//  Created by admin on 16/3/25.
//
//

#import <Foundation/Foundation.h>
#import "QIMCommonEnum.h"

@interface QIMNavConfigManager : NSObject
@property(nonatomic, readonly, copy) NSString *httpHost;
@property(nonatomic, readonly, copy) NSString *newerHttpUrl;
@property(nonatomic, readonly, copy) NSString *takeSmsUrl;
@property(nonatomic, readonly, copy) NSString *wikiUrl;
@property(nonatomic, readonly, copy) NSString *checkSmsUrl;
@property(nonatomic, readonly, copy) NSString *tokenSmsUrl;
@property(nonatomic, readonly, copy) NSString *javaurl;
@property(nonatomic, readonly, copy) NSString *payurl;
@property(nonatomic, readonly, copy) NSString *pubkey;
@property(nonatomic, readonly, copy) NSString *domain;
@property(nonatomic, readonly, assign) QTLoginType loginType; //登录方式
@property(nonatomic, readonly, copy) NSString *xmppHost;
@property(nonatomic, readonly, copy) NSString *innerFileHttpHost;
@property(nonatomic, readonly, copy) NSString *port;  //xmpp端口
@property(nonatomic, readonly, copy) NSString *protobufPort;   //Pb端口
@property(nonatomic, readonly, copy) NSString *checkConfig;
@property(nonatomic, readonly, copy) NSString *leaderurl;  //直属领导
@property(nonatomic, readonly, copy) NSString *mobileurl;  //手机号领导
@property(nonatomic, readonly, copy) NSString *shareUrl;   //分享聊天记录
@property(nonatomic, readonly, copy) NSString *domainHost; //种Cookie的domain
@property(nonatomic, readonly, copy) NSString *resetPwdUrl;
@property(nonatomic, readonly, copy) NSString *appWeb;
@property(nonatomic, readonly, copy) NSString *videourl;

//hosts
@property(nonatomic, readonly, copy) NSString *hashHosts;
@property(nonatomic, readonly, copy) NSString *qcHost;

@property(nonatomic, readonly, strong) NSArray *adItems;
@property(nonatomic, readonly, assign) int adSec;
@property(nonatomic, readonly, assign) BOOL adShown;
@property(nonatomic, readonly, assign) BOOL adCarousel;
@property(nonatomic, readonly, assign) int adCarouselDelay;
@property(nonatomic, readonly, assign) BOOL adAllowSkip;
@property(nonatomic, readonly, assign) long long adInterval;   //两次广告的间隔之间
@property(nonatomic, readonly, copy) NSString *adSkipTips;

//imConfig
@property(nonatomic, readonly, assign) BOOL showOA;                //展示OA
@property(nonatomic, readonly, assign) BOOL showOrganizational;    //展示组织架构
@property(nonatomic, readonly, copy) NSString *email;              //邮箱号
@property(nonatomic, readonly, copy) NSString *uploadLog;          //数据上报
@property(nonatomic, readonly, copy) NSString *foundConfigUrl;     //发现页配置url
@property(nonatomic, readonly, assign) BOOL isToC;             //判断是否toC


//ability
@property(nonatomic, readonly, copy) NSString *getPushState;
@property(nonatomic, readonly, copy) NSString *setPushState;
@property(nonatomic, readonly, copy) NSString *qCloudHost;
@property(nonatomic, readonly, copy) NSString *resetpwd;
@property(nonatomic, readonly, copy) NSString *mconfig;
@property(nonatomic, readonly, copy) NSString *searchUrl;
@property(nonatomic, readonly, copy) NSString *qSearchUrl;
@property(nonatomic, readonly, copy) NSString *qcGrabOrder;
@property(nonatomic, readonly, copy) NSString *qcOrderManager;
@property(nonatomic, readonly, assign) BOOL newPush;
@property(nonatomic, readonly, assign) BOOL showmsgstat;

//RN Ability
@property(nonatomic, assign) BOOL RNMineView;      //展示RNMineView
@property(nonatomic, assign) BOOL RNAboutView;     //展示RNAboutView
@property(nonatomic, assign) BOOL RNGroupCardView; //展示RNGroupCardView
@property(nonatomic, assign) BOOL RNContactView;   //展示RNContactView
@property(nonatomic, assign) BOOL RNSettingView;   //展示RNSettingView
@property(nonatomic, assign) BOOL RNUserCardView;  //展示RNUserCardView
@property(nonatomic, assign) BOOL RNGroupListView;   //展示RN 群组列表
@property(nonatomic, assign) BOOL RNPublicNumberListView;    //展示RN 公众号列表

//OPS
@property(nonatomic, readonly, copy) NSString *opsHost;

//Video
@property(nonatomic, readonly, copy) NSString *group_room_host;
@property(nonatomic, readonly, copy) NSString *signal_host;
@property(nonatomic, readonly, copy) NSString *wssHost;
@property(nonatomic, readonly, copy) NSString *videoApiHost;
//Versions
@property(nonatomic, readonly, assign) long long navVersion;
@property(nonatomic, readonly, assign) long long checkConfigVersion;

@property(nonatomic, copy) NSString *navUrl;

@property(nonatomic, copy) NSString *navTitle;

@property(nonatomic, readonly, assign) BOOL debug;

@property(nonatomic, readonly, copy) NSString *healthcheckUrl;

@property(nonatomic, strong) NSMutableArray *localNavConfigs;

+ (QIMNavConfigManager *)sharedInstance;

//- (NSString *)getAdvertImageFilePath;

- (NSArray *)qimNav_getDebugers;

- (NSArray *)qimNav_getLocalNavServerConfigs;

// 更新导航配置

- (void)qimNav_updateNavigationConfigWithCheck:(BOOL)check;
- (void)qimNav_updateNavigationConfigWithCheck:(BOOL)check withCallBack:(QIMKitGetNavConfigCallBack)callback;
- (void)qimNav_clearAdvertSource;

- (void)qimNav_swicthLocalNavConfigWithNavDict:(NSDictionary *)navDict;

- (NSString *)qimNav_getAdvertImageFilePath;

- (void)qimNav_updateAdvertConfigWithCheck:(BOOL)check;

- (BOOL)qimNav_updateNavigationConfigWithDomain:(NSString *)domain WithUserName:(NSString *)userName withCallBack:(QIMKitGetNavConfigCallBack)callback;

- (BOOL)qimNav_updateNavigationConfigWithNavUrl:(NSString *)navUrl WithUserName:(NSString *)userName withCallBack:(QIMKitGetNavConfigCallBack)callback;

- (void)qimNav_updateNavigationConfigWithNavDict:(NSDictionary *)navDict WithUserName:(NSString *)userName Check:(BOOL)check WithForcedUpdate:(BOOL)forcedUpdate withCallBack:(QIMKitGetNavConfigCallBack)callback;

- (void)qimNav_updateAdvertConfigWithCheck:(BOOL)check;

- (NSString *)qimNav_getRSACodePublicKeyPathWithFileName:(NSString *)fileName;

- (NSString *)getWebAppUrl;

- (NSString *)getManagerAppUrl;

- (NSString *)getNewResetPwdUrl;

- (NSString *)getPubSearchUserHostUrl;

- (NSString *)getQChatGetTKUrl;
@end
