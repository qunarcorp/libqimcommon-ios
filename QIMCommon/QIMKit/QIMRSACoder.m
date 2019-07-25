//
//  QIMRSACoder.m
//  qunarChatCommon
//
//  Created by May on 14/12/29.
//  Copyright (c) 2014年 May. All rights reserved.
//

#import "QIMRSACoder.h"
#import "QIMBase64.h"
#import "NSData+QIMBase64.h"
#import "NSString+QIMBase64.h"
#import "NSBundle+QIMLibrary.h"
#import "QIMNavConfigManager.h"
#import "QIMPublicRedefineHeader.h"
#import <QIMOpenSSL/openssl/rsa.h>
#import <QIMOpenSSL/openssl/pem.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <openssl/rsa.h>
#include <openssl/engine.h>
#include <openssl/pem.h>
#import <CommonCrypto/CommonCrypto.h>

#define RSA_BASE_64 @"MIIBCgKCAQEA2M6/CuCMgZmehFC/DA5cmYW1KS3U0qt+AnRco7Ijg0ohYyO1Mh/I\
88djJuvbHuja/wXZ3Fw9laQsykq1akVR0P3N8ax8FAX0Wb+oLszwIJDVzk748Dsp\
DvBUSmJ4w9fPUyyk8ENCntNqjp3qiOK2V2Jm7GitHtnwbe53c/ti3m/tjzYcixMC\
UoDjbRmYeu/I7jva8AHYPRzAg4Q7Bf4nKX3/2rYi23zWkSEdgPFPq31i8IsrEJPT\
ai7usBU7ZU6nokF+LeeiY/d/cSOZe6FeTncf/8e4EXlgtbXuRqhV31hlXhGo/OLJ\
RjkPyeklCHiWW8sEIsr+macFLU+K0u4StwIDAQAB"

#define PADDING RSA_PKCS1_PADDING

RSA* loadPUBLICKeyFromString( const char* publicKeyStr )
{
    // A BIO is an I/O abstraction (Byte I/O?)
    
    // BIO_new_mem_buf: Create a read-only bio buf with data
    // in string passed. -1 means string is null terminated,
    // so BIO_new_mem_buf can find the dataLen itself.
    // Since BIO_new_mem_buf will be READ ONLY, it's fine that publicKeyStr is const.
    BIO* bio = BIO_new_mem_buf( (void*)publicKeyStr, -1 ) ; // -1: assume string is null terminated
    
    BIO_set_flags( bio, BIO_FLAGS_BASE64_NO_NL ) ; // NO NL
    
    // Load the RSA key from the BIO
    RSA* rsaPubKey = PEM_read_bio_RSA_PUBKEY( bio, NULL, NULL, NULL ) ;
    if( !rsaPubKey )
        printf( "ERROR: Could not load PUBLIC KEY!  PEM_read_bio_RSA_PUBKEY FAILED: %s\n", ERR_error_string( ERR_get_error(), NULL ) ) ;
    
    BIO_free( bio ) ;
    return rsaPubKey ;
}

RSA* loadPRIVATEKeyFromString( const char* privateKeyStr )
{
    BIO *bio = BIO_new_mem_buf( (void*)privateKeyStr, -1 );
    //BIO_set_flags( bio, BIO_FLAGS_BASE64_NO_NL ) ; // NO NL
    RSA* rsaPrivKey = PEM_read_bio_RSAPrivateKey( bio, NULL, NULL, NULL ) ;
    
    if ( !rsaPrivKey )
        printf("ERROR: Could not load PRIVATE KEY!  PEM_read_bio_RSAPrivateKey FAILED: %s\n", ERR_error_string(ERR_get_error(), NULL));
    
    BIO_free( bio ) ;
    return rsaPrivKey ;
}

unsigned char* rsaEncrypt( RSA *pubKey, const unsigned char* str, int dataSize, int *resultLen )
{
    int rsaLen = RSA_size( pubKey ) ;
    unsigned char* ed = (unsigned char*)malloc( rsaLen ) ;
    
    // RSA_public_encrypt() returns the size of the encrypted data
    // (i.e., RSA_size(rsa)). RSA_private_decrypt()
    // returns the size of the recovered plaintext.
    *resultLen = RSA_public_encrypt( dataSize, (const unsigned char*)str, ed, pubKey, PADDING ) ;
    if( *resultLen == -1 )
        printf("ERROR: RSA_public_encrypt: %s\n", ERR_error_string(ERR_get_error(), NULL));
    
    return ed ;
}

unsigned char* rsaDecrypt( RSA *privKey, const unsigned char* encryptedData, int *resultLen )
{
    int rsaLen = RSA_size( privKey ) ; // That's how many bytes the decrypted data would be
    
    unsigned char *decryptedBin = (unsigned char*)malloc( rsaLen ) ;
    *resultLen = RSA_private_decrypt( RSA_size(privKey), encryptedData, decryptedBin, privKey, PADDING ) ;
    if( *resultLen == -1 )
        printf( "ERROR: RSA_private_decrypt: %s\n", ERR_error_string(ERR_get_error(), NULL) ) ;
    
    return decryptedBin ;
}

unsigned char* makeAlphaString( int dataSize )
{
    unsigned char* s = (unsigned char*) malloc( dataSize ) ;
    
    int i;
    for( i = 0 ; i < dataSize ; i++ )
        s[i] = 65 + i ;
    s[i-1]=0;//NULL TERMINATOR ;)
    
    return s ;
}

char* rsaEncryptThenBase64( RSA *pubKey, unsigned char* binaryData, int binaryDataLen, int *outLen )
{
    int encryptedDataLen ;
    
    // RSA encryption with public key
    unsigned char* encrypted = rsaEncrypt( pubKey, binaryData, binaryDataLen, &encryptedDataLen ) ;
    
    // To base 64
    int asciiBase64EncLen ;
    char* asciiBase64Enc = base64( encrypted, encryptedDataLen, &asciiBase64EncLen ) ;
    
    // Destroy the encrypted data (we are using the base64 version of it)
    free( encrypted ) ;
    
    // Return the base64 version of the encrypted data
    return asciiBase64Enc ;
}

unsigned char* rsaDecryptThisBase64( RSA *privKey, char* base64String, int *outLen )
{
    int encBinLen ;
    unsigned char* encBin = unbase64( base64String, (int)strlen( base64String ), &encBinLen ) ;
    
    // rsaDecrypt assumes length of encBin based on privKey
    unsigned char *decryptedBin = rsaDecrypt( privKey, encBin, outLen ) ;
    free( encBin ) ;
    
    return decryptedBin ;
}

char* bio_read_publicKey(const char* data, const char *filepath, int *len)
{
    OpenSSL_add_all_algorithms();
    BIO* bp = BIO_new( BIO_s_file() );
    BIO_read_filename( bp, filepath );
    
    RSA* rsaK = PEM_read_bio_RSAPublicKey( bp, NULL, NULL, NULL );
    int nLen = 0;
    if (NULL == rsaK)
    {
        
        return "";
    }else{
        nLen = RSA_size(rsaK);
    }
    //    int nLen = RSA_size(rsaK);
    char *pEncode = (char*)malloc(nLen + 1);
    memset(pEncode, 0, nLen + 1);
    
    int nlendt = (int)strlen(data);
    int ret = RSA_public_encrypt( nlendt,(const unsigned char*)data,
                                 (unsigned char *)pEncode,rsaK,RSA_PKCS1_PADDING);
    char* strRet = nil;
    if (ret >= 0) {
        *len = ret;
        strRet = (char*)malloc(ret + 1);
        memset(strRet, 0, ret + 1);
        memcpy(strRet, pEncode, ret);
    }
    free(pEncode);
    CRYPTO_cleanup_all_ex_data();
    BIO_free_all( bp );
    RSA_free(rsaK);
    return strRet;
}

@implementation QIMRSACoder

+ (RSA *) rsaWithPublickeyFile:(NSString *) filePath {
    FILE *file;
    
    file = fopen([filePath UTF8String], "rb");
    
    RSA *rsa = PEM_read_RSA_PUBKEY(file, NULL, NULL, NULL);
    
    fclose(file);
    return rsa;
}

+(NSString*) md5:(NSString*) str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), result );
    
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02X",result[i]];
    }
    return [hash lowercaseString];
}

+ (NSString *) writeRSAFile:(NSString *) publicKey {
    NSString *certBase64 = [[NSString alloc] initWithString:publicKey];
    
    NSMutableString *pemString = [NSMutableString string];
    
    [pemString appendString:@"-----BEGIN PUBLIC KEY-----\n"];
    
    int count = 0;
    
    for (int i = 0; i < [certBase64 length]; ++i) {
        
        unichar c = [certBase64 characterAtIndex:i];
        if (c == '\n' || c == '\r') {
            continue;
        }
        [pemString appendFormat:@"%c", c];
        if (++count == 64) {
            [pemString appendString:@"\n"];
            count = 0;
        }
    }
    
    [pemString appendString:@"\n-----END PUBLIC KEY-----\n"];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingPathComponent:@"pub_key"];
    return path;
}

+ (NSString *) rsaYourText:(NSString *) text {
    
    const char *b64_pKey = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCRtdWPrhe2+2jmOURxJlpXkxf9AHsn6UjmPmYdXdaMouA8kPWN2QqFbK8jrC2RymT4JrEvo+YY/udrFvqVlfZgMHWKqCP18e82kGNOX2/3mVeau6XH+xtMypSuBT4lz001XrUyu9p59RXq2UzLO05u07uicu2v+FkrEUZ7D3+onQIDAQAB";
    
    int dataSize = 37 ; // 128 for NO PADDING, __ANY SIZE UNDER 128 B__ for RSA_PKCS1_PADDING
    unsigned char *str = makeAlphaString( dataSize ) ;
    printf( "\nThe original data is:\n%s\n\n", (char*)str ) ;
    
    // LOAD PUBLIC KEY
    RSA *pubKey = loadPUBLICKeyFromString( b64_pKey ) ;
    
    int asciiB64ELen ;
    char* asciiB64E = rsaEncryptThenBase64( pubKey, str, dataSize, &asciiB64ELen ) ;
    
    RSA_free( pubKey ) ; // free the public key when you are done all your encryption
    
    printf( "Sending base64_encoded ( rsa_encrypted ( <<binary data>> ) ):\n%s\n", asciiB64E ) ;
    puts( "<<----------------  SENDING DATA ACROSS INTERWEBS  ---------------->>" ) ;
    
    char* rxOverHTTP = asciiB64E ; // Simulate Internet connection by a pointer reference
    printf( "\nRECEIVED some base64 string:\n%s\n", rxOverHTTP ) ;
    puts( "\n * * * What could it be?" ) ;
    return nil;
}

+ (NSString *)URLEncodedString:(NSString *) str
{
    NSString *result = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)str,
                                                              NULL,
                                                              CFSTR("!*'();:@&=+$,/?%#[] "),
                                                              kCFStringEncodingUTF8));
    return result;
}

+ (NSString *) RSAForPassword:(NSString *)password
{
    //
    // step1 md5
    
    NSString *md5Key = [QIMRSACoder md5:password];
    
    //
    // step2 rsa
    
    NSString *rsaKey = [QIMRSACoder encryptByRsa:md5Key publicKeyFileName:[QIMNavConfigManager sharedInstance].pubkey];
    
    //
    // step3 url encode key
    
    NSString *key = [QIMRSACoder URLEncodedString:rsaKey];
    return key;
}

+ (NSData *) RSAYourText:(NSString *) text withPublicKeyFile:(NSString *) fileName { 
    int length = 0;
    char* pItem = bio_read_publicKey([text UTF8String], [fileName UTF8String], &length);
    NSData *data = [NSData dataWithBytes:pItem length:length];
    //free(pItem);
    return data;
}


+ (SecKeyRef)publicKey:(NSString *) certPath {
    SecCertificateRef myCertificate = nil;
    NSData *certificateData = [[NSData alloc] initWithContentsOfFile:certPath];
    myCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)certificateData);
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(myCertificate,myPolicy,&myTrust);
    SecTrustResultType trustResult;
    if (status == noErr) {
        status = SecTrustEvaluate(myTrust, &trustResult);
    }
    return SecTrustCopyPublicKey(myTrust);
}

+ (NSData *) RSAEncrypotoText:(NSString *)plainText withPublicKey:(SecKeyRef) publicKey {
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = NULL;
    
    cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    memset((void *)cipherBuffer, 0 * 0, cipherBufferSize);
    
    NSData *plainTextBytes = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    int blockSize = cipherBufferSize-11;  // 这个地方比较重要是加密问组长度
    int numBlock = (int)ceil([plainTextBytes length] / (double)blockSize);
    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    for (int i=0; i<numBlock; i++) {
        int bufferSize = MIN(blockSize,[plainTextBytes length]-i*blockSize);
        NSData *buffer = [plainTextBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        OSStatus status = SecKeyEncrypt(publicKey,
                                        kSecPaddingPKCS1,
                                        (const uint8_t *)[buffer bytes],
                                        [buffer length],
                                        cipherBuffer,
                                        &cipherBufferSize);
        if (status == noErr)
        {
            NSData *encryptedBytes = [[NSData alloc]
                                      initWithBytes:(const void *)cipherBuffer
                                      length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
        }
        else
        {
            return nil;
        }
    }
    if (cipherBuffer)
    {
        free(cipherBuffer);
    }
    return encryptedData;
}

+ (NSString *)RSAEncrypotoTheData:(NSString *)plainText withPublicKey:(SecKeyRef) publicKey {
    
    size_t cipherBufferSize = SecKeyGetBlockSize(publicKey);
    uint8_t *cipherBuffer = NULL;
    
    cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    memset((void *)cipherBuffer, 0 * 0, cipherBufferSize);
    
    NSData *plainTextBytes = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    int blockSize = cipherBufferSize-11;  // 这个地方比较重要是加密问组长度
    int numBlock = (int)ceil([plainTextBytes length] / (double)blockSize);
    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    for (int i=0; i<numBlock; i++) {
        int bufferSize = MIN(blockSize,[plainTextBytes length]-i*blockSize);
        NSData *buffer = [plainTextBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        OSStatus status = SecKeyEncrypt(publicKey,
                                        kSecPaddingPKCS1,
                                        (const uint8_t *)[buffer bytes],
                                        [buffer length],
                                        cipherBuffer,
                                        &cipherBufferSize);
        if (status == noErr)
        {
            NSData *encryptedBytes = [[NSData alloc]
                                       initWithBytes:(const void *)cipherBuffer
                                       length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
        }
        else
        {
            return nil;
        }
    }
    if (cipherBuffer)
    {
        free(cipherBuffer);
    }
    NSString *encrypotoResult = [NSString stringWithFormat:@"%@",[encryptedData qim_base64EncodedString]];
    return encrypotoResult;
}

+ (NSString *) encryptByRsa:(NSString*)content {
    NSString *fileName = [QIMNavConfigManager sharedInstance].pubkey;
    int status;
    int length = (int)[content length];
    unsigned char input[length + 1];
    bzero(input, length + 1);
    int i = 0;
    for (; i < length; i++)
    {
        input[i] = [content characterAtIndex:i];
    }
    
    NSString *path = [[QIMNavConfigManager sharedInstance] qimNav_getRSACodePublicKeyPathWithFileName:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path] || !path) {
        path = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:fileName ofType:@"pem"];
    }
    QIMVerboseLog(@"EncryptRSA FileName : %@, Path : %@", fileName, path);
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        RSA *rsa = [self rsaWithPublickeyFile:path];
        
        int len = RSA_size(rsa);
        
        NSInteger flen = len - 11;
        
        
        char *encData = (char*)malloc(flen);
        bzero(encData, flen);
        
        status = RSA_public_encrypt(length,
                                    (unsigned char*)input,
                                    (unsigned char*)encData,
                                    rsa,
                                    RSA_PKCS1_PADDING);
        
        if (status != -1)
        {
            NSData *returnData = [NSData dataWithBytes:encData length:status];
            free(encData);
            encData = NULL;
            
            NSString *ret = [returnData base64EncodedStringWithOptions:0];
            return ret;
        }
        
        free(encData);
        encData = NULL;
        
        return nil;
    }
    return nil;
}

+ (NSString *) encryptByRsa:(NSString*)content publicKeyFileName:(NSString *) fileName
{
    int status;
    int length = (int)[content length];
    unsigned char input[length + 1];
    bzero(input, length + 1);
    int i = 0;
    for (; i < length; i++)
    {
        input[i] = [content characterAtIndex:i];
    }

    NSString *path = [[QIMNavConfigManager sharedInstance] qimNav_getRSACodePublicKeyPathWithFileName:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path] || !path.length) {
        path = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:fileName ofType:@"pem"];
    }
    QIMVerboseLog(@"EncryptRSA FileName : %@, Path : %@", fileName, path);
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        RSA *rsa = [self rsaWithPublickeyFile:path];
        
        int len = RSA_size(rsa);
        
        NSInteger flen = len - 11;
        
        
        char *encData = (char*)malloc(flen);
        bzero(encData, flen);
        
        status = RSA_public_encrypt(length,
                                    (unsigned char*)input,
                                    (unsigned char*)encData,
                                    rsa,
                                    RSA_PKCS1_PADDING);
        
        if (status != -1)
        {
            NSData *returnData = [NSData dataWithBytes:encData length:status];
            free(encData);
            encData = NULL;
            
            NSString *ret = [returnData base64EncodedStringWithOptions:0];
            return ret;
        }
        
        free(encData);
        encData = NULL;
        
        return nil;
    }
    return nil;
}

@end
