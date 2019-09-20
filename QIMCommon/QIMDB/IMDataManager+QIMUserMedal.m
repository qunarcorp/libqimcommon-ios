//
//  IMDataManager+QIMUserMedal.m
//  QIMCommon
//
//  Created by lilu on 2018/12/11.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "IMDataManager+QIMUserMedal.h"
#import "QIMDataBase.h"

@implementation IMDataManager (QIMUserMedal)

- (NSArray *)qimDB_getUserMedalsWithXmppId:(NSString *)xmppId {
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"Select XmppId, Type, URL, URLDesc, LastUpdateTime From IM_Users_Medal Where XmppId='%@' Order By LastUpdateTime Desc;", xmppId];
        DataReader *reader = [database executeReader:sql withParameters:nil];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *XmppId = [reader objectForColumnIndex:0];
            NSString *type = [reader objectForColumnIndex:1];
            NSString *URL = [reader objectForColumnIndex:2];
            NSString *URLDesc = [reader objectForColumnIndex:3];
            NSNumber *LastUpdateTime = [reader objectForColumnIndex:4];

            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:paramDic setObject:XmppId forKey:@"UserId"];
            [IMDataManager safeSaveForDic:paramDic setObject:type forKey:@"type"];
            [IMDataManager safeSaveForDic:paramDic setObject:URL forKey:@"url"];
            [IMDataManager safeSaveForDic:paramDic setObject:URLDesc forKey:@"desc"];
            [IMDataManager safeSaveForDic:paramDic setObject:LastUpdateTime forKey:@"LastUpdateTime"];
            [resultList addObject:paramDic];
        }
        
    }];
    return resultList;
}

- (void)qimDB_bulkInsertUserMedalsWithData:(NSArray *)userMedals {
    if (userMedals.count <= 0) {
        return;
    }
    [[self dbInstance] syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSMutableArray *params = [[NSMutableArray alloc] init];
        NSString *sql = [NSString stringWithFormat:@"insert or Replace into IM_Users_Medal(XmppId, Type, URL, URLDesc, LastUpdateTime) values(:XmppId, :Type, :URL, :URLDesc, :LastUpdateTime);"];
        for (NSDictionary *dic in userMedals) {
            NSString *userId = [dic objectForKey:@"userId"];
            NSString *host = [dic objectForKey:@"host"];
            NSString *xmppId = [NSString stringWithFormat:@"%@@%@", userId, host];
            NSString *type = [dic objectForKey:@"type"];
            NSString *url = [dic objectForKey:@"url"];
            NSString *urldesc = [dic objectForKey:@"desc"];
            NSNumber *updateTime = [dic objectForKey:@"upt"];
            
            NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:11];
            [param addObject:xmppId ? xmppId : @""];
            [param addObject:type ? type : @""];
            [param addObject:url ? url : @":NULL"];
            [param addObject:urldesc ? urldesc : @""];
            [param addObject:updateTime ? updateTime : @(0)];
            [params addObject:param];
        }
        [database executeBulkInsert:sql withParameters:params];
    }];
}

/**************************************新版勋章********************************/


/**
 查询勋章列表版本号
 */
- (NSInteger)qimDB_selectMedalListVersion {
    __block NSInteger result = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select value from IM_Cache_Data where key=? and type=?"];
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:@"medalListVersionValue"];
        [param addObject:@(10)];
        DataReader *reader = [database executeReader:sql withParameters:param];
        if ([reader read]) {
            result = [[reader objectForColumnIndex:0] longLongValue];
        }
        [reader close];
        
    }];
    return result;
}

/**
 查询勋章列表版本号
 */
- (NSInteger)qimDB_selectUserMedalStatusVersion {
    __block NSInteger result = 0;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = [NSString stringWithFormat:@"select value from IM_Cache_Data where key=? and type=?"];
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:@"medalUserStatusValue"];
        [param addObject:@(10)];
        DataReader *reader = [database executeReader:sql withParameters:param];
        if ([reader read]) {
            result = [[reader objectForColumnIndex:0] longLongValue];
        }
        [reader close];
        
    }];
    return result;
}

/**
 * 查询勋章列表版本号
 *
 * @return
 */
- (NSArray *)qimDB_selectUserHaveMedalStatus:(NSString *)userId {
    if (userId.length <= 0) {
        return nil;
    }
    __block NSMutableArray *resultList = nil;
    [[self dbInstance] inDatabase:^(QIMDataBase* _Nonnull database) {
        NSString *sql = @"select a.medalid ,a.medalName, a.obtainCondition,a.smallIcon,a.bigLightIcon, a.BigGrayIcon,a.bigLockIcon,a.status, COALESCE(userid, ?), COALESCE(medalStatus, 0) from im_medal_list as a left join im_user_status_medal as b on a.medalid  = b.medalid and b.UserId = ? where  a.status = 1 order by b.medalStatus desc, b.updateTime";
        NSMutableArray *param = [[NSMutableArray alloc] init];
        [param addObject:userId];
        [param addObject:userId];
        DataReader *reader = [database executeReader:sql withParameters:param];
        while ([reader read]) {
            if (resultList == nil) {
                resultList = [[NSMutableArray alloc] init];
            }
            NSString *medalid = [reader objectForColumnIndex:0];
            NSString *medalName = [reader objectForColumnIndex:1];
            NSString *obtainCondition = [reader objectForColumnIndex:2];
            NSString *smallIcon = [reader objectForColumnIndex:3];
            NSString *bigLightIcon = [reader objectForColumnIndex:4];
            NSString *BigGrayIcon = [reader objectForColumnIndex:5];
            NSString *bigLockIcon = [reader objectForColumnIndex:6];
            NSNumber *status = [reader objectForColumnIndex:7];
            
            
            NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
            [IMDataManager safeSaveForDic:paramDic setObject:medalid forKey:@"medalid"];
            [IMDataManager safeSaveForDic:paramDic setObject:medalName forKey:@"medalName"];
            [IMDataManager safeSaveForDic:paramDic setObject:obtainCondition forKey:@"obtainCondition"];
            [IMDataManager safeSaveForDic:paramDic setObject:smallIcon forKey:@"smallIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:bigLightIcon forKey:@"bigLightIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:BigGrayIcon forKey:@"BigGrayIcon"];
            [IMDataManager safeSaveForDic:paramDic setObject:bigLockIcon forKey:@"bigLockIcon"];

            [resultList addObject:paramDic];
        }
    }];
    return resultList;
}

/*
public List<UserHaveMedalStatus> selectUserHaveMedalStatus(String userid) {
    deleteJournal();
    
    String sql = "select a.medalid ,a.medalName, a.obtainCondition,a.smallIcon,a.bigLightIcon," +
    "a.BigGrayIcon,a.bigLockIcon,a.status, COALESCE(userid, ?), COALESCE(medalStatus, 0)" +
    "  from im_medal_list as a left join im_user_status_medal as b " +
    "on a.medalid  = b.medalid and b.UserId = ? where  a.status = 1 " +
    "order by b.medalStatus desc, b.updateTime ";
    //        String sql = "select a.medalid ,a.medalName, a.obtainCondition,a.smallIcon,a.bigLightIcon,a.BigGrayIcon,a.status," +
    //                " COALESCE(userid, ?), COALESCE(medalStatus, 0)  from im_medal_list as a left join im_user_status_medal as b " +
    //                "on a.medalid  = b.medalid where a.status = 1 and b.UserId = ?";
    final List<UserHaveMedalStatus> list = new ArrayList<>();
    Object result = query(sql, new String[]{userid, userid}, new IQuery() {
        @Override
        public Object onQuery(Cursor cursor) {
            int count = 0;
            try {
                while (cursor.moveToNext()) {
                    UserHaveMedalStatus data = new UserHaveMedalStatus();
                    data.setMedalId(cursor.getInt(0));
                    data.setMedalName(cursor.getString(1));
                    data.setObtainCondition(cursor.getString(2));
                    data.setSmallIcon(cursor.getString(3));
                    data.setBigLightIcon(cursor.getString(4));
                    data.setBigGrayIcon(cursor.getString(5));
                    data.setBigLockIcon(cursor.getString(6));
                    data.setStatus(cursor.getInt(7));
                    data.setMedalUserId(cursor.getString(8));
                    data.setMedalUserStatus(cursor.getInt(9));
                    list.add(data);
                    //                        count = Integer.parseInt(cursor.getString(0));
                    //                        break;
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (cursor != null) {
                    cursor.close();
                }
            }
            return list;
        }
    });
    //        if (result == null) {
    return list;
    //        } else {
    //            return (int) result;
    //        }
}

public List<UserHaveMedalStatus> selectUserWearMedalStatusByUserid(String userid) {
    deleteJournal();
    
    String sql = "select a.medalid ,a.medalName, a.obtainCondition,a.smallIcon,a.bigLightIcon," +
    "a.BigGrayIcon,a.bigLockIcon,a.status, COALESCE(userid, ?), b.medalStatus, 0" +
    "  from im_medal_list as a left join im_user_status_medal as b " +
    "on a.medalid  = b.medalid and b.UserId = ? where  a.status = 1 " +
    "and (b.medalStatus & 0x02 = 0x02)" +
    "order by b.medalStatus desc, b.updateTime ";
    //        String sql = "select a.medalid ,a.medalName, a.obtainCondition,a.smallIcon,a.bigLightIcon,a.BigGrayIcon,a.status," +
    //                " COALESCE(userid, ?), COALESCE(medalStatus, 0)  from im_medal_list as a left join im_user_status_medal as b " +
    //                "on a.medalid  = b.medalid where a.status = 1 and b.UserId = ?";
    final List<UserHaveMedalStatus> list = new ArrayList<>();
    Object result = query(sql, new String[]{userid, userid}, new IQuery() {
        @Override
        public Object onQuery(Cursor cursor) {
            int count = 0;
            try {
                while (cursor.moveToNext()) {
                    UserHaveMedalStatus data = new UserHaveMedalStatus();
                    data.setMedalId(cursor.getInt(0));
                    data.setMedalName(cursor.getString(1));
                    data.setObtainCondition(cursor.getString(2));
                    data.setSmallIcon(cursor.getString(3));
                    data.setBigLightIcon(cursor.getString(4));
                    data.setBigGrayIcon(cursor.getString(5));
                    data.setBigLockIcon(cursor.getString(6));
                    data.setStatus(cursor.getInt(7));
                    data.setMedalUserId(cursor.getString(8));
                    data.setMedalUserStatus(cursor.getInt(9));
                    list.add(data);
                    //                        count = Integer.parseInt(cursor.getString(0));
                    //                        break;
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (cursor != null) {
                    cursor.close();
                }
            }
            return list;
        }
    });
    //        if (result == null) {
    return list;
    //        } else {
    //            return (int) result;
    //        }
}

public void updateMedalListVersion(int value) {
    String sql = "insert or replace into IM_Cache_Data(key, type, value" + ") values" +
    "(?, ?, ?);";
    
    SQLiteDatabase db = helper.getWritableDatabase();
    
    db.beginTransactionNonExclusive();
    SQLiteStatement stat = db.compileStatement(sql);
    try {
        stat.bindString(1, CacheDataType.medalListVersionValue);
        stat.bindString(2, CacheDataType.medalListVersionType + "");
        stat.bindString(3, value + "");
        stat.executeInsert();
        db.setTransactionSuccessful();
    } catch (Exception e) {
        Logger.e(e, "updateCollectEmojConfig crashed.");
    } finally {
        db.endTransaction();
    }
}



public List<MedalListResponse.DataBean.MedalListBean> selectMedalList() {
    deleteJournal();
    String sql = "select * from IM_Medal_List  where status =" + CacheDataType.Y;
    final List<MedalListResponse.DataBean.MedalListBean> medalList = new ArrayList<>();
    
    
    Object result = query(sql, null, new IQuery() {
        @Override
        public Object onQuery(Cursor cursor) {
            try {
                while (cursor.moveToNext()) {
                    MedalListResponse.DataBean.MedalListBean data = new MedalListResponse.DataBean.MedalListBean();
                    MedalListResponse.DataBean.MedalListBean.IconBean iconBean = new MedalListResponse.DataBean.MedalListBean.IconBean();
                    data.setId(cursor.getInt(0));
                    data.setMedalName(cursor.getString(1));
                    data.setObtainCondition(cursor.getString(2));
                    iconBean.setSmall(cursor.getString(3));
                    iconBean.setBigLight(cursor.getString(4));
                    iconBean.setBigGray(cursor.getString(5));
                    iconBean.setBigLock(cursor.getString(6));
                    data.setStatus(cursor.getInt(7));
                    data.setIcon(iconBean);
                    medalList.add(data);
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (cursor != null) {
                    cursor.close();
                }
            }
            return medalList;
        }
    });
    
    
    return medalList;
}

public void InsertMedalList(MedalListResponse medalList) {
    String sql = "INSERT or REPLACE INTO IM_Medal_List (medalId,medalName,obtainCondition,smallIcon,bigLightIcon,bigGrayIcon,bigLockIcon,status) VALUES(?,?,?,?,?,?,?,?)";
    SQLiteDatabase db = helper.getWritableDatabase();
    try {
        db.beginTransactionNonExclusive();
        SQLiteStatement stat = db.compileStatement(sql);
        for (int i = 0; i < medalList.getData().getMedalList().size(); i++) {
            MedalListResponse.DataBean.MedalListBean data = medalList.getData().getMedalList().get(i);
            
            stat.bindString(1, data.getId() + "");
            stat.bindString(2, data.getMedalName());
            stat.bindString(3, data.getObtainCondition());
            stat.bindString(4, data.getIcon().getSmall());
            stat.bindString(5, data.getIcon().getBigLight());
            stat.bindString(6, data.getIcon().getBigGray());
            stat.bindString(7,data.getIcon().getBigLock());
            stat.bindString(8, data.getStatus() + "");
            stat.executeInsert();
        }
        db.setTransactionSuccessful();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        db.endTransaction();
    }
}

public void InsertUserMedalStatusList(MedalUserStatusResponse medalList) {
    String sql = "INSERT or REPLACE INTO IM_User_Status_Medal (medalId,userId,medalStatus,mappingVersion,updateTime) VALUES(?,?,?,?,?)";
    SQLiteDatabase db = helper.getWritableDatabase();
    try {
        db.beginTransactionNonExclusive();
        SQLiteStatement stat = db.compileStatement(sql);
        for (int i = 0; i < medalList.getData().getUserMedals().size(); i++) {
            MedalUserStatusResponse.DataBean.UserMedalsBean data = medalList.getData().getUserMedals().get(i);
            
            stat.bindString(1, data.getMedalId() + "");
            stat.bindString(2, data.getUserId());
            stat.bindString(3, data.getMedalStatus() + "");
            stat.bindString(4, data.getMappingVersion() + "");
            stat.bindString(5, data.getUpdateTime() + "");
            stat.executeInsert();
        }
        db.setTransactionSuccessful();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        db.endTransaction();
    }
}
*/
@end
