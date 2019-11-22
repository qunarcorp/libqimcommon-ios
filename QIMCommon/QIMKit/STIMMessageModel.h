//
//  Message.h
//  qunarChatMac
//
//  Created by ping.xue on 14-2-28.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STIMCommonEnum.h"

@interface STIMMessageModel : NSObject

@property (nonatomic, copy)   NSString          *xmppId;
@property (nonatomic, copy)   NSString          *messageId;                 //消息Id
@property (nonatomic, copy)   NSString          *from;                      //消息发送方
@property (nonatomic, copy)   NSString          *to;                        //消息接收方
@property (nonatomic, copy)   NSString          *realFrom;                  //消息真实发送方
@property (nonatomic, copy)   NSString          *realTo;                    //消息真实接受方
@property (nonatomic, copy)   NSString          *ochatJson;
@property (nonatomic, copy)   NSString          *channelInfo;               //消息channelInfo
@property (nonatomic, copy)   NSString          *message;                   //消息Body体
@property (nonatomic, copy)   NSString          *extendInformation;         //消息的扩展信息
@property (nonatomic, copy)   NSString          *backupInfo;                //群艾特消息，携带BackUpInfo
@property (nonatomic, strong) NSDictionary      *appendInfoDict;            //qchat需求 -> 对方发送过来携带的cctext，bu等字段，发回去消息时务必携带

@property (nonatomic, copy)   NSString          *chatId;                    //Consult消息必须携带

#warning 8.22发送地理位置临时改动
@property (nonatomic, copy)   NSString          *originalMessage;
@property (nonatomic, copy)   NSString          *originalExtendedInfo;

//@property (nonatomic, copy)   NSString          *nickName;

@property (nonatomic, copy)   NSString          *realJid;

@property (nonatomic, assign) IMPlatform        platform;                   //消息发送方的平台
@property (nonatomic, assign) STIMMessageType    messageType;                //消息的Type
@property (nonatomic, assign) STIMMessageSendState   messageSendState;       //消息当前发送状态
@property (nonatomic, assign) STIMMessageRemoteReadState messageReadState;   //消息当前阅读状态
@property (nonatomic, assign) STIMMessageDirection  messageDirection;           //消息方向
//@property (nonatomic, assign) STIMMessageRemoteReadState remoteReadState;    //消息已读状态

@property (nonatomic, assign) ChatType          originChatType;             //代收消息 -> 原始消息的ChatType
@property (nonatomic, assign) ChatType          chatType;                   //消息的ChatType
@property (nonatomic, assign) long long         messageDate;                //消息时间戳
//@property (nonatomic, assign) long long         version;
@property (nonatomic, strong) NSData            * imageData;
//@property (nonatomic, strong) NSString          *MD5;// 保存图片only

//@property (nonatomic, copy)   NSString          *fromUser;
//@property (nonatomic, assign) int               readTag;
@property (nonatomic, copy)   NSString          *msgRaw;                    //原始的消息完整体

- (NSDictionary *)getMsgInfoDic;

- (NSString *)messageId;


@end

