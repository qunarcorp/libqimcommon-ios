//
//  QIMAppInfo.h
//  qunarChatIphone
//
//  Created by admin on 16/1/20.
//
//

#import <Foundation/Foundation.h>
#import "QIMCommonEnum.h"

@interface QIMAppInfo : NSObject

@property (nonatomic, copy) NSString *pushToken;
@property (nonatomic, assign) QIMApplicationState applicationState;
@property (nonatomic, assign) QIMProjectType appType;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *customDeviceModel;

+ (id)sharedInstance;

- (NSString *)getPushToken;

/**
 网卡地址
 */
- (NSString *)macAddress;

/**
 终端
 */
- (NSString *)Platform;

/**
 设备名称
 */
- (NSString *)deviceName;

/**
 机器码（唯一标识）
 */
- (NSString *)appAID;


/**
 判断是不是iPad
 */
- (BOOL)getIsIpad;

/**
  系统版本
 */
- (NSString *)SystemVersion;

/**
 运营商
 */
- (NSString *)carrierName;

/**
 App版本号
 */
- (NSString *)AppVersion;

/**
 App Build版本号
 */
- (NSString *)AppBuildVersion;

@end
