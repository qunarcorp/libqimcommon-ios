//
//  IMDataManager+QIMDBCollectionMessage.h
//  QIMCommon
//
//  Created by 李露 on 11/24/18.
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
#import "IMDataManager+QIMDBPublicNumber.h"
#import "IMDataManager+QIMDBUser.h"
#import "IMDataManager+QIMUserMedal.h"
#import "IMDataManager+QIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (QIMDBCollectionMessage)

- (NSArray *)qimDB_getCollectionAccountList;

- (void)qimDB_bulkinsertCollectionAccountList:(NSArray *)accounts;

- (NSDictionary *)qimDB_selectCollectionUserByJID:(NSString *)jid;

- (void)qimDB_bulkInsertCollectionUserCards:(NSArray *)userCards;

- (NSDictionary *)qimDB_getCollectionGroupCardByGroupId:(NSString *)groupId;

- (void)qimDB_bulkInsertCollectionGroupCards:(NSArray *)array;

- (NSDictionary *)qimDB_getLastCollectionMsgWithLastMsgId:(NSString *)lastMsgId;

- (NSArray *)qimDB_getCollectionSessionListWithBindId:(NSString *)bindId;

- (NSArray *)qimDB_getCollectionMsgListWithBindId:(NSString *)bindId;

- (BOOL)qimDB_checkCollectionMsgById:(NSString *)msgId;

- (void)qimDB_bulkInsertCollectionMsgWithMsgDics:(NSArray *)msgs;

- (NSInteger)qimDB_getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState;

- (NSInteger)qimDB_getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId;

-(NSInteger)qimDB_getCollectionMsgNotReadCountgetCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId originUserId:(NSString *)originUserId;

- (void)qimDB_updateCollectionMsgNotReadStateByJid:(NSString *)jid WithReadtate:(NSInteger)readState;

- (void)qimDB_updateCollectionMsgNotReadStateForBindId:(NSString *)bindId originUserId:(NSString *)originUserId WithReadState:(NSInteger)readState;

- (NSDictionary *)qimDB_getCollectionMsgListForMsgId:(NSString *)msgId;

- (NSArray *)qimDB_getCollectionMsgListWithUserId:(NSString *)userId originUserId:(NSString *)originUserId;

@end

NS_ASSUME_NONNULL_END
