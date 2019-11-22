//
//  STIMManager+QuickReply.m
//  STIMCommon
//
//  Created by 李露 on 2018/8/8.
//  Copyright © 2018年 STIMKit. All rights reserved.
//

#import "STIMManager+QuickReply.h"
#import "STIMPrivateHeader.h"

@implementation STIMManager (QuickReply)

- (void)getRemoteQuickReply {
    
    NSString *url = [NSString stringWithFormat:@"%@/quickreply/quickreplylist.qunar", [[STIMNavConfigManager sharedInstance] newerHttpUrl]];
    NSURL *destUrl = [NSURL URLWithString:url];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:4];
    [param setSTIMSafeObject:[STIMManager getLastUserName] forKey:@"username"];
    [param setSTIMSafeObject:[[STIMManager sharedInstance] getDomain] forKey:@"host"];
    [param setSTIMSafeObject:@([[IMDataManager stIMDB_SharedInstance] stIMDB_getQuickReplyGroupVersion]) forKey:@"groupver"];
    [param setSTIMSafeObject:@([[IMDataManager stIMDB_SharedInstance] stIMDB_getQuickReplyContentVersion]) forKey:@"contentver"];
    NSData *requestData = [[STIMJSONSerializer sharedInstance] serializeObject:param error:nil];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    NSString *requestHeaders = [NSString stringWithFormat:@"q_ckey=%@", [[STIMManager sharedInstance] thirdpartKeywithValue]];
    [cookieProperties setObject:requestHeaders forKey:@"Cookie"];
    [cookieProperties setObject:@"application/json;" forKey:@"Content-type"];

    STIMHTTPRequest *request = [[STIMHTTPRequest alloc] initWithURL:destUrl];
    [request setHTTPMethod:STIMHTTPMethodPOST];
    [request setHTTPBody:requestData];
    [request setHTTPRequestHeaders:cookieProperties];
    [STIMHTTPClient sendRequest:request complete:^(STIMHTTPResponse *response) {
        if (response.code == 200) {
            NSDictionary *result = [[STIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
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
        [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertQuickReply:updateGroupItems];
        [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteQuickReplyGroup:deleteGroupItems];
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
        [[IMDataManager stIMDB_SharedInstance] stIMDB_bulkInsertQuickReplyContents:updateContentItems];
        [[IMDataManager stIMDB_SharedInstance] stIMDB_deleteQuickReplyContents:deleteContentItems];
    }
}

- (NSInteger)getQuickReplyGroupCount {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getQuickReplyGroupCount];
}

- (NSArray *)getQuickReplyGroup {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getQuickReplyGroup];
}

- (NSArray *)getQuickReplyContentWithGroupId:(long)groupId {
    return [[IMDataManager stIMDB_SharedInstance] stIMDB_getQuickReplyContentWithGroupId:groupId];
}

@end
