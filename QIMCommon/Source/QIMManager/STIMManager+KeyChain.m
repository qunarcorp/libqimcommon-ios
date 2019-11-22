//
//  STIMManager+KeyChain.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/2.
//

#import "STIMManager+KeyChain.h"
#import "STIMPrivateHeader.h"

@implementation STIMManager (KeyChain)
 
+ (void)updateSessionListToKeyChain {
    NSArray *itemArray = [[STIMManager sharedInstance] getFullSessionList];
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
//                [[STIMManager sharedInstance] getHeaderImageLocalPathForUserId:[obj objectForKey:@"XmppId"] WithHeaderImageSize:CGSizeMake(90, 90)];
                UIImage *headerImage = nil;
                if (fileName.length > 0) {
                    headerImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:fileName] scale:[UIScreen mainScreen].scale];
                }
                if (headerImage) {
                    [STIMUUIDTools setHeadImage:UIImageJPEGRepresentation(headerImage, 1.0) forUserId:[obj objectForKey:@"XmppId"]];
                } else {
                    [tempDic setSTIMSafeObject:fileName forKey:@"headSrc"];
                }
            }
        }];
        itemArray = temp;
        NSData *sessionListStr = [[STIMJSONSerializer sharedInstance] serializeObject:itemArray error:nil];
        [STIMUUIDTools setUUIDToolsSessionList:sessionListStr];
    }
}

+ (void)updateGroupListToKeyChain {
    NSData *groupListStr = [[STIMJSONSerializer sharedInstance] serializeObject:[[IMDataManager stIMDB_SharedInstance] stIMDB_getGroupList] error:nil];
    [STIMUUIDTools setUUIDToolsMyGroupList:groupListStr];
}

+ (void)updateFriendListToKeyChain {
    //save friend list to keychain
    NSArray *dbFriendList = [[IMDataManager stIMDB_SharedInstance] stIMDB_selectFriendList];
    NSMutableArray *friendList = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *infoDic in dbFriendList) {
        
        NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [newDic setSTIMSafeObject:infoDic[@"UserId"] forKey:@"UserId"];
        [newDic setSTIMSafeObject:infoDic[@"XmppId"] forKey:@"XmppId"];
        [newDic setSTIMSafeObject:infoDic[@"Name"] forKey:@"Name"];
        [friendList addObject:newDic];
    }
    NSData *friendListStr = [[STIMJSONSerializer sharedInstance] serializeObject:[friendList subarrayWithRange:NSRangeFromString([NSString stringWithFormat:@"(0,%ld)", MIN(friendList.count, 40)])] error:nil];
    [STIMUUIDTools setUUIDToolsFriendList:friendListStr];
}

+ (void)updateRequestFileURL {
    [STIMUUIDTools setRequestFileURL:[[[STIMNavConfigManager sharedInstance] innerFileHttpHost] dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (void)updateRequestURL {
    NSLog(@"[[[STIMNavConfigManager sharedInstance] newerHttpUrl] : %@", [[STIMNavConfigManager sharedInstance] newerHttpUrl]);
    [STIMUUIDTools setRequestURL:[[[STIMNavConfigManager sharedInstance] newerHttpUrl] dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (void)updateNewHttpRequestURL {
    [STIMUUIDTools setNewHttpRequestURL:[[[STIMNavConfigManager sharedInstance] newerHttpUrl] dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (void)updateRequestDomain {
    [STIMUUIDTools setRequestDomain:[[[STIMNavConfigManager sharedInstance] domain] dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
