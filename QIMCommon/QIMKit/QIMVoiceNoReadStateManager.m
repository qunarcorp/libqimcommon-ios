//
//  QIMVoiceNoReadStateManager.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/6/6.
//
//
/**
 未读语音消息保存格式
 {chatId1:[Messages1],
 chatId2:[Messages2],
 chatId3:[Messages3],
 chatId4:[Messages4],
 chatId5:[Messages5],
 }
 */
#import "QIMVoiceNoReadStateManager.h"

@interface QIMVoiceNoReadStateManager ()

@property (nonatomic, assign) BOOL isRead;

@end

static QIMVoiceNoReadStateManager *__voiceNoReadStateManager = nil;
static NSMutableDictionary *_voiceNoReadStateDict = nil;
@implementation QIMVoiceNoReadStateManager

+ (instancetype)sharedVoiceNoReadStateManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __voiceNoReadStateManager = [[QIMVoiceNoReadStateManager alloc] init];
    });
    return __voiceNoReadStateManager;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _voiceNoReadStateDict = [NSMutableDictionary dictionary];
        NSString *path = [self getVoiceReadStatePath];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        [_voiceNoReadStateDict setDictionary:dict];
        
    }
    return self;
}

- (NSMutableDictionary *)voiceNoReadStateDict {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _voiceNoReadStateDict = [NSMutableDictionary dictionary];
        NSString *path = [self getVoiceReadStatePath];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        [_voiceNoReadStateDict setDictionary:dict];
    });
    
    return _voiceNoReadStateDict;
}

- (NSInteger)getIndexOfMsgIdWithChatId:(NSString *)chatId msgId:(NSString *)msgId {
    if (chatId && msgId) {
        NSMutableArray *array = self.voiceNoReadStateDict[chatId];
        if (array && [array containsObject:msgId]) {
            NSInteger index = [array indexOfObject:msgId];
            return index;
        }
    }
    return -1;
}


/**
 获取当前未读语音消息id

 @param chatId chatId
 @param index 消息index
 */
- (NSString *)getMsgIdWithChatId:(NSString *)chatId index:(NSInteger)index {
    if (chatId && index>=0) {
        NSMutableArray *array = self.voiceNoReadStateDict[chatId];
        if (index < array.count) {
            NSString *msgId = array[index];
            if (msgId) {
                return msgId;
            }
        }
    }
    return nil;
}

- (BOOL) playVoiceIsNoReadWithMsgId:(NSString *)msgId ChatId:(NSString *)chatId {
    //    //1包含-未读  0不包含-已读
    BOOL isContain;
    {
        NSMutableArray *array = self.voiceNoReadStateDict[chatId];
        {
            isContain = [array containsObject:msgId];
        }
    }
    return isContain;
}

/**
 获取当前对话中未读语音消息数

 @param chatId chatId
 @return 未读语音消息数
 */
- (NSInteger)getVisibleNoReadSoundsCountWithChatId:(NSString *)chatId {
    
    if (chatId) {
        NSMutableArray *array = self.voiceNoReadStateDict[chatId];
        if (array) {
            return array.count;
        }
    }
    return -1;
}

- (BOOL)isReadWithMsgId:(NSString *)messageId ChatId:(NSString *)chatId {
    if (messageId && chatId) {
        NSMutableArray *array = self.voiceNoReadStateDict[chatId];
        //包含未读，不包含已读
        BOOL isRead = ![array containsObject:messageId];
        //YES 已读，NO未读
        return isRead;
    }
    return NO;
}

- (void)setVoiceNoReadStateWithMsgId:(NSString *)messageId ChatId:(NSString *)chatId withState:(BOOL) unread {
    
    if (!messageId && !chatId) {
        return;
    }
    if (!unread) {
        
        NSMutableArray *chatMessages = [self.voiceNoReadStateDict objectForKey:chatId];
        if (chatMessages.count) {
            if ([chatMessages containsObject:messageId]) {
                return;
            }
            [chatMessages addObject:messageId];
        } else {
            chatMessages = [NSMutableArray arrayWithCapacity:10];
            [chatMessages addObject:messageId];
        }
        if (chatMessages) {
            [self.voiceNoReadStateDict setObject:chatMessages forKey:chatId];
        }
        [self saveVoiceReadStateWithVoiceReadStateDict];
    }  else {
        
        NSMutableArray *chatMessages = [self.voiceNoReadStateDict objectForKey:chatId];
        if (chatMessages.count) {
            [chatMessages removeObject:messageId];
        } else {
            chatMessages = [NSMutableArray arrayWithCapacity:10];
        }
        [self.voiceNoReadStateDict setObject:chatMessages forKey:chatId];
        [self saveVoiceReadStateWithVoiceReadStateDict];
    }
}

//Save Message

- (NSString *)getVoiceReadStatePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    //判断Cache文件夹
    NSString *noReadCachePath = [documentDirectory stringByAppendingPathComponent:@"VoiceMessageState"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:noReadCachePath] == NO) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:noReadCachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    //获取Voice文件路径
    NSString *voiceSourcePath = [noReadCachePath stringByAppendingPathComponent:@"VoiceReadState"];
    return voiceSourcePath;
}

//保存语音消息
- (void)saveVoiceReadStateWithVoiceReadStateDict {
    
    [self.voiceNoReadStateDict writeToFile:[self getVoiceReadStatePath] atomically:YES];
}

@end
