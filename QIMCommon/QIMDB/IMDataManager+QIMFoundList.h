//
//  IMDataManager+QIMFoundList.h
//  QIMCommon
//
//  Created by lilu on 2019/4/17.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "IMDataManager.h"
#import "IMDataManager+QIMSession.h"
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
#import "QIMPublicRedefineHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (QIMFoundList)

- (void)qimDB_insertFoundListWithAppVersion:(NSString *)version withFoundList:(NSString *)foundListStr;

- (NSString *)qimDB_getFoundListWithAppVersion:(NSString *)version;

@end

NS_ASSUME_NONNULL_END
