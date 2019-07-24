//
//  QIMManager+QuickReply.m
//  QIMCommon
//
//  Created by 李露 on 2018/8/8.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMManager+QuickReply.h"
#import "QIMPrivateHeader.h"

@implementation QIMManager (QuickReply)

- (void)getRemoteQuickReply {
    
    NSString *url = [NSString stringWithFormat:@"%@/quickreply/quickreplylist.qunar", [[QIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSURL *destUrl = [NSURL URLWithString:url];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:4];
    [param setQIMSafeObject:[QIMManager getLastUserName] forKey:@"username"];
    [param setQIMSafeObject:[[QIMManager sharedInstance] getDomain] forKey:@"host"];
    [param setQIMSafeObject:@([[IMDataManager qimDB_SharedInstance] qimDB_getQuickReplyGroupVersion]) forKey:@"groupver"];
    [param setQIMSafeObject:@([[IMDataManager qimDB_SharedInstance] qimDB_getQuickReplyContentVersion]) forKey:@"contentver"];
    NSData *requestData = [[QIMJSONSerializer sharedInstance] serializeObject:param error:nil];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[QIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];

    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:destUrl];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPBody:requestData];
    [request setHTTPRequestHeaders:cookieProperties];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSDictionary *result = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
            BOOL ret = [[result objectForKey:@"ret"] boolValue];
            if (ret) {
                NSDictionary *data = [result objectForKey:@"data"];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    [self dealWithQuickReplyRemoteData:data];
                }
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)dealWithQuickReplyRemoteData:(NSDictionary *)data {
    NSDictionary *groupInfo = [data objectForKey:@"groupInfo"];
    NSMutableArray *updateGroupItems = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *deleteGroupItems = [NSMutableArray arrayWithCapacity:3];
    if (groupInfo.count > 0) {
        long groupVersion = [groupInfo objectForKey:@"version"];
        
        NSArray *groups = [groupInfo objectForKey:@"groups"];
        for (NSDictionary *groupItem in groups) {
            long groupRId = [[groupItem objectForKey:@"id"] longValue];
            long groupseq = [[groupItem objectForKey:@"groupseq"] longValue];
            NSString *groupname = [groupItem objectForKey:@"groupname"];
            long groupversion = [[groupItem objectForKey:@"version"] longValue];
            BOOL isdel = [[groupItem objectForKey:@"isdel"] boolValue];
            if (!isdel) {
                [updateGroupItems addObject:groupItem];
            } else {
                [deleteGroupItems addObject:@(groupRId)];
            }
        }
        [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertQuickReply:updateGroupItems];
        [[IMDataManager qimDB_SharedInstance] qimDB_deleteQuickReplyGroup:deleteGroupItems];
    }
    NSDictionary *contentInfo = [data objectForKey:@"contentInfo"];
    NSMutableArray *updateContentItems = [NSMutableArray arrayWithCapacity:3];
    NSMutableArray *deleteContentItems = [NSMutableArray arrayWithCapacity:3];
    if (contentInfo.count > 0) {
        NSArray *contents = [contentInfo objectForKey:@"contents"];
        for (NSDictionary *contentItem in contents) {
            long contentRId = [contentItem objectForKey:@"id"];
            long contentGId = [contentItem objectForKey:@"groupid"];
            NSString *content = [contentItem objectForKey:@"content"];
            long contentsql = [contentItem objectForKey:@"contentseq"];
            long contentVersion = [contentItem objectForKey:@"version"];
            BOOL isdel = [[contentItem objectForKey:@"isdel"] boolValue];
            if (!isdel) {
                [updateContentItems addObject:contentItem];
            } else {
                [deleteContentItems addObject:@(contentRId)];
            }
        }
        [[IMDataManager qimDB_SharedInstance] qimDB_bulkInsertQuickReplyContents:updateContentItems];
        [[IMDataManager qimDB_SharedInstance] qimDB_deleteQuickReplyContents:deleteContentItems];
    }
}

- (NSInteger)getQuickReplyGroupCount {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getQuickReplyGroupCount];
}

- (NSArray *)getQuickReplyGroup {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getQuickReplyGroup];
}

- (NSArray *)getQuickReplyContentWithGroupId:(long)groupId {
    return [[IMDataManager qimDB_SharedInstance] qimDB_getQuickReplyContentWithGroupId:groupId];
}

@end
