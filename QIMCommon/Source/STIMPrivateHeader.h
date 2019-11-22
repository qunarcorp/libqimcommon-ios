//
//  STIMPrivateHeader.h
//  STIMCommon
//
//  Created by 李露 on 2018/4/21.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#ifndef STIMPrivateHeader_h
#define STIMPrivateHeader_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "STIMManager.h"
#import "STIMManager+Calendar.h"
#import "STIMManager+MiddleVirtualAccountManager.h"
#import "STIMManager+WorkFeed.h"
#import "STIMManager+ClientConfig.h"
#import "STIMManager+Request.h"
#import "STIMManager+Collection.h"
#import "STIMManager+Consult.h"
#import "STIMManager+DB.h"
#import "STIMManager+EncryptChat.h"
#import "STIMManager+Friend.h"
#import "STIMManager+Group.h"
#import "STIMManager+Request.h"
#import "STIMManager+GroupMessage.h"
#import "STIMManager+Helper.h"
#import "STIMManager+UserMedal.h"
#import "STIMManager+PublicNavUserManager.h"
#import "STIMManager+KeyChain.h"
#import "STIMManager+Login.h"
#import "STIMManager+Message.h"
#import "STIMManager+MySelfStatus.h"
#import "STIMManager+NetWork.h"
#import "STIMManager+PublicRobot.h"
#import "STIMManager+QuickReply.h"
#import "STIMManager+resetLoginInfo.h"
#import "STIMManager+Session.h"
#import "STIMManager+SingleMessage.h"
#import "STIMManager+SystemMessage.h"
#import "STIMManager+UserVcard.h"
#import "STIMManager+Found.h"
#import "STIMManager+Search.h"
#import "STIMManager+XmppImManagerEvent.h"

#import "STIMMessageModel.h"
#import "STIMMessageManager.h"
#import "STIMNavConfigManager.h"
#import "STIMUserCacheManager.h"
#import "STIMVoiceNoReadStateManager.h"

#import "STIMFilteredProtocol.h"
#import "STIMAppInfo.h"
#import "STIMAppSetting.h"
#import "STIMDataController.h"
#import "STIMDESHelper.h"
#import "STIMHttpApi.h"
#import "STIMHttpRequestMonitor.h"
#import "STIMJSONSerializer.h"
#import "STIMFileManager.h"
#import "STIMUUIDTools.h"
#import "STIMNetwork.h"
#import "STIMWatchDog.h"

#import "IMDataManager.h"
#import "IMDataManager+STIMSession.h"
#import "IMDataManager+STIMSearchKeyHistory.h"
#import "IMDataManager+STIMCalendar.h"
#import "IMDataManager+WorkFeed.h"
#import "IMDataManager+STIMDBClientConfig.h"
#import "IMDataManager+STIMDBQuickReply.h"
#import "IMDataManager+STIMNote.h"
#import "IMDataManager+STIMDBGroup.h"
#import "IMDataManager+STIMDBFriend.h"
#import "IMDataManager+STIMDBMessage.h"
#import "IMDataManager+STIMDBCollectionMessage.h"
#import "IMDataManager+STIMDBPublicNumber.h"
#import "IMDataManager+STIMDBUser.h"
#import "IMDataManager+STIMUserMedal.h"
#import "IMDataManager+STIMFoundList.h"

#import "XmppImManager.h"

#import "STIMCommonEnum.h"
#import "STIMConfigKeys.h"
#import "STIMNotificationKeys.h"

#import "STIMPublicRedefineHeader.h"

#pragma mark - Categories

#import "STIMCommonCategories.h"

#import "ASIHTTPRequest.h"
#import "YYModel.h"

#define UserDocumentsPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define UserCachesPath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]
#define UserPath [[STIMNavConfigManager sharedInstance] debug] ? @"_Beta": @"_Release"


#endif /* STIMPrivateHeader_h */
