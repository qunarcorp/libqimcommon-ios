//
//  QIMPBXmppParser.m
//  qunarChatCommon
//
//  Created by admin on 16/10/11.
//  Copyright © 2016年 May. All rights reserved.
//

#import "QIMPBXmppParser.h"
#import "Message.pb.h"

#include <zlib.h>
#include <tea.h>

int MAX_BUFF_LENGTH = 65534;
static int MESSAGE_SIZE_LENGTH = 4096;

typedef struct _tagCompreessBuffer {
    char* p;
    uLong length;
}compressbuff;

compressbuff * compressbuff_new(int size) {
    compressbuff * buff = malloc(sizeof(compressbuff));
    buff->p = malloc(sizeof(char) * size);
    buff->length = 0;
    return buff;
}

Bytef * compressbuff_pos(compressbuff*buf, int pos) {
    return (Bytef *)(buf->p + pos);
}

void compressbuff_free(compressbuff*buff){
    free(buff->p);
    free(buff);
}

@implementation QIMPBXmppParser{
    uint32_t tea_key[4];
    NSMutableData *buff;
    int header_size;
    int pos;
}

static unsigned
scan_varint(unsigned len, const uint8_t *data)
{
    unsigned i;
    if (len > 10)
        len = 10;
    for (i = 0; i < len; i++)
        if ((data[i] & 0x80) == 0)
            break;
    if (i == len)
        return 0;
    return i + 1;
}

unsigned scan__varint(unsigned len, const uint8_t *data) {
    return scan_varint(len, data);
}

+ (QIMPBXmppParser *)pbXmppParserInit{
    QIMPBXmppParser *parser = [[QIMPBXmppParser alloc] init];
    return parser;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        header_size = 0;
        pos = 0;
        buff = nil;
        tea_key[0] = 0x00;
        tea_key[1]  = 0x00;
        tea_key[2]  = 0x00;
        tea_key[3]  = 0x00;
    }
    return self;
}

- (NSString *)paserBufFormatString{
    NSString * str = [NSString stringWithFormat:@"Buf Data : %@ , Pos : %d , headerSize : %d",[buff description],pos,header_size];
    return str;
}

- (void)clearParser{
    buff = nil;
    pos = 0;
    header_size = 0;
} 

- (NSData *)encodeGZipWithData:(NSData *)data{
    if (data.length > 0) {
        int finished = 0;
        z_stream zStream;
        {
            //
            // init
            memset(&zStream, 0, sizeof(zStream));
            
            zStream.zalloc = Z_NULL;
            zStream.zfree = Z_NULL;
            zStream.opaque = Z_NULL;
            zStream.avail_in = 0;
            zStream.next_in = 0;
            
            int windowsBits = 15;
            int GZIP_ENCODING = 16;
            
            int status = deflateInit2(&zStream,
                                      Z_DEFAULT_COMPRESSION,
                                      Z_DEFLATED,
                                      windowsBits | GZIP_ENCODING,
                                      8,
                                      Z_DEFAULT_STRATEGY);
            
            if (status != Z_OK) {
                return nil;
            }
        }
        
        NSMutableData *resultData = [NSMutableData data];
        
        uint32_t buflen = 16;
        int status = 0;
        zStream.next_in = data.bytes;
        zStream.avail_in = (uInt)data.length;
        zStream.avail_out = 0;
        
        uLong totalLen = 0;
        
        while (zStream.avail_out == 0) {
            compressbuff *buf = compressbuff_new(buflen);
            
            zStream.next_out = compressbuff_pos(buf, 0);
            zStream.avail_out = buflen;
            status = deflate(&zStream, (finished == 0) ? Z_FINISH : Z_NO_FLUSH);
            if (status == Z_STREAM_END) {
                buf->length = zStream.total_out - totalLen;
                totalLen += buf->length;
                [resultData appendBytes:buf->p length:buf->length];
                compressbuff_free(buf);
                break;
            } else if (status != Z_OK) {
                compressbuff_free(buf);
                return nil;
            }
            buf->length = buflen;
            totalLen += buf->length;
            [resultData appendBytes:buf->p length:buf->length];
            compressbuff_free(buf);
        }
        // 清楚数据
        deflateEnd(&zStream);
        return resultData;
    }
    return nil;
}

- (NSData *)decodeGZipWithData:(NSData *)gzipData{
    if (gzipData.length > 0) {
        z_stream zStream;
        {
            //
            // init
            memset(&zStream, 0, sizeof(zStream));
            
            // Setup the inflate stream
            zStream.zalloc = Z_NULL;
            zStream.zfree = Z_NULL;
            zStream.opaque = Z_NULL;
            zStream.avail_in = 0;
            zStream.next_in = 0;
            int status = inflateInit2(&zStream, 16 + MAX_WBITS);
            if (status != Z_OK) {
                return nil;
            }
        }
        NSMutableData *buffers = [NSMutableData data];
        int status;
        
        int buflen = 16;
        
        zStream.next_in = (z_const Bytef *)gzipData.bytes;
        zStream.avail_in = (uInt)gzipData.length;
        zStream.avail_out = 0;
        
        uLong totalLen = 0;
        
        while (zStream.avail_in != 0) {
            
            compressbuff *buf = compressbuff_new(buflen);
            
            zStream.next_out = compressbuff_pos(buf, 0);
            zStream.avail_out = buflen;
            status = inflate(&zStream, Z_NO_FLUSH);
            //if (status == Z_STREAM_END) {
            //    buf->length = zStream.total_out - totalLen;
            //    totalLen += buf->length;
            //    break;
            //} else
            if (status != Z_OK && status != Z_STREAM_END) {
                compressbuff_free(buf);
                return nil;
            }
            buf->length = buflen - zStream.avail_out;
            totalLen += buf->length;
            [buffers appendBytes:buf->p length:buf->length];
            compressbuff_free(buf);
        }
        
        // 清楚数据
        inflateEnd(&zStream);
        return buffers;
    }
    return nil;
}

- (ProtoMessage *)parserMessageByTeaWithHeader:(ProtoHeader *)header{
    int i = 0;
    while ((header.message.length - i) >= 2 * (sizeof(uint32_t))) {
        tea_decrypt((uint32_t *)(header.message.bytes + i), tea_key);
        i += 2 * sizeof(uint32_t);
    }
    ProtoMessage *message = [ProtoMessage parseFromData:header.message];
    return message;
}
    
- (ProtoMessage *)parserMessageWithHeader:(ProtoHeader *)header{
    if (header) { 
        if (header.hasOptions) {
            //
            // 0x01 是压缩，0x05 是 TEA
            if (header.options == 0x01) { 
                ProtoMessage *message = [ProtoMessage parseFromData:[self decodeGZipWithData:header.message]];
                return message;
                
            } else if (header.options == 0x05) {
               int i = 0;
                while ((header.message.length - i) >= 2 * (sizeof(uint32_t))) {
                    tea_decrypt((uint32_t *)(header.message.bytes + i), tea_key);
                    i += 2 * sizeof(uint32_t);
                }
                ProtoMessage *message = [ProtoMessage parseFromData:header.message];
                return message;
            } else if (header.options == 0x00) {
                
                ProtoMessage *message = [ProtoMessage parseFromData:header.message];;
                return message;
            }
            
            
        } else {
            //
            // 木有选项，那奏是没压缩的ProtoMessage
            
            if (header.hasMessage) {
//                return  [ProtoMessage parseFromData:[self decodeGZipWithData:header.message]];;
                ProtoMessage *message = [ProtoMessage parseFromData:header.message];;
                return message;
            }
        }
    }
    return nil;
}

- (ProtoMessage *)parserOneObjWithData:(NSData *)data{
    if (buff == nil) {
        buff = [NSMutableData data];
    }
    if (data) {
        [buff appendData:data];
    }
    if (data.length <= 0) {
        return nil;
    }
    //
    // 第三步，parse
    unsigned varintcount = 0;
    int message_count = 0;
    do {
        if (header_size > 0){
            //
            // 可以parse 一次了
            if (buff.length >= header_size + pos) {
                NSData *headerData = [buff subdataWithRange:NSMakeRange(pos, header_size)];
                ProtoHeader* header = [ProtoHeader parseFromData:headerData];
                if (header) {
                    ProtoMessage *msg = [self parserMessageWithHeader:header];
                    if (msg) {
                        message_count++;
                        pos += header_size;
                        header_size = 0;
                        return msg;
                    }
                    pos += header_size;
                    header_size = 0;
                }
            } else {
                
                // 数据不够了 等下次再解
                break;
            }
        }
      //Paser完了 清空Parser  || pos >= size
        if (pos == buff.length) {
            [self clearParser];
            break;
        }

        int remain = buff.length - pos;
        if (remain >= 1) {
            int size = 0;
            int count = remain > 3 ? 3 : remain;
            int i = 1;
            for (i = 1; i <= count; i++) {
                
                /* code */ //整数最多10位
                varintcount = scan__varint(i,buff.bytes + pos);
                if (varintcount > 0) {
                    header_size = [self parse__uint32:[buff subdataWithRange:NSMakeRange(pos, buff.length - pos > 10?10:buff.length-pos)]];
                    pos += i;
                    break;
                }
            }
        } else {
            varintcount = 0;
            break;
        }
    } while(varintcount > 0);
    return NULL;

}


- (NSArray *)paserProtoMessageWithData:(NSData *)data{
    if (buff == nil) {
        buff = [NSMutableData data];
    }
    if (data) {
        [buff appendData:data];
    }
    if (data.length <= 0) {
        return nil;
    }
    
    NSMutableArray *resultList = nil;
    unsigned varintcount = 0;
    int message_count = 0;
    do {
        /* code */
        if (header_size > 0){
            //
            // 可以parse 一次了
            if (buff.length >= header_size + pos) {
                // Buff内的数据 够用 解一次
                NSData *headerData = [buff subdataWithRange:NSMakeRange(pos, header_size)];
                long long length = [headerData length];
                ProtoHeader* header = [ProtoHeader parseFromData:headerData];
                
                if (header) {
                    ProtoMessage *msg = [self parserMessageWithHeader:header];
                    if (msg) {
                        message_count++;
                        if (resultList == nil) {
                            resultList = [NSMutableArray array];
                        }
                        [resultList addObject:msg];
                    }
                    pos += header_size;
                    header_size = 0;
                }
            } else {
                // 数据不够了 等下次再解
                break;
            }
        }
        //Paser完了 清空Parser  || pos >= size
        if (pos == buff.length) {
            [self clearParser];
            break;
        }
        
        int remain = buff.length - pos;
        if (remain >= 1) {
            int maxIntCount = 10;
            int count = remain > maxIntCount ? maxIntCount : remain; // ? 为什么只找3位
            int i = 1;
            for (i = 1; i <= count; i++) {
                /* code */ //整数最多10位
                varintcount = scan__varint(i, buff.bytes + pos);
                if (varintcount > 0) {
                    header_size = [self parse__uint32:[buff subdataWithRange:NSMakeRange(pos, buff.length - pos > maxIntCount?maxIntCount:buff.length-pos)]];
                    pos += i;
                    break;
                }
            }
        } else {
            varintcount = 0;
            break;
        }
    } while(varintcount > 0);
    return resultList;
}


- (void)setTeaKey:(uint32_t[4])key{
    memcpy(tea_key, key, 4 * sizeof(uint32_t));
}

- (NSData *)uint32__pack:(uint32_t)value{
    SInt32 size = computeUInt32SizeNoTag(value);
    NSMutableData* data = [NSMutableData dataWithLength:size];
    PBCodedOutputStream* stream = [PBCodedOutputStream streamWithData:data];
    [stream writeUInt32NoTag:value];
    return data;
}

- (uint32_t)parse__uint32:(NSData *)data{
    PBCodedInputStream *stream = [PBCodedInputStream streamWithData:data];
    return [stream readUInt32];
}

- (NSData *)bulidPackageForProtoMessage:(ProtoMessage *)message{
    if (message) {
        static uint8_t *packbuf = NULL;
        static uint32_t buflength = 0;
        static uint32_t MAX_BUF_LENGTH = 0;
        
        NSMutableData *resultData = [NSMutableData data];
        NSData *messageData = [message data];
        long long len = messageData.length; 
        if (len > 200) {
            ProtoHeaderBuilder *builder = [ProtoHeader builder];
            [builder setOptions:0x01];
            messageData = [self encodeGZipWithData:messageData];
            [builder setMessage:messageData];
            NSData *headerData = [[builder build] data];
            size_t headerlen = headerData.length;
            NSData *packLenData = [self uint32__pack:headerlen];
            [resultData appendData:packLenData];
            [resultData appendData:headerData];
            return resultData;
        } else if (0) {
            ProtoHeaderBuilder *builder = [ProtoHeader builder];
            [builder setOptions:0x0];
            [builder setMessage:messageData];
            NSData *headerData = [[builder build] data];
            size_t headerlen = headerData.length;
            NSData *packLenData = [self uint32__pack:headerlen];
            [resultData appendData:packLenData];
            [resultData appendData:headerData];
            return resultData;
        } else {
            //
            // 使用tea 加扰 
            ProtoHeaderBuilder *builder = [ProtoHeader builder];
            [builder setOptions:0x5];
            int i = 0;
            while ((messageData.length - i) >= 2 * (sizeof(uint32_t))) {
                tea_encrypt((uint32_t *)(messageData.bytes + i), tea_key);
                i += 2 * sizeof(uint32_t);
            }
            [builder setMessage:messageData];
            NSData *headerData = [[builder build] data];
            size_t headerlen = headerData.length;
            NSData *packLenData = [self uint32__pack:headerlen];
            [resultData appendData:packLenData];
            [resultData appendData:headerData];
            return resultData;
        }
    }
    return nil;
}

+ (void)parserNSDataStrXmppMessage{
    NSString *dataStr = @"08011001 18003a20 36393446 30454133 36353633 34383836 39394531 45383436 45364335 42313037 4a231221 56426f78 4d616e61 6765206d 6f646966 79686420 78787820 2d2d636f 6d706163 74";
    NSMutableData *data = [NSMutableData data];
    for (NSString *str in [dataStr componentsSeparatedByString:@" "]) {
        for (int i = 0; i<str.length; i=i+2) {
            unsigned int anInt;
            NSString *hexCharStr = [str substringWithRange:NSMakeRange(i, 2)];
            NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
            [scanner scanHexInt:&anInt];
            [data appendBytes:&anInt length:1];
        }
    }
    XmppMessage *xmppMessage = [XmppMessage parseFromData:data];
}

+ (void)parserNSDataStr{
    // cb011005 32c6016a b18429c9 8a0d7a94 828af50a f601e8ff b72caf16 be0ec65f e4ab53a5 5f94bdb3 590b3731 624f6cf2 f7d9a5c1 d7af67ff 6524ea9e cf7be1bd a9a2264f bb473b69 15f43604 21cd99a6 29a341cb 368ce966 d8410e0e 8737a482 f7af9829 eb194d46 2e8a6c7b da70c391 b57742c3 f5aed115 25fb49fc 83b7bfae eae969cc 0c70e42f 857f3e98 6eb25cd7 9d5d6ef8 5fbd87be c6745a75 5ee73b9f 7d4b9bd9 2d759f77 bbcd197b 8ecd6852 4fd1d8fe ee2fbfe9 f44704f2 76900ffc 9b66052e 1a4931cc abecfc9c 2b
    // e4021001 32df021f 8b080000 00000000 038d8dbd 4fc2401c 86016334 4ee86498 2e0c0e1a daebd7f5 4a6c6476 30eec6e1 7af72b2d a11f4081 386b4c18 8c13891a dc1cd001 9c8c3131 2efe2950 75367155 7170667c f33eeffb 2c67f24b 856dc1b9 a268a6c2 c1e2ba26 54865da6 630a6061 62681a54 7814bad0 84908304 35e67851 2b51e4f4 7a381df6 8aab8285 52dd6f57 fe9bcdaf dc7236bf b09e2923 70197554 3088ee62 5d018732 cbb52c42 5cca0d46 75bafb9a 5b592c64 15945d7b ca1d444e 0d254731 d8453f60 5528a20e abb77f93 972471ab 2ccb8d44 6ab443d6 947814c8 ae5f07b9 a3ca22ea 86f58809 39812096 894674c3 b10c0d0b 2c18565d a0821142 b8a5a9d4 042ac561 75276401 d8f3901b 3389fd67 9a1bdf9b 9dcf3d29 a2ae2f12 cf36b189 3cf0ab5e 621ba672 f8fe7239 79bc4b2f c648b14a 25152394 8ecfa737 b71fc7cf e9a097f6 efd3b3d1 dbd5c9b4 7f3a1d3d 20b43ff9 9e7c0eb6 7e006bae 0419ce01 0000
    // 83011005 327f93a9 c4415051 5d994bc5 39bbc409 4286f2f7 d9a5c1d7 af67ff65 24ea9ecf 7be1979c 546af01a a9c8d328 d2443cb1 6ebda629 a341cb36 8ce9189d 6a081841 ac0fe673 f8da582d 484a8e93 ecd88110 faaf86c9 2431a8c0 a60a6f63 6a0a7d45 ccc0d9d8 9df85c04 9ba828c8 f508b804 4008b0ff b6e8f530 574050ae 81d3fb9c 2b
    // 9c021001 3297021f 8b080000 00000000 03e36010 6097527f ba6bd9d3 c6f6921c 87e4fcbc b4d4a2d4 bce454bd d4acc4a4 8cfce212 43fda77b 163c5dd7 fea263be 92604a62 9e5e4e66 a9035c52 eb361307 a300b304 839582a9 b985b1a9 ab99a393 a593a589 b989b9a5 a5b1818b 89939ba9 93b9a199 85aba5d7 4a262e56 29464305 46a1f94c d1f94959 0a259505 a9b64a99 b989e9a9 4a0a6589 39a5405e 5a664eaa 7e99917e 4a7e795e 4e7e628a 7e496a6e 817e9a89 412ad04c 437373a3 24432363 33cb1453 43a3d454 0b033323 33034b63 43bdac82 747b9056 5bb07e62 94abb901 55fa25e6 92a2250f ac9c1895 b9c5e999 29b68482 4449a13c 33a524c3 d6dcd440 21233533 3da3c4d6 d0d8d844 2136a071 d5dddf73 b4011721 0d8c9e01 0000
    // b8011001 32b3011f 8b080000 00000000 03e36010 10908a4e 49ccd3cb c92c7548 cd4a4cca c82f2e31 d40f8b36 34303630 3036b388 8d0f88f6 4d4c8e8d 7789ce4d 4c8e3734 d03334d2 338a8df7 74893632 35303470 72357634 76323131 30b2b434 b7303235 74723333 72713472 33022a0a 7052a2a5 e15a561c 8c02cc12 0c560ac6 a68e6e4e ce460646 46ae40d5 2e869666 8ea66ee6 26e606e6 e68e2ee6 e6465e9c 5cac528c 860a8c42 0c015faf 3efa3347 1b008b16 dc3cfa00 0000
   // NSData *packLenData = [[QIMPBXmppParser QIMPBXmppParserInit] uint32__pack:450000000];
    //
    NSString *dataStr = @"80100532 7c93a9c4 4150515d 994bc539 bbc40942 86f2f7d9 a5c1d7af 67ff6524 ea9ecf7b e1bda9a2 264fbb47 3b6915f4 360421cd 99a629a3 41cb368c e927b1d9 b1ff8a9c c1defe57 20ec08cc 4da471cb 014ab5e2 589cf2b8 784f2405 56213d27 1b34cc20 1cf21935 5aede7a0 348ecc0d c6076f46 04a59a34 a44d6870 b2a0e5a1 2b";
    NSMutableString *serviceStr = [NSMutableString string];
    NSMutableData *data = [NSMutableData data];
    for (NSString *str in [dataStr componentsSeparatedByString:@" "]) {
        for (int i = 0; i<str.length; i=i+2) {
            unsigned int anInt;
            NSString *hexCharStr = [str substringWithRange:NSMakeRange(i, 2)];
            NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
            [scanner scanHexInt:&anInt];
            [serviceStr appendFormat:@"%d",anInt];
            [serviceStr appendString:@","];
            [data appendBytes:&anInt length:1];
        }
    }
    ProtoHeader *header = [ProtoHeader parseFromData:data];
    ProtoMessage *pMsg = [[QIMPBXmppParser pbXmppParserInit] parserMessageByTeaWithHeader:header];
//    ProtoMessage *pMsg = [[QIMPBXmppParser pbXmppParserInit] parserOneObjWithData:data];
    //IQMessage *iqMsg = [IQMessage parseFromData:data];
    XmppMessage *xmppMsg = [XmppMessage parseFromData:pMsg.message];
}

+ (void)parserServiceDataStr{
    
    NSArray *strArray = [@"128,1,16,5,50,124,147,169,196,65,80,81,93,153,75,197,57,187,196,9,66,134,242,247,217,165,193,215,175,103,255,101,36,234,158,207,123,225,189,169,162,38,79,187,71,59,105,21,244,54,4,33,205,153,166,41,163,65,203,54,140,233,39,177,217,177,255,138,156,193,222,254,87,32,236,8,204,77,164,113,203,1,74,181,226,88,156,242,184,120,79,36,5,86,33,61,39,27,52,204,32,28,242,25,53,90,237,231,160,52,142,204,13,198,7,111,70,4,165,154,52,164,77,104,112,178,160,229,161,43" componentsSeparatedByString:@","];
    Byte byte[strArray.count];
    int index = 0;
    for (NSString *str in strArray) {
        byte[index] = [str intValue];
        index++;
    }
    NSData *ndata = [NSData dataWithBytes:byte length:strArray.count];
    QIMPBXmppParser *parse = [QIMPBXmppParser pbXmppParserInit];
    ProtoMessage *message = [parse parserOneObjWithData:ndata];
    return;
}

+ (void)testGZip{
    QIMPBXmppParser *parser = [QIMPBXmppParser pbXmppParserInit];
    NSData *messageData = [[NSString stringWithString:@"12345678"] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encodeData = [parser encodeGZipWithData:messageData];
    NSData *decodeData = [parser decodeGZipWithData:encodeData];
    return;
}

+ (void)testTea{
    uint32_t tea_key[4];
    tea_key[0]=0x00;
    tea_key[1]=0x00;
    tea_key[2]=0x00;
    tea_key[3]=0x00;
    NSData *messageData = [[NSString stringWithString:@"12345678"] dataUsingEncoding:NSUTF8StringEncoding];
    int i = 0;
    while ((messageData.length - i) >= 2 * (sizeof(uint32_t))) {
        tea_encrypt((uint32_t *)(messageData.bytes + i), tea_key);
        i += 2 * sizeof(uint32_t);
    }
    i = 0;
    while ((messageData.length - i) >= 2 * (sizeof(uint32_t))) {
        tea_decrypt((uint32_t *)(messageData.bytes + i), tea_key);
        i += 2 * sizeof(uint32_t);
    }
    return;
}

+ (void)testWireshark{
    NSString *fileUrl = @"/Users/admin/Documents/TestWireshake/test";
    NSData *fileData = [NSData dataWithContentsOfFile:fileUrl];
    NSData *decodeData = [[QIMPBXmppParser pbXmppParserInit] decodeGZipWithData:fileData];
    if (decodeData == nil) {
        decodeData = fileData;
    }
    NSString *content = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
    return;
}

+ (void)testParser{
    [self parserNSDataStr];
    return;
    QIMPBXmppParser *parser = [QIMPBXmppParser pbXmppParserInit];
    ProtoMessageBuilder *builder = [ProtoMessage builder];
    [builder setFrom:@"Test From"];
    [builder setTo:@"Test To"];
    [builder setSignalType:SignalTypeSignalTypeGroupChat];
    NSData *data = [parser bulidPackageForProtoMessage:[builder build]];
    
    NSMutableData *parserData = [NSMutableData data];
    [parserData appendData:data];
    [parserData appendData:data];
    [parserData appendData:data];
    [parserData appendData:data];
    
    NSData *data1 = [parserData subdataWithRange:NSMakeRange(0, 45)];
    NSData *data2 = [parserData subdataWithRange:NSMakeRange(45, parserData.length-45)];
    
//    ProtoMessage *msg = [parser parserOneObjWithData:parserData];
//    NSArray *messageList = [parser paserProtoMessageWithData:parserData];
    ProtoMessage *msg1 = [parser parserOneObjWithData:data1];
    ProtoMessage *msg2 = [parser parserOneObjWithData:nil];
    NSArray *msgList2 = [parser paserProtoMessageWithData:data2];
}

@end
