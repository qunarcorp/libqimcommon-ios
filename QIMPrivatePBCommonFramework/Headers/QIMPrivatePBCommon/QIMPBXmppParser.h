//
//  QIMPBXmppParser.h
//  qunarChatCommon
//
//  Created by admin on 16/10/11.
//  Copyright © 2016年 May. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProtoMessage;
@interface QIMPBXmppParser : NSObject

+ (QIMPBXmppParser *)pbXmppParserInit;

- (void)setTeaKey:(uint32_t[4])key;

- (ProtoMessage *)parserOneObjWithData:(NSData *)data;

- (NSArray *)paserProtoMessageWithData:(NSData *)data;

- (NSData *)bulidPackageForProtoMessage:(ProtoMessage *)message;

- (void)clearParser;

- (NSString *)paserBufFormatString;
+ (void)parserServiceDataStr;
+ (void)testParser;
+ (void)parserNSDataStr;
@end
