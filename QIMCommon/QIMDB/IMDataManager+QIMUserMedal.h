//
//  IMDataManager+QIMUserMedal.h
//  QIMCommon
//
//  Created by lilu on 2018/12/11.
//  Copyright © 2018 QIM. All rights reserved.
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
#import "IMDataManager+QIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (QIMUserMedal)

- (NSArray *)qimDB_getUserMedalsWithXmppId:(NSString *)xmppId;

- (void)qimDB_bulkInsertUserMedalsWithData:(NSArray *)userMedals;

@end

NS_ASSUME_NONNULL_END
