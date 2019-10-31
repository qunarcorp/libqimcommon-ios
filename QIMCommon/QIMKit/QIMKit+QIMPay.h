//
//  QIMKit+QIMPay.h
//  QIMCommon
//
//  Created by lihaibin on 2019/10/16.
//

#import "QIMKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMKit (QIMPay)
- (void)getBindPayAccount:(NSString *)userid withCallBack:(QIMKitPayCheckAccountBlock)callBack;
- (void)sendRedEnvelop:(NSDictionary *)params withCallBack:(nonnull QIMKitPayCreateRedEnvelopBlock)callBack;
- (void)bindAlipayAccount:(NSString *)aliOpenid withAliUid:(NSString *)aliUid userId:(NSString *)userid;
- (void)getRedEnvelopDetail:(NSString *)xmppid RedRid:(NSString *)rid IsChatRoom:(NSInteger) isRoom withCallBack:(QIMKitPayRedEnvelopDetailBlock)callBack;
- (void)openRedEnvelop:(NSString *)xmppid RedRid:(NSString *)rid IsChatRoom:(NSInteger) isRoom withCallBack:(QIMkitPayRedEnvelopOpenBlock)callBack;
- (void)grapRedEnvelop:(NSString *)xmppid RedRid:(NSString *)rid IsChatRoom:(NSInteger) isRoom withCallBack:(QIMKitPayRedEnvelopGrapBlock)callBack;
- (void)redEnvelopReceive:(NSInteger)page PageSize:(NSInteger)pageSize WithYear:(NSInteger) year withCallBack:(QIMKitPayRedEnvelopReceiveBlock)callBack;
- (void)redEnvelopSend:(NSInteger)page PageSize:(NSInteger)pageSize WithYear:(NSInteger) year withCallBack:(QIMKitPayRedEnvelopSendBlock)callBack;
- (void)getAlipayLoginParams;
@end

NS_ASSUME_NONNULL_END
