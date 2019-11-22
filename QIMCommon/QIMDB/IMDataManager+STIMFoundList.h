//
//  IMDataManager+STIMFoundList.h
//  STIMCommon
//
//  Created by lilu on 2019/4/17.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "IMDataManager.h"
#import "IMDataManager+STIMSession.h"
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
#import "STIMPublicRedefineHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (STIMFoundList)

- (void)stIMDB_insertFoundListWithAppVersion:(NSString *)version withFoundList:(NSString *)foundListStr;

- (NSString *)stIMDB_getFoundListWithAppVersion:(NSString *)version;

@end

NS_ASSUME_NONNULL_END
