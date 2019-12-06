//
//  QIMPrivateHeader.h
//  QIMCommon
//
//  Created by 李露 on 2018/4/21.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#ifndef QIMPrivateHeader_h
#define QIMPrivateHeader_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "QIMManager.h"
#import "QIMManager+Calendar.h"
#import "QIMManager+MiddleVirtualAccountManager.h"
#import "QIMManager+WorkFeed.h"
#import "QIMManager+ClientConfig.h"
#import "QIMManager+Request.h"
#import "QIMManager+Collection.h"
#import "QIMManager+Consult.h"
#import "QIMManager+DB.h"
#import "QIMManager+EncryptChat.h"
#import "QIMManager+Friend.h"
#import "QIMManager+Group.h"
#import "QIMManager+Request.h"
#import "QIMManager+GroupMessage.h"
#import "QIMManager+Helper.h"
#import "QIMManager+UserMedal.h"
#import "QIMManager+PublicNavUserManager.h"
#import "QIMManager+KeyChain.h"
#import "QIMManager+Login.h"
#import "QIMManager+Message.h"
#import "QIMManager+MySelfStatus.h"
#import "QIMManager+NetWork.h"
#import "QIMManager+PublicRobot.h"
#import "QIMManager+QuickReply.h"
#import "QIMManager+resetLoginInfo.h"
#import "QIMManager+Session.h"
#import "QIMManager+SingleMessage.h"
#import "QIMManager+SystemMessage.h"
#import "QIMManager+UserVcard.h"
#import "QIMManager+Found.h"
#import "QIMManager+Search.h"
#import "QIMManager+XmppImManagerEvent.h"
#import "QIMManager+Pay.h"

#import "QIMMessageModel.h"
#import "QIMMessageManager.h"
#import "QIMNavConfigManager.h"
#import "QIMUserCacheManager.h"
#import "QIMVoiceNoReadStateManager.h"

#import "QIMFilteredProtocol.h"
#import "QIMAppInfo.h"
#import "QIMAppSetting.h"
#import "QIMDataController.h"
#import "QIMDESHelper.h"
#import "QIMHttpRequestMonitor.h"
#import "QIMJSONSerializer.h"
#import "QIMFileManager.h"
#import "QIMUUIDTools.h"
#import "QIMNetwork.h"
#import "QIMWatchDog.h"

#import "IMDataManager.h"
#import "IMDataManager+QIMSession.h"
#import "IMDataManager+QIMSearchKeyHistory.h"
#import "IMDataManager+QIMCalendar.h"
#import "IMDataManager+WorkFeed.h"
#import "IMDataManager+QIMDBClientConfig.h"
#import "IMDataManager+QIMDBQuickReply.h"
#import "IMDataManager+QIMNote.h"
#import "IMDataManager+QIMDBGroup.h"
#import "IMDataManager+QIMDBFriend.h"
#import "IMDataManager+QIMDBMessage.h"
#import "IMDataManager+QIMDBCollectionMessage.h"
#import "IMDataManager+QIMDBPublicNumber.h"
#import "IMDataManager+QIMDBUser.h"
#import "IMDataManager+QIMUserMedal.h"
#import "IMDataManager+QIMFoundList.h"

#import "XmppImManager.h"

#import "QIMCommonEnum.h"
#import "QIMConfigKeys.h"
#import "QIMNotificationKeys.h"

#import "QIMPublicRedefineHeader.h"

#pragma mark - Categories

#import "QIMCommonCategories.h"

#import "YYModel.h"

#define UserDocumentsPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define UserCachesPath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
#define UserPath [[QIMNavConfigManager sharedInstance] debug] ? @"_Beta": @"_Release"


#endif /* QIMPrivateHeader_h */
