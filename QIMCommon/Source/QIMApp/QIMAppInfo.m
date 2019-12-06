//
//  QIMAppInfo.m
//  qunarChatIphone
//
//  Created by admin on 16/1/20.
//
//

#import "QIMPrivateHeader.h"
#import "QIMAppInfo.h"
#import <objc/runtime.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "Reachability.h"
#import <dlfcn.h>

@interface QIMAppInfo ()
// 内存缓存，初始化时需要清零
@property (nonatomic, strong) NSString *macAddress;                // 网卡mac地址

@end

static QIMAppInfo *__globalAppInfo = nil;

@implementation QIMAppInfo

+ (id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __globalAppInfo = [[QIMAppInfo alloc] init];
        [__globalAppInfo registerObserver];
    });
    return __globalAppInfo;
}

- (NSString *)appName {
    if (_appName == nil) {
        _appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    }
    return _appName;
}

- (NSString *)pushToken {
    return _pushToken;
}

- (NSString *)getPushToken {
    if (!_pushToken) {
        _pushToken = [[QIMUserCacheManager sharedInstance] userObjectForKey:@"AppPushToken"];
    }
    return _pushToken;
}

- (void)registerObserver {
    [self addObserver:self forKeyPath:@"pushToken" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"pushToken"]) {
        QIMWarnLog(@"PushToken 改变: %@", change);
        BOOL deleteFlag = [change[@"new"] isEqual:[NSNull null]] || !change[@"new"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0), ^{
            if (_pushToken) {
                [[QIMUserCacheManager sharedInstance] setUserObject:_pushToken forKey:@"AppPushToken"];
            }
            [[QIMManager sharedInstance] sendPushTokenWithMyToken:[[QIMAppInfo sharedInstance] pushToken] WithDeleteFlag:deleteFlag withCallback:nil];
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// 机器的唯一标识
- (NSString *)appAID
{
    return [QIMUUIDTools deviceUUID];
}

- (NSString *)macAddress
{
    if (_macAddress == nil)
    {
        int                 mib[6];
        size_t              len;
        char                *buf;
        unsigned char       *ptr;
        struct if_msghdr    *ifm;
        struct sockaddr_dl  *sdl;
        
        mib[0] = CTL_NET;
        mib[1] = AF_ROUTE;
        mib[2] = 0;
        mib[3] = AF_LINK;
        mib[4] = NET_RT_IFLIST;
        
        if ((mib[5] = if_nametoindex("en0")) == 0)
        {
            return nil;
        }
        
        if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0)
        {
            return nil;
        }
        
        if ((buf = malloc(len)) == NULL)
        {
            return nil;
        }
        
        if (sysctl(mib, 6, buf, &len, NULL, 0) < 0)
        {
            free(buf);
            return nil;
        }
        
        ifm = (struct if_msghdr *)buf;
        sdl = (struct sockaddr_dl *)(ifm + 1);
        ptr = (unsigned char *)LLADDR(sdl);
        NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                               *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
        free(buf);
        _macAddress = outstring;
    }
    
    return _macAddress;
}

- (NSString *)Platform {
    return @"iOS";
}

- (NSString *)deviceName {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *name = malloc(size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    
    NSString *machine = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    
    free(name);
    
    if ([machine isEqualToString:@"i386"] || [machine isEqualToString:@"x86_64"]) {
        if ([[self Platform].uppercaseString isEqualToString:@"IOS"]) {
            machine = @"ios_sim";
        } else {
            NSString *versionString = [[NSProcessInfo processInfo] operatingSystemVersionString];
            NSArray *versions = [versionString componentsSeparatedByCharactersInSet:
                                 [NSCharacterSet characterSetWithCharactersInString:@" （"]];
            if (versions.count > 1) {
                machine = [NSString stringWithFormat:@"mac_%@", [versions objectAtIndex:1]];
            } else {
                NSRange range = [versionString rangeOfString:@"（"];
                versionString = [[versionString stringByReplacingOccurrencesOfString:@" " withString:@"_"] substringToIndex:range.location];
                machine = [NSString stringWithFormat:@"mac_%@", versionString];
            }
        }
    }
    
    // iPhone
    else if ([machine isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    else if ([machine isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    else if ([machine isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    else if ([machine isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    else if ([machine isEqualToString:@"iPhone10,6"])   return @"iPhone X";         // GSM
    else if ([machine isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";    // GSM
    else if ([machine isEqualToString:@"iPhone10,4"])   return @"iPhone 8";         // GSM
    else if ([machine isEqualToString:@"iPhone10,3"])   return @"iPhone X";         // Global
    else if ([machine isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";    // Global
    else if ([machine isEqualToString:@"iPhone10,1"])   return @"iPhone 8";         // Global
    else if ([machine isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";    // GSM
    else if ([machine isEqualToString:@"iPhone9,3"])    return @"iPhone 7";         // GSM
    else if ([machine isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";    // Global
    else if ([machine isEqualToString:@"iPhone9,1"])    return @"iPhone 7";         // Global
    else if ([machine isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    else if ([machine isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    else if ([machine isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    else if ([machine isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    else if ([machine isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    else if ([machine isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    else if ([machine isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    else if ([machine isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    else if ([machine isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    else if ([machine isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (CDMA)";
    else if ([machine isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    else if ([machine isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    else if ([machine isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    else if ([machine isEqualToString:@"iPhone3,2"])    return @"iPhone 4 (GSM Rev A)";
    else if ([machine isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    else if ([machine isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    else if ([machine isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    else if ([machine isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    
    // iPod touch
    else if ([machine isEqualToString:@"iPod7,1"])      return @"iPod touch 6G";
    else if ([machine isEqualToString:@"iPod5,1"])      return @"iPod touch 5G";
    else if ([machine isEqualToString:@"iPod4,1"])      return @"iPod touch 4G";
    else if ([machine isEqualToString:@"iPod3,1"])      return @"iPod touch 3G";
    else if ([machine isEqualToString:@"iPod2,1"])      return @"iPod touch 2G";
    else if ([machine isEqualToString:@"iPod1,1"])      return @"iPod touch 1G";
    
    // iPad
    else if ([machine isEqualToString:@"iPad7,6"])      return @"iPad 6 (Cellular)";
    else if ([machine isEqualToString:@"iPad7,5"])      return @"iPad 6 (WiFi)";
    else if ([machine isEqualToString:@"iPad7,4"])      return @"iPad Pro 10.5-inch (Cellular)";
    else if ([machine isEqualToString:@"iPad7,3"])      return @"iPad Pro 10.5-inch (WiFi)";
    else if ([machine isEqualToString:@"iPad7,2"])      return @"iPad Pro 12.9-inch 2nd-gen (Cellular)";
    else if ([machine isEqualToString:@"iPad7,1"])      return @"iPad Pro 12.9-inch 2nd-gen (WiFi)";
    else if ([machine isEqualToString:@"iPad6,12"])     return @"iPad 5 (Cellular)";
    else if ([machine isEqualToString:@"iPad6,11"])     return @"iPad 5 (WiFi)";
    else if ([machine isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9-inch (Cellular)";
    else if ([machine isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9-inch (WiFi)";
    else if ([machine isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7-inch (Cellular)";
    else if ([machine isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7-inch (WiFi)";
    else if ([machine isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    else if ([machine isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    else if ([machine isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (Cellular)";
    else if ([machine isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    else if ([machine isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (Cellular)";
    else if ([machine isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    else if ([machine isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    else if ([machine isEqualToString:@"iPad4,6"])      return @"iPad Mini Retina (China)";
    else if ([machine isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina (Cellular)";
    else if ([machine isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina (WiFi)";
    else if ([machine isEqualToString:@"iPad4,3"])      return @"iPad Air (CDMA)";
    else if ([machine isEqualToString:@"iPad4,2"])      return @"iPad Air (GSM)";
    else if ([machine isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    else if ([machine isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    else if ([machine isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    else if ([machine isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    else if ([machine isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    else if ([machine isEqualToString:@"iPad3,2"])      return @"iPad 3 (CDMA)";
    else if ([machine isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    else if ([machine isEqualToString:@"iPad2,7"])      return @"iPad Mini (CDMA)";
    else if ([machine isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    else if ([machine isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    else if ([machine isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    else if ([machine isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    else if ([machine isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    else if ([machine isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    else if ([machine isEqualToString:@"iPad1,1"])      return @"iPad";
    
    return machine;
}

- (BOOL)getIsIpad {
#if __has_include("QIMIPadWindowManager.h")
    if (self.customDeviceModel.length > 0) {
        if ([self.customDeviceModel isEqualToString:@"iPhone"]) {
            return NO;
        } else if ([self.customDeviceModel isEqualToString:@"iPad"]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        NSString *deviceType = [UIDevice currentDevice].model;
        
        if([deviceType isEqualToString:@"iPhone"]) {
            //iPhone
            return NO;
        }
        else if([deviceType isEqualToString:@"iPod touch"]) {
            //iPod Touch
            return NO;
        }
        else if([deviceType isEqualToString:@"iPad"]) {
            //iPad
            return YES;
        }
        return NO;
    }
#else
    return NO;
#endif
}

- (NSString *)SystemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)carrierName {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSString *carrierName = carrier.carrierName;    //运营商名称
    return carrierName;
}

- (NSString *)AppVersion {
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];  //当前应用大版本号
    return appVersion;
}

- (NSString *)AppBuildVersion {
    NSString *appBuildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];  //当前应用小build号
    return appBuildVersion;
}

@end
