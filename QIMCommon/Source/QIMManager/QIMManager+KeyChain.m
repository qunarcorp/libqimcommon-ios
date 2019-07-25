//
//  QIMManager+KeyChain.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/2.
//

#import "QIMManager+KeyChain.h"
#import "QIMPrivateHeader.h"

@implementation QIMManager (KeyChain)
 
+ (void)updateSessionListToKeyChain {
    NSArray *itemArray = [[QIMManager sharedInstance] getFullSessionList];
    if (itemArray.count > 0) {
        __block id tempDic = nil;
        __block NSMutableArray *temp = [NSMutableArray arrayWithArray:itemArray];
        [temp enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            int chatType = [[obj objectForKey:@"ChatType"] intValue];
            if (chatType == ChatType_System) {
                tempDic = obj;
                [temp removeObject:tempDic];
            }
            if (chatType == ChatType_SingleChat) {
                //Comment by 8.28
                NSString *fileName = @"";
//                [[QIMManager sharedInstance] getHeaderImageLocalPathForUserId:[obj objectForKey:@"XmppId"] WithHeaderImageSize:CGSizeMake(90, 90)];
                UIImage *headerImage = nil;
                if (fileName.length > 0) {
                    headerImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:fileName] scale:[UIScreen mainScreen].scale];
                }
                if (headerImage) {
                    [QIMUUIDTools setHeadImage:UIImageJPEGRepresentation(headerImage, 1.0) forUserId:[obj objectForKey:@"XmppId"]];
                } else {
                    [tempDic setQIMSafeObject:fileName forKey:@"headSrc"];
                }
            }
        }];
        itemArray = temp;
        NSData *sessionListStr = [[QIMJSONSerializer sharedInstance] serializeObject:itemArray error:nil];
        [QIMUUIDTools setUUIDToolsSessionList:sessionListStr];
    }
}

+ (void)updateGroupListToKeyChain {
    NSData *groupListStr = [[QIMJSONSerializer sharedInstance] serializeObject:[[IMDataManager qimDB_SharedInstance] qimDB_getGroupList] error:nil];
    [QIMUUIDTools setUUIDToolsMyGroupList:groupListStr];
}

+ (void)updateFriendListToKeyChain {
    //save friend list to keychain
    NSArray *dbFriendList = [[IMDataManager qimDB_SharedInstance] qimDB_selectFriendList];
    NSMutableArray *friendList = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *infoDic in dbFriendList) {
        
        NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [newDic setQIMSafeObject:infoDic[@"UserId"] forKey:@"UserId"];
        [newDic setQIMSafeObject:infoDic[@"XmppId"] forKey:@"XmppId"];
        [newDic setQIMSafeObject:infoDic[@"Name"] forKey:@"Name"];
        [friendList addObject:newDic];
    }
    NSData *friendListStr = [[QIMJSONSerializer sharedInstance] serializeObject:[friendList subarrayWithRange:NSRangeFromString([NSString stringWithFormat:@"(0,%ld)", MIN(friendList.count, 40)])] error:nil];
    [QIMUUIDTools setUUIDToolsFriendList:friendListStr];
}

+ (void)updateRequestFileURL {
    [QIMUUIDTools setRequestFileURL:[[[QIMNavConfigManager sharedInstance] innerFileHttpHost] dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (void)updateRequestURL {
    NSLog(@"[[[QIMNavConfigManager sharedInstance] newerHttpUrl] : %@", [[QIMNavConfigManager sharedInstance] newerHttpUrl]);
    [QIMUUIDTools setRequestURL:[[[QIMNavConfigManager sharedInstance] newerHttpUrl] dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (void)updateNewHttpRequestURL {
    [QIMUUIDTools setNewHttpRequestURL:[[[QIMNavConfigManager sharedInstance] newerHttpUrl] dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (void)updateRequestDomain {
    [QIMUUIDTools setRequestDomain:[[[QIMNavConfigManager sharedInstance] domain] dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
