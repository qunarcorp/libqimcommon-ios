//
//  IQMessage+Utitly.h
//  qunarChatCommon
//
//  Created by admin on 10/14/16.
//  Copyright © 2016 May. All rights reserved.
//

#import "Message.pb.h"
#import <Foundation/Foundation.h>

@interface PBProtocol : NSObject
@property (nonatomic, assign) BOOL needReplaceDefineKey;
+ (PBProtocol *)sharedInstance;
@end
@interface IQMessage(Utility)
- (NSDictionary *)getHeadersDicForHeaders:(NSArray<StringHeader*>*)headers;
@end
@interface XmppMessage(Utility) 
- (NSDictionary *)getHeadersDicForHeaders:(NSArray<StringHeader*>*)headers;
@end
@interface PresenceMessage(Utility)
- (NSDictionary *)getHeadersDicForHeaders:(NSArray<StringHeader*>*)headers;
@end

@interface StringHeaderBuilder(Utility)
#warning 修改 StringHeader setKey方法 精简包大小
- (BOOL)updateDefineKeyForKey:(NSString *)key;
@end

@interface IQMessageBuilder(Utility)
#warning 修改 IQMessageBuilder setKey方法 精简包大小
- (BOOL)updateDefineKeyForKey:(NSString *)key;
@end

@interface PresenceMessageBuilder(Utility)
#warning 修改 PresenceMessageBuilder setKey方法 精简包大小
- (BOOL)updateDefineKeyForKey:(NSString *)key;
@end
