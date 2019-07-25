//
//  IMDataManager+QIMNote.h
//  QIMCommon
//
//  Created by 李露 on 10/29/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "IMDataManager.h"
#import "IMDataManager+QIMSession.h"
#import "IMDataManager+QIMCalendar.h"
#import "IMDataManager+WorkFeed.h"
#import "IMDataManager+QIMDBClientConfig.h"
#import "IMDataManager+QIMDBQuickReply.h"
#import "IMDataManager+QIMDBGroup.h"
#import "IMDataManager+QIMDBFriend.h"
#import "IMDataManager+QIMDBMessage.h"
#import "IMDataManager+QIMDBCollectionMessage.h"
#import "IMDataManager+QIMDBPublicNumber.h"
#import "IMDataManager+QIMDBUser.h"
#import "IMDataManager+QIMUserMedal.h"
#import "IMDataManager+QIMFoundList.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMDataManager (QIMNote)

/*********************** QTNotes **********************/

//Main

- (BOOL)checkExitsMainItemWithQid:(NSInteger)qid WithCId:(NSInteger)cid;

- (void)insertQTNotesMainItemWithQId:(NSInteger)qid
                             WithCid:(NSInteger)cid
                           WithQType:(NSInteger)qtype
                          WithQTitle:(NSString *)qtitle
                      WithQIntroduce:(NSString *)qIntroduce
                        WithQContent:(NSString *)qContent
                           WithQTime:(NSInteger)qTime
                          WithQState:(NSInteger)qstate
                   WithQExtendedFlag:(NSInteger)qExtendedFlag;

- (void)updateToMainWithQId:(NSInteger)qid
                    WithCid:(NSInteger)cid
                  WithQType:(NSInteger)qtype
                 WithQTitle:(NSString *)qtitle
              WithQDescInfo:(NSString *)qdescInfo
               WithQContent:(NSString *)qcontent
                  WithQTime:(NSInteger)qtime
                 WithQState:(NSInteger)qstate
          WithQExtendedFlag:(NSInteger)qExtendedFlag;

- (void)updateToMainItemWithDicts:(NSArray *)mainItemList;

- (void)deleteToMainWithQid:(NSInteger)qid;

- (void)deleteToMainWithCid:(NSInteger)cid;

- (void)updateToMainItemTimeWithQId:(NSInteger)qid
                          WithQTime:(NSInteger)qTime
                  WithQExtendedFlag:(NSInteger)qExtendedFlag;

- (void)updateMainStateWithQid:(NSInteger)qid
                       WithCid:(NSInteger)cid
                    WithQState:(NSInteger)qstate
             WithQExtendedFlag:(NSInteger)qExtendedFlag;

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType;

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType QString:(NSString *)qString;

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType WithExceptQState:(NSInteger)qState;

- (NSArray *)getQTNotesMainItemWithQType:(NSInteger)qType WithQState:(NSInteger)qState;

- (NSArray *)getQTNoteMainItemWithQType:(NSInteger)qType WithQDescInfo:(NSString *)descInfo;
- (NSArray *)getQTNotesMainItemWithQExtendFlag:(NSInteger)qExtendFlag;
- (NSArray *)getQTNotesSubItemWithQSExtendedFlag:(NSInteger)qsExtendedFlag;

- (NSArray *)getQTNotesMainItemWithQExtendedFlag:(NSInteger)qExtendedFlag needConvertToString:(BOOL)flag;

- (NSDictionary *)getQTNotesMainItemWithCid:(NSInteger)cid;

- (NSInteger)getQTNoteMainItemMaxTimeWithQType:(NSInteger)qType;

- (NSInteger)getMaxQTNoteMainItemCid;

//Sub

- (BOOL)checkExitsSubItemWithQsid:(NSInteger)qsid WithCsid:(NSInteger)csid;

- (void)insertQTNotesSubItemWithCId:(NSInteger)cid
                           WithQSId:(NSInteger)qsid
                           WithCSId:(NSInteger)csid
                         WithQSType:(NSInteger)qstype
                        WithQSTitle:(NSString *)qstitle
                    WithQSIntroduce:(NSString *)qsIntroduce
                      WithQSContent:(NSString *)qsContent
                         WithQSTime:(NSInteger)qsTime
                         WithQState:(NSInteger)qSstate
                WithQS_ExtendedFlag:(NSInteger)qs_ExtendedFlag;

- (void)updateToSubWithCid:(NSInteger)cid
                  WithQSid:(NSInteger)qsid
                  WithCSid:(NSInteger)csid
               WithQSTitle:(NSString *)qSTitle
            WithQSDescInfo:(NSString *)qsDescInfo
             WithQSContent:(NSString *)qsContent
                WithQSTime:(NSInteger)qsTime
               WithQSState:(NSInteger)qsState
       WithQS_ExtendedFlag:(NSInteger)qs_ExtendedFlag;

- (void)updateToSubItemWithDicts:(NSArray *)subItemList;

- (void)deleteToSubWithCId:(NSInteger)cid;

- (void)deleteToSubWithCSId:(NSInteger)Csid;

- (void)updateSubStateWithCSId:(NSInteger)Csid
                   WithQSState:(NSInteger)qsState
            WithQsExtendedFlag:(NSInteger)qsExtendedFlag;

- (void)updateToSubItemTimeWithCSId:(NSInteger)csid
                         WithQSTime:(NSInteger)qsTime
                 WithQsExtendedFlag:(NSInteger)qsExtendedFlag;

- (NSArray *)getQTNotesSubItemWithMainQid:(NSString *)qid WithQSExtendedFlag:(NSInteger)qsExtendedFlag;

- (NSArray *)getQTNotesSubItemWithMainQid:(NSString *)qid WithQSExtendedFlag:(NSInteger)qsExtendedFlag needConvertToString:(BOOL)flag;

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid QSExtendedFlag:(NSInteger)qsExtendedFlag;

- (NSArray *)getQTNotesSubItemWithQSState:(NSInteger)qsState;

- (NSArray *)getQTNotesSubItemWithExpectQSState:(NSInteger)qsState;

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSState:(NSInteger)qsState;

- (NSDictionary *)getQTNotesSubItemWithCid:(NSInteger)cid WithUserId:(NSString *)userId;

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithExpectQSState:(NSInteger)qsState;

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSType:(NSInteger)qsType WithQSState:(NSInteger)qsState;

- (NSArray *)getQTNotesSubItemWithCid:(NSInteger)cid WithQSType:(NSInteger)qsType WithExpectQSState:(NSInteger)qsState;

- (NSInteger)getQTNoteSubItemMaxTimeWithCid:(NSInteger)cid
                                 WithQSType:(NSInteger)qsType;
- (NSDictionary *)getQTNoteSubItemWithParmDict:(NSDictionary *)paramDict;

- (NSInteger)getMaxQTNoteSubItemCSid;


@end

NS_ASSUME_NONNULL_END
