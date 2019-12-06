//
//  QIMManager+Pay.h
//  QIMCommon
//
//  Created by lihaibin on 2019/10/16.
//

#import "QIMManager.h"
#import "QIMPrivateHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMManager (Pay)

- (void)getBindPayAccount:(NSString *)userid withCallBack:(QIMKitPayCheckAccountBlock)callBack;
- (void)bindAlipayAccount:(NSString *)aliOpenid withAliUid:(NSString *)aliUid userId:(NSString *)userid;
- (void)getAlipayLoginParams;
- (void)sendRedEnvelop:(NSDictionary *)params withCallBack:(QIMKitPayCreateRedEnvelopBlock)callBack;
- (void)getRedEnvelopDetail:(NSString *)xmppid RedRid:(NSString *)rid IsChatRoom:(NSInteger) isRoom withCallBack:(QIMKitPayRedEnvelopDetailBlock)callBack;
- (void)openRedEnvelop:(NSString *)xmppid RedRid:(NSString *)rid IsChatRoom:(NSInteger) isRoom withCallBack:(QIMkitPayRedEnvelopOpenBlock)callBack;
- (void)grapRedEnvelop:(NSString *)xmppid RedRid:(NSString *)rid IsChatRoom:(NSInteger) isRoom withCallBack:(QIMKitPayRedEnvelopGrapBlock)callBack;
- (void)redEnvelopReceive:(NSInteger)page PageSize:(NSInteger)pageSize WithYear:(NSInteger) year withCallBack:(QIMKitPayRedEnvelopReceiveBlock)callBack;
- (void)redEnvelopSend:(NSInteger)page PageSize:(NSInteger)pageSize WithYear:(NSInteger) year withCallBack:(QIMKitPayRedEnvelopSendBlock)callBack;
@end

NS_ASSUME_NONNULL_END
