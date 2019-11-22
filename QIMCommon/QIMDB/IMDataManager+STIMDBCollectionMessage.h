//
//  IMDataManager+STIMDBCollectionMessage.h
//  STIMCommon
//
//  Created by 李露 on 11/24/18.
//  Copyright © 2018 STIM. All rights reserved.
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
#import "IMDataManager+STIMDBPublicNumber.h"
#import "IMDataManager+STIMDBUser.h"
#import "IMDataManager+STIMUserMedal.h"
#import "IMDataManager+STIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (STIMDBCollectionMessage)

- (NSArray *)stIMDB_getCollectionAccountList;

- (void)stIMDB_bulkinsertCollectionAccountList:(NSArray *)accounts;

- (NSDictionary *)stIMDB_selectCollectionUserByJID:(NSString *)jid;

- (void)stIMDB_bulkInsertCollectionUserCards:(NSArray *)userCards;

- (NSDictionary *)stIMDB_getCollectionGroupCardByGroupId:(NSString *)groupId;

- (void)stIMDB_bulkInsertCollectionGroupCards:(NSArray *)array;

- (NSDictionary *)stIMDB_getLastCollectionMsgWithLastMsgId:(NSString *)lastMsgId;

- (NSArray *)stIMDB_getCollectionSessionListWithBindId:(NSString *)bindId;

- (NSArray *)stIMDB_getCollectionMsgListWithBindId:(NSString *)bindId;

- (BOOL)stIMDB_checkCollectionMsgById:(NSString *)msgId;

- (void)stIMDB_bulkInsertCollectionMsgWithMsgDics:(NSArray *)msgs;

- (NSInteger)stIMDB_getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState;

- (NSInteger)stIMDB_getCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId;

-(NSInteger)stIMDB_getCollectionMsgNotReadCountgetCollectionMsgNotReadCountByDidReadState:(NSInteger)readState ForBindId:(NSString *)bindId originUserId:(NSString *)originUserId;

- (void)stIMDB_updateCollectionMsgNotReadStateByJid:(NSString *)jid WithReadtate:(NSInteger)readState;

- (void)stIMDB_updateCollectionMsgNotReadStateForBindId:(NSString *)bindId originUserId:(NSString *)originUserId WithReadState:(NSInteger)readState;

- (NSDictionary *)stIMDB_getCollectionMsgListForMsgId:(NSString *)msgId;

- (NSArray *)stIMDB_getCollectionMsgListWithUserId:(NSString *)userId originUserId:(NSString *)originUserId;

@end

NS_ASSUME_NONNULL_END
