//
//  NavConfigManager.m
//  qunarChatIphone
//
//  Created by admin on 16/3/25.
//
//

#import "QIMNavConfigManager.h"
#import "QIMPrivateHeader.h"
#import "QIMAdvertItem.h"

@interface QIMNavConfigManager ()

@property(nonatomic, strong) NSDictionary *defaultSettings;

@end

@implementation QIMNavConfigManager {
    NSDictionary *_oldAdvertDic;
    NSString *_httpHost;
    NSString *_newerHttpUrl;
    NSString *_takeSmsUrl;
    NSString *_javaurl;
    NSString *_payurl;
    NSString *_checkSmsUrl;
    NSString *_wikiUrl;
    NSString *_tokenSmsUrl;
    NSString *_pubkey;
    NSString *_domain;
    QTLoginType _loginType; //登录方式
    NSString *_xmppHost;
    NSString *_innerFileHttpHost;
    NSString *_port;  //xmpp端口
    NSString *_protobufPort;   //Pb端口
    NSString *_resetPwdUrl; //重设密码
    NSString *_hashHosts;
    NSString * _videourl;

    NSArray *_adItems;
    int _adSec;
    BOOL _adShown;
    BOOL _adCarousel;
    int _adCarouselDelay;
    BOOL _adAllowSkip;
    NSString *_adSkipTips;

    NSString *_navUrl;
    BOOL _debug;
    NSString *_healthcheckUrl;

    //Video
    NSString *_videoApiHost;
    NSString *_wssHost;
    NSString *_signal_host;
    NSString *_group_room_host;

    //OPS
    NSString *_opsHost;

    NSString *_qcHost;
}

+ (QIMNavConfigManager *)sharedInstance {
    static QIMNavConfigManager *__monitor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __monitor = [[QIMNavConfigManager alloc] init];
    });
    return __monitor;
}

- (instancetype)init {
    self = [super init];
    QIMVerboseLog(@" QIMNavConfigManager sharedInstance");
    if (self) {

        if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQTalk) {
            NSString *qtalkSettingsPath = [[NSBundle mainBundle] pathForResource:@"qtalkDefaultSetting" ofType:@"json"];
            NSString *str = [[NSString alloc] initWithContentsOfFile:qtalkSettingsPath];
            NSData *encodeBase64Data = [NSData qim_dataWithBase64EncodedString:str];
            self.defaultSettings = [[QIMJSONSerializer sharedInstance] deserializeObject:encodeBase64Data error:nil];
        } else if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
            NSString *qchatSettings = [[NSBundle mainBundle] pathForResource:@"qchatDefaultSetting" ofType:@"json"];
            NSString *str = [[NSString alloc] initWithContentsOfFile:qchatSettings];
            NSData *encodeBase64Data = [NSData qim_dataWithBase64EncodedString:str];
            self.defaultSettings = [[QIMJSONSerializer sharedInstance] deserializeObject:encodeBase64Data error:nil];
        } else {
            self.defaultSettings = nil;
        }
        CFAbsoluteTime startTime1 = [[QIMWatchDog sharedInstance] startTime];
        NSString *navConfigStr = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"NavConfig"];
        NSMutableDictionary *navConfig = [[QIMJSONSerializer sharedInstance] deserializeObject:navConfigStr error:nil];
        QIMVerboseLog(@"本地找到的NavConfig ： %@", navConfig);
        NSMutableDictionary *oldNavConfigUrlDict = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"QC_CurrentNavDict"];
        QIMVerboseLog(@"本地找到的oldNavConfigUrlDict : %@", oldNavConfigUrlDict);
        if (navConfig.count > 0) {
            [self setNavConfig:navConfig];
        } else {
            NSMutableDictionary *oldNavConfigUrlDict = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"QC_CurrentNavDict"];
            QIMVerboseLog(@"本地找到的oldNavConfigUrlDict : %@", oldNavConfigUrlDict);
            NSString *navUrl = [oldNavConfigUrlDict objectForKey:@"NavUrl"];
            if (navUrl.length > 0) {
                [self qimNav_updateNavigationConfigWithNavDict:oldNavConfigUrlDict WithUserName:nil Check:YES WithForcedUpdate:YES withCallBack:nil];
            }
        }

        NSDictionary *advertConfig = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"AdvertConfig"];
        NSArray *adList = [advertConfig objectForKey:@"adlist"];
        if (adList.count > 0) {
            NSMutableArray *itemArray = [NSMutableArray array];
            for (NSDictionary *adDic in adList) {
                QIMAdvertItem *advertItem = [[QIMAdvertItem alloc] init];
                [advertItem setAdType:[[adDic objectForKey:@"adtype"] intValue]];
                [advertItem setAdImgUrl:[adDic objectForKey:@"imgurl"]];
                [advertItem setAdLinkUrl:[adDic objectForKey:@"linkurl"]];
                if (advertItem.adType == AdvertType_Image) {
                    NSString *filePath = [[QIMDataController getInstance] getSourcePath:advertItem.adImgUrl];
                    if (filePath == nil) {
                        continue;
                    }
                }
                [itemArray addObject:advertItem];
            }
            _adItems = itemArray;
            _adSec = [[advertConfig objectForKey:@"adsec"] intValue];
            _adShown = [[advertConfig objectForKey:@"shown"] boolValue];
            _adAllowSkip = [[advertConfig objectForKey:@"allowskip"] boolValue];
            _adCarousel = [[advertConfig objectForKey:@"carousel"] boolValue];
            _adSkipTips = [advertConfig objectForKey:@"skiptips"];
            _adCarouselDelay = [[advertConfig objectForKey:@"carouseldelay"] intValue];
        }
        [self initialNavConfig];
        QIMVerboseLog(@"[QIMNavConfigManager sharedInstance]耗时 : %llf", [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime1]);
    }
    return self;
}

- (void)initialNavConfig {
    if (_xmppHost == nil) {
        if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
            _xmppHost = [self.defaultSettings objectForKey:@"xmppHost"];
            _httpHost = [self.defaultSettings objectForKey:@"httpHost"];
            _newerHttpUrl = [self.defaultSettings objectForKey:@"newerHttpUrl"];
            _javaurl = [self.defaultSettings objectForKey:@"javaurl"];
            _payurl = [self.defaultSettings objectForKey:@"payurl"];
            _domain = [self.defaultSettings objectForKey:@"domain"];
            _innerFileHttpHost = [self.defaultSettings objectForKey:@"innerFileHttpHost"];
            _pubkey = [self.defaultSettings objectForKey:@"pubkey"];
            _takeSmsUrl = nil;
            _checkSmsUrl = nil;
            _port = [self.defaultSettings objectForKey:@"port"];
            _protobufPort = [self.defaultSettings objectForKey:@"protobufPort"];
            _adShown = NO;
            _qcHost = [self.defaultSettings objectForKey:@"qcHost"];
            _domainHost = [self.defaultSettings objectForKey:@"domainHost"];
            _searchUrl = [self.defaultSettings objectForKey:@"searchurl"];
            _shareUrl = [self.defaultSettings objectForKey:@"shareUrl"];
            _uploadLog = [self.defaultSettings objectForKey:@"uploadLog"];
            _resetPwdUrl = [self.defaultSettings objectForKey:@"resetPwdUrl"];
            _isToC = [[self.defaultSettings objectForKey:@"isToC"] boolValue];
            _videourl = [self.defaultSettings objectForKey:@"videourl"];
        } else if ([[QIMAppInfo sharedInstance] appType] != QIMProjectTypeQChat) {
            _xmppHost = [self.defaultSettings objectForKey:@"xmppHost"];
            _httpHost = [self.defaultSettings objectForKey:@"httpHost"];
            _javaurl = [self.defaultSettings objectForKey:@"javaurl"];
            _payurl = [self.defaultSettings objectForKey:@"payurl"];
            _newerHttpUrl = [self.defaultSettings objectForKey:@"newerHttpUrl"];
            _domain = [self.defaultSettings objectForKey:@"domain"];
            _innerFileHttpHost = [self.defaultSettings objectForKey:@"innerFileHttpHost"];
            _pubkey = [self.defaultSettings objectForKey:@"pubkey"];
            _takeSmsUrl = [self.defaultSettings objectForKey:@"takeSmsUrl"];
            _checkSmsUrl = [self.defaultSettings objectForKey:@"checkSmsUrl"];
            _tokenSmsUrl = [self.defaultSettings objectForKey:@"tokenSmsUrl"];
            _getPushState = [self.defaultSettings objectForKey:@"getPushState"];
            _setPushState = [self.defaultSettings objectForKey:@"setPushState"];
            _port = [self.defaultSettings objectForKey:@"port"];
            _protobufPort = [self.defaultSettings objectForKey:@"protobufPort"];
            _adShown = [[self.defaultSettings objectForKey:@"adShown"] boolValue];
            _healthcheckUrl = [self.defaultSettings objectForKey:@"healthcheckUrl"];
            _domainHost = [self.defaultSettings objectForKey:@"domainHost"];
            _shareUrl = [self.defaultSettings objectForKey:@"shareUrl"];
            _email = [self.defaultSettings objectForKey:@"email"];
            _uploadLog = [self.defaultSettings objectForKey:@"uploadLog"];
            _resetPwdUrl = [self.defaultSettings objectForKey:@"resetPwdUrl"];
            _qSearchUrl = [self.defaultSettings objectForKey:@"qSearchUrl"];
            _isToC = [[self.defaultSettings objectForKey:@"isToC"] boolValue];
            _videourl = [self.defaultSettings objectForKey:@"videourl"];
        }
    }

    if (_takeSmsUrl == nil || [_takeSmsUrl length] <= 0) {
        _takeSmsUrl = [self.defaultSettings objectForKey:@"takeSmsUrl"];
    }
    if (_checkSmsUrl == nil || [_checkSmsUrl length] <= 0) {
        _checkSmsUrl = [self.defaultSettings objectForKey:@"checkSmsUrl"];
    }
    if (_tokenSmsUrl == nil || [_tokenSmsUrl length] <= 0) {
        _tokenSmsUrl = [self.defaultSettings objectForKey:@"tokenSmsUrl"];
    }

    [[QIMManager sharedInstance] setImLoginType:_loginType];
    [[QIMManager sharedInstance] setImLoginDomain:_domain];
    [[QIMManager sharedInstance] setImLoginXmppHost:_xmppHost];
    [[QIMManager sharedInstance] setImLoginProtobufPort:_protobufPort];
    [[QIMManager sharedInstance] setImLoginPort:_port];
    [[QIMManager sharedInstance] updateNavigationConfig];
}

- (BOOL)debug {
    // TODO: 这里也要改
    NSNumber *debugNum = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"QC_Debug"];
    if (debugNum == nil) {
        debugNum = @(NO);
        [[QIMUserCacheManager sharedInstance] setUserObject:debugNum forKey:@"QC_Debug"];
    }
    return [debugNum boolValue];
}

- (NSArray *)qimNav_getDebugers {
    return @[@"lilulucas.li", @"nigotuu7479", @"hubin.hu", @"lee.guo", @"kaiming.zhang", @"lihaibin.li", @"yuelin.liu", @"xi.guo"];
}

- (NSArray *)qimNav_getLocalNavServerConfigs {
    return self.localNavConfigs;
}

- (NSString *)navUrl {
    NSString *appNavUrl = @"";
    NSDictionary *navUrlDict = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"QC_CurrentNavDict"];
    if (navUrlDict) {
        appNavUrl = navUrlDict[QIMNavUrlKey];
    } else {
        if ([[QIMAppInfo sharedInstance] appType] != QIMProjectTypeQChat) {
            appNavUrl = @"https://qim.qunar.com/package/static/qtalk/nav";
        } else {
            appNavUrl = @"https://qim.qunar.com/package/static/qchat/nav";
        }
    }
    return appNavUrl;
}

- (NSString *)navTitle {
    NSString *appNavTitle = @"";
    NSDictionary *navUrlDict = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"QC_CurrentNavDict"];
    if (navUrlDict) {
        appNavTitle = navUrlDict[QIMNavNameKey];
    } else {
        appNavTitle = [NSString stringWithFormat:@"%@导航", [[QIMAppInfo sharedInstance] appName]];
    }
    return appNavTitle;
}

#pragma mark - getter

// OPS
- (NSString *)opsHost {
    if (!_opsHost) {
        _opsHost = [self.defaultSettings objectForKey:@"opsHost"];
    }
    return _opsHost;
}

//Video
- (NSString *)signal_host {
    if (!_signal_host) {
        _signal_host = [self.defaultSettings objectForKey:@"signal_host"];
    }
    return _signal_host;
}

- (NSString *)group_room_host {
    if (!_group_room_host) {
        _group_room_host = [self.defaultSettings objectForKey:@"group_room_host"];
    }
    return _group_room_host;
}

- (NSString *)videoApiHost {
    if (!_videoApiHost) {
        _videoApiHost = [self.defaultSettings objectForKey:@"videoApiHost"];
    }
    return _videoApiHost;
}

- (NSString *)wssHost {
    if (!_wssHost) {
        _wssHost = [self.defaultSettings objectForKey:@"wssHost"];
    }
    return _wssHost;
}

- (NSString *)javaurl {
    if (!_javaurl) {
        _javaurl = [self.defaultSettings objectForKey:@"javaurl"];
    }
    return _javaurl;
}

- (NSString *)payurl {
    if (!_payurl) {
        _payurl = [self.defaultSettings objectForKey:@"payurl"];
    }
    return _payurl;
}

- (NSString *)qcHost {
    if (!_qcHost) {
        _qcHost = [self.defaultSettings objectForKey:@"qcHost"];
    }
    return _qcHost;
}

- (NSString *)healthcheckUrl {
    if (!_healthcheckUrl.length) {
        _healthcheckUrl = [self.defaultSettings objectForKey:@"healthcheckUrl"];
    }
    return _healthcheckUrl;
}

- (NSMutableArray *)localNavConfigs {
    if (!_localNavConfigs) {
        NSMutableArray *clientNavServerConfigs = [NSMutableArray arrayWithArray:[[QIMUserCacheManager sharedInstance] userObjectForKey:@"QC_NavAllDicts"]];
        if (!clientNavServerConfigs.count) {

            clientNavServerConfigs = [NSMutableArray arrayWithCapacity:5];
            NSString *tempNavName = [NSString stringWithFormat:@"%@导航", [[QIMAppInfo sharedInstance] appName]];
            NSDictionary *qtalkNav = @{QIMNavNameKey: tempNavName, QIMNavUrlKey: @"https://qim.qunar.com/package/static/qtalk/nav"};
            NSDictionary *publicQTalkNav = @{QIMNavNameKey: @"Qunar公共域导航", QIMNavUrlKey: @"https://qim.qunar.com/package/static/qtalk/publicnav?c=qunar.com"};
            NSDictionary *qchatNav = @{QIMNavNameKey: @"QChat导航", QIMNavUrlKey: @"https://qim.qunar.com/package/static/qchat/nav"};
            if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQTalk) {
                [clientNavServerConfigs addObject:qtalkNav];
                [clientNavServerConfigs addObject:publicQTalkNav];
            } else if ([[QIMAppInfo sharedInstance] appType] == QIMProjectTypeQChat) {
                [clientNavServerConfigs addObject:qchatNav];
            } else {

            }
        }
        _localNavConfigs = [NSMutableArray arrayWithArray:clientNavServerConfigs];
    }
    return _localNavConfigs;
}

- (void)addLocalNavDict:(NSDictionary *)navDict {
    NSArray *tempLocalNavConfigs = self.localNavConfigs;
    BOOL isExist = NO;
    for (NSDictionary *dict in tempLocalNavConfigs) {
        NSString *navUrl = [dict objectForKey:QIMNavUrlKey];
        NSString *newNavUrl = [navDict objectForKey:QIMNavUrlKey];
        if ([newNavUrl isEqualToString:navUrl]) {
            isExist = YES;
        }
    }
    if (isExist == NO && navDict) {
        [self.localNavConfigs addObject:navDict];
    }
}

- (void)setRNMineView:(BOOL)RNMineView {
    _RNMineView = RNMineView;
}

- (void)setRNAboutView:(BOOL)RNAboutView {
    _RNAboutView = RNAboutView;
}

- (void)setRNGroupCardView:(BOOL)RNGroupCardView {
    _RNGroupCardView = RNGroupCardView;
}

- (void)setRNContactView:(BOOL)RNContactView {
    _RNContactView = RNContactView;
}

- (void)setRNSettingView:(BOOL)RNSettingView {
    _RNSettingView = RNSettingView;
}

- (void)setRNUserCardView:(BOOL)RNUserCardView {
    _RNUserCardView = RNUserCardView;
}

- (void)setRNGroupListView:(BOOL)RNGroupListView {
    _RNGroupListView = RNGroupListView;
}

- (void)setRNPublicNumberListView:(BOOL)RNPublicNumberListView {
    _RNPublicNumberListView = RNPublicNumberListView;
}

- (void)setNavConfig:(NSDictionary *)navConfig {

    NSString *hashHosts = [navConfig objectForKey:@"hosts"];
    if (hashHosts.length > 0) {
        _hashHosts = hashHosts;
    }
    NSDictionary *loginDict = [navConfig objectForKey:@"Login"];
    NSString *loginType = [loginDict objectForKey:@"loginType"];
    if ([loginType isEqualToString:@"password"]) {
        _loginType = QTLoginTypePwd;
    } else if ([loginType isEqualToString:@"newpassword"]) {
        _loginType = QTLoginTypeNewPwd;
    } else {
        _loginType = QTLoginTypeSms;
    }
//    BOOL pwdLogin = [loginType isEqualToString:@"password"];
//    _loginType = pwdLogin ? QTLoginTypePwd : QTLoginTypeSms;
    [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:@"QC_UserWillSaveNavDict"];
    NSDictionary *abilityDict = [navConfig objectForKey:@"ability"];
    if (abilityDict.count) {
        _getPushState = [abilityDict objectForKey:@"getPushState"];
        _setPushState = [abilityDict objectForKey:@"setPushState"];
        _qCloudHost = [abilityDict objectForKey:@"qCloudHost"];
        _resetpwd = [abilityDict objectForKey:@"resetpwd"];
        _mconfig = [abilityDict objectForKey:@"mconfig"];
        _searchUrl = [abilityDict objectForKey:@"searchurl"];
        _qSearchUrl = [abilityDict objectForKey:@"new_searchurl"];
        _qcGrabOrder = [abilityDict objectForKey:@"qcGrabOrder"];
        _qcOrderManager = [abilityDict objectForKey:@"qcOrderManager"];
        _newPush = [[abilityDict objectForKey:@"newPush"] boolValue];
        _showmsgstat = [[abilityDict objectForKey:@"showmsgstat"] boolValue];
    } else {
        _getPushState = nil;
        _setPushState = nil;
        _qCloudHost = nil;
        _resetpwd = nil;
        _mconfig = nil;
        _searchUrl = nil;
        _qSearchUrl = nil;
        _qcGrabOrder = nil;
        _qcOrderManager = nil;
        _newPush = NO;
        _showmsgstat = NO;
    }
    _navVersion = [[navConfig objectForKey:@"version"] longLongValue];
    NSDictionary *Versions = [navConfig objectForKey:@"versions"];
    if (Versions.count) {
        _checkConfigVersion = [[Versions objectForKey:@"checkconfig"] longLongValue];
    } else {
        _checkConfigVersion = 0;
    }

    NSDictionary *imConfigDic = [navConfig objectForKey:@"imConfig"];
    if (imConfigDic.count) {
        NSString *showOA = [imConfigDic objectForKey:@"showOA"];
        NSString *showOrganizational = [imConfigDic objectForKey:@"showOrganizational"];
        if ([showOA boolValue]) {
            _showOA = YES;
        } else {
            _showOA = NO;
        }

        if ([showOrganizational boolValue]) {
            _showOrganizational = YES;
        } else {
            _showOrganizational = NO;
        }
        _email = [imConfigDic objectForKey:@"mail"];
        _uploadLog = [imConfigDic objectForKey:@"uploadLog"];
        _foundConfigUrl = [imConfigDic objectForKey:@"foundConfigUrl"];
        _isToC = [[imConfigDic objectForKey:@"isToC"] boolValue];
    } else {
        _showOA = NO;
        _showOrganizational = NO;
    }
    QIMVerboseLog(@"updateNavigationConfigWithNavDict SHOWOA : %d", _showOA);
    QIMVerboseLog(@"showOrganizational : %d", _showOrganizational);

    //Video
    NSDictionary *videoConfigDic = [navConfig objectForKey:@"video"];
    if (videoConfigDic.count) {
        _group_room_host = [videoConfigDic objectForKey:@"group_room_host"];
        _signal_host = [videoConfigDic objectForKey:@"signal_host"];
        _wssHost = [videoConfigDic objectForKey:@"wsshost"];
        _videoApiHost = [videoConfigDic objectForKey:@"apihost"];
    }

    //OPS
    NSDictionary *opsDict = [navConfig objectForKey:@"ops"];
    if (opsDict.count) {
        _opsHost = [opsDict objectForKey:@"host"];
    }

    NSDictionary *RNAbilityDict = [navConfig objectForKey:@"RNAbility"];
    if (RNAbilityDict.count) {
        NSString *RNContactView = [RNAbilityDict objectForKey:@"RNContactView"];
        if ([RNContactView boolValue]) {
            _RNContactView = YES;
        } else {
            _RNContactView = NO;
        }
        NSString *RNMineView = [RNAbilityDict objectForKey:@"RNMineView"];
        if ([RNMineView boolValue]) {
            _RNMineView = YES;
        } else {
            _RNMineView = NO;
        }
        NSString *RNSettingView = [RNAbilityDict objectForKey:@"RNSettingView"];
        if ([RNSettingView boolValue]) {
            _RNSettingView = YES;
        } else {
            _RNSettingView = NO;
        }
        NSString *RNAboutView = [RNAbilityDict objectForKey:@"RNAboutView"];
        if ([RNAboutView boolValue]) {
            _RNAboutView = YES;
        } else {
            _RNAboutView = NO;
        }
        NSString *RNGroupCardView = [RNAbilityDict objectForKey:@"RNGroupCardView"];
        if ([RNGroupCardView boolValue]) {
            _RNGroupCardView = YES;
        } else {
            _RNGroupCardView = NO;
        }

        NSString *RNGroupListView = [RNAbilityDict objectForKey:@"RNGroupListView"];
        if ([RNGroupListView boolValue]) {
            _RNGroupListView = YES;
        } else {
            _RNGroupListView = NO;
        }

        NSString *RNPublicNumberListView = [RNAbilityDict objectForKey:@"RNPublicNumberListView"];
        if ([RNPublicNumberListView boolValue]) {
            _RNPublicNumberListView = YES;
        } else {
            _RNPublicNumberListView = NO;
        }

        NSString *RNUserCardView = [RNAbilityDict objectForKey:@"RNUserCardView"];
        if ([RNUserCardView boolValue]) {
            _RNUserCardView = YES;
        } else {
            _RNUserCardView = NO;
        }
    } else {
        _RNContactView = YES;
        _RNMineView = YES;
        _RNSettingView = YES;
        _RNAboutView = NO;
        _RNGroupCardView = YES;
        _RNGroupListView = YES;
        _RNPublicNumberListView = YES;
        _RNUserCardView = YES;
    }
    _RNContactView = YES;
    _RNMineView = YES;
    _RNSettingView = YES;
    _RNAboutView = NO;
    _RNGroupCardView = YES;
    _RNGroupListView = YES;
    _RNPublicNumberListView = YES;
    _RNUserCardView = YES;
    NSDictionary *baseAddess = [navConfig objectForKey:@"baseaddess"];
    if (baseAddess.count) {
        _xmppHost = [baseAddess objectForKey:@"xmpp"];
        _domain = [baseAddess objectForKey:@"domain"];
        _httpHost = [baseAddess objectForKey:@"apiurl"];
        _newerHttpUrl = [baseAddess objectForKey:@"httpurl"];
        _wikiUrl = [baseAddess objectForKey:@"wikiurl"];
        _javaurl = [baseAddess objectForKey:@"javaurl"];
        _payurl = [baseAddess objectForKey:@"payurl"];
        _innerFileHttpHost = [baseAddess objectForKey:@"fileurl"];
        _port = [baseAddess objectForKey:@"xmppmport"];
        _protobufPort = [baseAddess objectForKey:@"protobufPort"];
        _pubkey = [baseAddess objectForKey:@"pubkey"];
        _tokenSmsUrl = [baseAddess objectForKey:@"sms_token"];
        _checkSmsUrl = [baseAddess objectForKey:@"sms_verify"];
        _takeSmsUrl = [baseAddess objectForKey:@"sms_verify"];
        _checkConfig = [baseAddess objectForKey:@"checkconfig"];
        _leaderurl = [baseAddess objectForKey:@"leaderurl"];
        _mobileurl = [baseAddess objectForKey:@"mobileurl"];
        _shareUrl = [baseAddess objectForKey:@"shareurl"];
        _resetPwdUrl = [baseAddess objectForKey:@"resetPwdUrl"];
        _appWeb = [baseAddess objectForKey:@"appWeb"];
        _videourl = [baseAddess objectForKey:@"videourl"];
        NSString *domainHost = [baseAddess objectForKey:@"domainhost"];
        if (domainHost.length > 0) {
            _domainHost = domainHost;
        }
    }
    NSDictionary *qcadminDic = [navConfig objectForKey:@"qcadmin"];
    if (qcadminDic.count) {
        _qcHost = [qcadminDic objectForKey:@"host"];
    }

    NSString *navConfigStr = [[QIMJSONSerializer sharedInstance] serializeObject:navConfig];
    [[QIMUserCacheManager sharedInstance] setUserObject:navConfigStr forKey:@"NavConfig"];
    [[QIMManager sharedInstance] setImLoginType:_loginType];
    [[QIMManager sharedInstance] setImLoginDomain:_domain];
    [[QIMManager sharedInstance] setImLoginXmppHost:_xmppHost];
    [[QIMManager sharedInstance] setImLoginProtobufPort:_protobufPort];
    [[QIMManager sharedInstance] setImLoginPort:_port];
    [[QIMManager sharedInstance] updateNavigationConfig];
}

//更新Hash策略后的导航配置
- (void)qimNav_updateNavigationConfigWithHashHost:(NSString *)hashHost {
    NSString *userName = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"currentLoginName"];
    if (![hashHost containsString:@"u="] && userName) {
        hashHost = [_hashHosts stringByAppendingFormat:@"&u=%@", [QIMManager getLastUserName]];
    }

    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:hashHost]];
    [request setTimeoutInterval:3.0f];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSDictionary *hashNavConfig = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
            NSDictionary *baseAddess = [hashNavConfig objectForKey:@"baseaddess"];
            if (baseAddess.count) {
                _xmppHost = [baseAddess objectForKey:@"xmpp"];
                _domain = [baseAddess objectForKey:@"domain"];
                _httpHost = [baseAddess objectForKey:@"apiurl"];
                _javaurl = [baseAddess objectForKey:@"javaurl"];
                _payurl = [baseAddess objectForKey:@"payurl"];
                _innerFileHttpHost = [baseAddess objectForKey:@"fileurl"];
                _port = [baseAddess objectForKey:@"xmppmport"];
                _protobufPort = [baseAddess objectForKey:@"protobufPort"];
                _pubkey = [baseAddess objectForKey:@"pubkey"];
                _tokenSmsUrl = [baseAddess objectForKey:@"sms_token"];
                _checkSmsUrl = [baseAddess objectForKey:@"sms_verify"];
                _takeSmsUrl = [baseAddess objectForKey:@"sms_verify"];
                _resetPwdUrl = [baseAddess objectForKey:@"resetPwdUrl"];
                _appWeb = [baseAddess objectForKey:@"appWeb"];
                _videourl = [baseAddess objectForKey:@"videourl"];
            }
        }
    }                  failure:^(NSError *error) {

    }];
}

//更新导航所有配置
- (void)qimNav_updateNavigationConfigWithNavDict:(NSDictionary *)navDict NavStr:(NSString *)navConfigUrl Check:(BOOL)check withCallBack:(QIMKitGetNavConfigCallBack)callBack {
    NSString *userName = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"currentLoginName"];
    if (![navConfigUrl containsString:@"u="] && userName) {
        navConfigUrl = [navConfigUrl stringByAppendingFormat:@"&u=%@", [QIMManager getLastUserName]];
    }
    [[QIMManager sharedInstance] sendTPGetRequestWithUrl:navConfigUrl withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *navConfig = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if (navConfig.count > 0) {
            [self setNavConfig:navConfig];
            QIMVerboseLog(@"QC_CurrentNavDictDict : %@ QC_NavConfigs : %@", navConfigUrl, navConfig);
            NSRange range = [navConfigUrl rangeOfString:@"qim.qunar.com/s/qtalk"];
            if (!navConfigUrl || (range.location != NSNotFound && range.length > 0)) {
                [[QIMUserCacheManager sharedInstance] setUserObject:@(YES) forKey:@"isQunarQTalk"];
            }
            [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:@"QCNavFailed"];
            NSString *navConfigStr = [[QIMJSONSerializer sharedInstance] serializeObject:navConfig];
            [[QIMUserCacheManager sharedInstance] setUserObject:navConfigStr forKey:@"NavConfig"];
            [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:@"currentLoginUserName"];
            if (callBack) {
                callBack(YES);
            }
        } else {
            [[QIMUserCacheManager sharedInstance] setUserObject:@(NO) forKey:@"QCNavFailed"];
            [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:@"currentLoginUserName"];
            if (callBack) {
                callBack(NO);
            }
        }
    } withFailedCallBack:^(NSError *error) {
        if (callBack) {
            callBack(NO);
        }
    }];
}

- (void)qimNav_updateNavigationConfigWithDomain:(NSString *)domain WithUserName:(NSString *)userName withCallBack:(QIMKitGetNavConfigCallBack)callback {
    if (domain) {
        NSDictionary *currentNav = @{QIMNavNameKey: domain, QIMNavUrlKey: domain};
        [[QIMUserCacheManager sharedInstance] setUserObject:currentNav forKey:@"QC_CurrentNavDict"];
        [self qimNav_updateNavigationConfigWithNavDict:currentNav WithUserName:userName Check:YES WithForcedUpdate:YES withCallBack:^(BOOL success) {
            if (callback) {
                callback(success);
            }
        }];
    } else {
        if (callback) {
            callback(NO);
        }
    }
}

- (void)qimNav_updateNavigationConfigWithNavUrl:(NSString *)navUrl WithUserName:(NSString *)userName withCallBack:(QIMKitGetNavConfigCallBack)callback {
    if (navUrl.length > 0) {
        NSDictionary *currentNav = @{QIMNavNameKey: navUrl, QIMNavUrlKey: navUrl};
        [self qimNav_updateNavigationConfigWithNavDict:currentNav WithUserName:userName Check:YES WithForcedUpdate:YES withCallBack:^(BOOL success) {
            if (callback) {
                callback(success);
            }
        }];
    } else {
        if (callback) {
            callback(NO);
        }
    }
}

- (void)qimNav_updateNavigationConfigWithNavDict:(NSDictionary *)navDict WithUserName:(NSString *)userName Check:(BOOL)check WithForcedUpdate:(BOOL)forcedUpdate withCallBack:(QIMKitGetNavConfigCallBack)callback {
    NSString *customNavUrl = [navDict objectForKey:QIMNavUrlKey];
    NSString *realNavUrl = nil;
    if (customNavUrl.length > 0) {
        realNavUrl = customNavUrl;
    } else {
        realNavUrl = [self navUrl];
    }
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [[infoDictionary objectForKey:@"CFBundleVersion"] description];
    long long navConfigUpdateTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"NavConfigUpdateTime"] longLongValue];
    long long currentTime = [[NSDate date] timeIntervalSince1970];
    BOOL qcNavFailed = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"QCNavFailed"] boolValue];
    if (check || currentTime - navConfigUpdateTime > 2 * 60 * 60 || [self debug] == 1 || forcedUpdate == YES || qcNavFailed == YES) {
        realNavUrl = [[realNavUrl stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        if (![realNavUrl containsString:@"https://"]) {
            if (![realNavUrl containsString:@"http://"]) {
                realNavUrl = [NSString stringWithFormat:@"https://qim.qunar.com/package/static/qtalk/publicnav?c=%@", realNavUrl];
            }
        }
        NSString *navConfigUrl = realNavUrl;
        if ([realNavUrl containsString:@"?"]) {
            if ([navConfigUrl containsString:@"debug"]) {
                navConfigUrl = [realNavUrl stringByAppendingFormat:@"&v=%@&p=%@", appVersion, @"iphone"];
            } else {
                navConfigUrl = [realNavUrl stringByAppendingFormat:@"&v=%@&p=%@&debug=%@", appVersion, @"iphone", [self debug] == 1 ? @"true" : @"false"];
            }
        } else {
            if ([navConfigUrl containsString:@"debug"]) {
                navConfigUrl = [realNavUrl stringByAppendingFormat:@"?v=%@&p=%@", appVersion, @"iphone"];
            } else {
                navConfigUrl = [realNavUrl stringByAppendingFormat:@"?v=%@&p=%@&debug=%@", appVersion, @"iphone", [self debug] == 1 ? @"true" : @"false"];
            }
        }
        if (![navConfigUrl containsString:@"u="] && userName.length > 0) {
            navConfigUrl = [navConfigUrl stringByAppendingFormat:@"&u=%@", userName];
        }
        if (![navConfigUrl containsString:@"nauth="]) {
            navConfigUrl = [navConfigUrl stringByAppendingFormat:@"&nauth=true"];
        }
        __block BOOL resultSuccess = NO;
        [self qimNav_updateNavigationConfigWithNavDict:navDict NavStr:navConfigUrl Check:check withCallBack:^(BOOL res) {
            resultSuccess = res;
            if (resultSuccess) {
                [self addLocalNavDict:navDict];
                [[QIMUserCacheManager sharedInstance] setUserObject:_localNavConfigs forKey:@"QC_NavAllDicts"];
                NSString *lastComponent = [[[navConfigUrl lastPathComponent] componentsSeparatedByString:@"?"] lastObject];
                if (_hashHosts.length > 0) {
                    if (![_hashHosts containsString:@"?"]) {
                        _hashHosts = [_hashHosts stringByAppendingFormat:@"?%@", lastComponent];
                    }
                    if (![_hashHosts containsString:@"u="] && userName) {
                        _hashHosts = [_hashHosts stringByAppendingFormat:@"&u=%@", userName];
                    }
                    [self qimNav_updateNavigationConfigWithHashHost:_hashHosts];
                }
                [self qimNav_updateAdvertConfigWithCheck:YES];
                [self qimNav_getRSACodePublicKeyFromRemote];
            }
            [[QIMUserCacheManager sharedInstance] setUserObject:@(currentTime) forKey:@"NavConfigUpdateTime"];
            [[QIMUserCacheManager sharedInstance] setUserObject:@(_loginType) forKey:@"LoginType"];
            if (navDict.count > 0) {
                [[QIMUserCacheManager sharedInstance] setUserObject:navDict forKey:@"QC_CurrentNavDict"];
            } else {
                NSDictionary *emptyNavDict = @{QIMNavNameKey: [self navTitle], QIMNavUrlKey: [self navUrl]};
                [[QIMUserCacheManager sharedInstance] setUserObject:emptyNavDict forKey:@"QC_CurrentNavDict"];
            }
            //[[QIMManager sharedInstance] updateNavigationConfig];
            [[QIMUserCacheManager sharedInstance] removeUserObjectForKey:@"currentLoginUserName"];
            if (callback) {
                callback(resultSuccess);
            }
        }];
        QIMVerboseLog(@"请求导航服务器 : %@", navConfigUrl);
    } else {
        if (callback) {
            callback(NO);
        }
    }
//    return NO;
}


// 更新导航配置
- (void)qimNav_updateNavigationConfigWithCheck:(BOOL)check {
    [self qimNav_updateNavigationConfigWithCheck:check withCallBack:nil];
}

- (void)qimNav_updateNavigationConfigWithCheck:(BOOL)check withCallBack:(QIMKitGetNavConfigCallBack)callback {
    QIMVerboseLog(@"更新导航配置 %s", __func__);
    NSDictionary *currentLoginNav = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"QC_UserWillSaveNavDict"];
    NSString *userName = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"currentLoginUserName"];
    if (currentLoginNav.count) {
        [self qimNav_updateNavigationConfigWithNavDict:currentLoginNav WithUserName:userName Check:check WithForcedUpdate:NO withCallBack:^(BOOL success) {
            if (callback) {
                callback(success);
            }
        }];
    } else {
        [self qimNav_updateNavigationConfigWithNavDict:[[QIMUserCacheManager sharedInstance] userObjectForKey:@"QC_CurrentNavDict"] WithUserName:userName Check:check WithForcedUpdate:NO withCallBack:^(BOOL success) {
            if (callback) {
                callback(success);
            }
        }];
    }
}

- (void)qimNav_swicthLocalNavConfigWithNavDict:(NSDictionary *)navDict {
    QIMVerboseLog(@"切换账号 : %@", navDict);
    _loginType = QTLoginTypeNone;
    _xmppHost = nil;
//    [self resetIvarList];
    [self initialNavConfig];
    NSDictionary *navConfig = [navDict objectForKey:@"NavConfig"];
    id willNavDict = [navDict objectForKey:@"NavUrl"];
    QIMVerboseLog(@"willNavDict : %@", willNavDict);
    NSString *userName = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"currentLoginName"];
    if ([willNavDict isKindOfClass:[NSDictionary class]]) {
        QIMVerboseLog(@"willNavDict is NSDictionary");
        if (willNavDict) {
            [self qimNav_updateNavigationConfigWithNavDict:willNavDict WithUserName:userName Check:YES WithForcedUpdate:YES withCallBack:nil];
        }
    } else if ([willNavDict isKindOfClass:[NSString class]]) {
        QIMVerboseLog(@"willNavDict is NSString");
        NSString *navTitle = [navDict objectForKey:@"title"];
        if (navTitle.length > 0) {
            [self qimNav_updateNavigationConfigWithNavDict:navDict WithUserName:userName Check:YES WithForcedUpdate:YES withCallBack:nil];
        } else {
            [self qimNav_updateNavigationConfigWithNavDict:nil NavStr:willNavDict Check:YES withCallBack:nil];
        }
    } else {
        [self setNavConfig:navConfig];
    }
    [[QIMManager sharedInstance] clearQIMManager];
}

- (NSString *)qimNav_getAdvertImageFilePath {
    NSString *advertCache = [UserCachesPath stringByAppendingPathComponent:@"AdvertCache/"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:advertCache] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:advertCache withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return advertCache;
}

- (void)qimNav_updateAdvertImageFileWithImageUrl:(NSString *)imageUrl {

    NSURL *requestUrl = [[NSURL alloc] initWithString:[imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSData *responseData = response.data;
                NSString *filePath = [self qimNav_getAdvertImageFilePath];
                NSString *advertFileName = [[QIMFileManager sharedInstance] getFileNameFromUrl:imageUrl];
                filePath = [filePath stringByAppendingPathComponent:advertFileName];
                [responseData writeToFile:filePath atomically:YES];
            });
        }
    }                  failure:^(NSError *error) {

    }];
}

// 更新广告配置
- (void)qimNav_updateAdvertConfigWithCheck:(BOOL)check {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [[infoDictionary objectForKey:@"CFBundleVersion"] description];
    long long navConfigUpdateTime = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"AdvertConfigUpdateTime"] longLongValue];
    long long currentTime = [[NSDate date] timeIntervalSince1970];
    if (check || currentTime - navConfigUpdateTime > 24 * 60 * 60 || [self debug] == 1) {
        NSDictionary *oldAdvertConfig = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"AdvertConfig"];
        int oldVersion = [[oldAdvertConfig objectForKey:@"version"] intValue];
        NSString *user = [[[QIMUserCacheManager sharedInstance] userObjectForKey:@"kLastUserId"] lowercaseString];
        NSURL *url = [NSURL URLWithString:[self navUrl]];
        NSString *host = [url host];
        NSString *advertConfigUrl = [NSString stringWithFormat:@"https://qim.qunar.com/advert/%@/advert.php?v=%@&p=%@&u=%@&debug=%@&ver=%d&nav=%@&mv=%@", [[QIMAppInfo sharedInstance] appName], appVersion, @"iphone", [user ? user : @"unknow" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [self debug] ? @"true" : @"false", oldVersion, host ? host : @"unkown", @"v2"];

        QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:advertConfigUrl]];
        request.shouldASynchronous = YES;
        [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
            if (response.code == 200) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    NSDictionary *oldAdvertConfig = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"AdvertConfig"];
                    _oldAdvertDic = oldAdvertConfig;
                    int oldVersion = [[oldAdvertConfig objectForKey:@"version"] intValue];
                    NSDictionary *advertConfig = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
                    int version = [[advertConfig objectForKey:@"version"] intValue];
                    if (version > oldVersion || [self debug] == 1) {
                        NSArray *adList = [advertConfig objectForKey:@"adlist"];
                        if (adList.count > 0) {
                            NSMutableArray *itemArray = [NSMutableArray array];
                            for (NSDictionary *adDic in adList) {
                                QIMAdvertItem *advertItem = [[QIMAdvertItem alloc] init];
                                [advertItem setAdType:[[adDic objectForKey:@"adtype"] intValue]];
                                [advertItem setAdImgUrl:[adDic objectForKey:@"imgurl"]];
                                [advertItem setAdLinkUrl:[adDic objectForKey:@"linkurl"]];
                                if (advertItem.adType == AdvertType_Image) {
                                    if (advertItem.adImgUrl) {
                                        [self qimNav_updateAdvertImageFileWithImageUrl:advertItem.adImgUrl];
                                    }
                                } else if (advertItem.adType == AdvertType_Video) {
                                    if (advertItem.adLinkUrl) {
                                        [self qimNav_updateAdvertImageFileWithImageUrl:advertItem.adLinkUrl];
                                    }
                                }
                                [itemArray addObject:advertItem];
                            }
                            _adItems = itemArray;
                            _adSec = [[advertConfig objectForKey:@"adsec"] intValue];
                            _adShown = [[advertConfig objectForKey:@"shown"] boolValue];
                            _adAllowSkip = [[advertConfig objectForKey:@"allowskip"] boolValue];
                            _adCarousel = [[advertConfig objectForKey:@"carousel"] boolValue];
                            _adCarouselDelay = [[advertConfig objectForKey:@"carouseldelay"] intValue];
                            _adSkipTips = [advertConfig objectForKey:@"skiptips"];
                            _oldAdvertDic = advertConfig;
                            _adInterval = [[advertConfig objectForKey:@"interval"] longLongValue];
                            if ([self debug] != 1) {
                                [[QIMUserCacheManager sharedInstance] setUserObject:advertConfig forKey:@"AdvertConfig"];
                                long long currentTime = [[NSDate date] timeIntervalSince1970];
                                [[QIMUserCacheManager sharedInstance] setUserObject:@(currentTime) forKey:@"AdvertConfigUpdateTime"];
                            }
                        }
                    }
                });
            }
        }                  failure:^(NSError *error) {
            QIMErrorLog(@"获取广告配置失败 : %@", error);
        }];
    }
}

- (void)qimNav_clearAdvertSource {
    /*
    if (_oldAdvertDic) {
        NSMutableSet *newImages = [NSMutableSet set];
        for (QIMAdvertItem *item in self.adItems) {
            if (item.adType == AdvertType_Image) {
                if (item.adImgUrl) {
                    [newImages addObject:item.adImgUrl];
                }
            }
        }
        for (NSDictionary *adDic in [_oldAdvertDic objectForKey:@"adlist"]) {
            int adType = [[adDic objectForKey:@"adtype"] intValue];
            if (adType == AdvertType_Image) {
                NSString *imgUrl = [adDic objectForKey:@"imgurl"];
                if (imgUrl && [newImages containsObject:imgUrl] == NO) {
                    [[QIMDataController getInstance] deleteResourceWithFileName:imgUrl];
                }
            }
        }
    }
     */
}

- (NSString *)qimNav_getRSACertificateCachePath {
    NSString *certificateCache = [UserCachesPath stringByAppendingString:@"CertificateCache/"];
    NSString *certificateDirectoryPath = [certificateCache stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/", self.xmppHost]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:certificateDirectoryPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:certificateDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return certificateDirectoryPath;
}

- (NSString *)qimNav_getRSACodePublicKeyPathWithFileName:(NSString *)fileName {
    NSString *certificate = [[self qimNav_getRSACertificateCachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pem", fileName]];
    return certificate;
}

- (void)qimNav_getRSACodePublicKeyFromRemote {
    NSString *url = [NSString stringWithFormat:@"%@/qtapi/nck/rsa/get_public_key.do", self.javaurl];
    [[QIMManager sharedInstance] sendTPGetRequestWithUrl:url withSuccessCallBack:^(NSData *responseData) {
        NSDictionary *resultDic = [[QIMJSONSerializer sharedInstance] deserializeObject:responseData error:nil];
        if (resultDic.count) {
            BOOL ret = [[resultDic objectForKey:@"ret"] boolValue];
            if (ret) {
                NSDictionary *data = [resultDic objectForKey:@"data"];
                NSString *pub_key_fullkey = [data objectForKey:@"pub_key_fullkey"];
                BOOL success = [pub_key_fullkey writeToFile:[self qimNav_getRSACodePublicKeyPathWithFileName:self.pubkey] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                QIMVerboseLog(@"self.pubKey公钥文件写入%@ %@", self.pubkey, success ? @"成功" : @"失败");
            }
        }
    } withFailedCallBack:^(NSError *error) {
        
    }];
}

- (NSString *)getWebAppUrl {
    return [NSString stringWithFormat:@"%@/entry/#/?domain=%@", self.appWeb, self.domain];
}

- (NSString *)getManagerAppUrl {
    return [NSString stringWithFormat:@"%@/manage#/audit_user?domain=%@", self.appWeb, self.domain];
}


- (NSString *)getNewResetPwdUrl {

    return [NSString stringWithFormat:@"%@?domain=%@", self.resetPwdUrl, self.domain];
}

- (NSString *)getPubSearchUserHostUrl {
    return [self.defaultSettings objectForKey:@"pubSearchUserHost"];
}

- (NSString *)getQChatGetTKUrl {
    return [self.defaultSettings objectForKey:@"qchatGetTk"];
}

@end
