//
//  do_Alipay_SM.m
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Alipay_SM.h"

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "DataSigner.h"
#import "do_Alipay_Order.h"
#import "do_Alipay_Auth.h"
#import <AlipaySDK/AlipaySDK.h>
#import "RSADataSigner.h"
#import "MD5DataSigner.h"

@implementation do_Alipay_SM
#pragma mark - 方法
#pragma mark - 同步异步方法的实现
//同步
//异步
- (void)pay:(NSArray *)parms
{
    //异步耗时操作，但是不需要启动线程，框架会自动加载一个后台线程处理这个函数
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //回调函数名_callbackName
    NSString *_callbackName = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    doInvokeResult *_invokeResult = [[doInvokeResult alloc] init];
    
    //自己的代码实现
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    do_Alipay_Order *order = [[do_Alipay_Order alloc] init];
    NSString *privateKey = _dictParas[@"rsaPrivate"];
    order.partner = _dictParas[@"partner"];
    order.seller = _dictParas[@"sellerId"];
    order.tradeNO = _dictParas[@"tradeNo"]; //订单ID（由商家自行制定）
    order.productName = _dictParas[@"subject"]; //商品标题
    order.productDescription = _dictParas[@"body"]; //商品描述
    order.amount = _dictParas[@"totalFee"]; //商品价格
    order.notifyURL =  _dictParas[@"notifyUrl"]; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = _dictParas[@"timeOut"];
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"alipay";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    

    //获取私钥并将商户信息签名,需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    RSADataSigner *signer = [[RSADataSigner alloc] initWithPrivateKey:privateKey];
    NSString *signedString = [signer signString:orderSpec];
    
    NSString *AA = [[MD5DataSigner new] algorithmName];
    //将签名成功字符串格式化为订单字符串
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSString *resultStatus = resultDic[@"resultStatus"];
            NSMutableDictionary *_dict = [[NSMutableDictionary alloc]init];
            if ([resultStatus  isEqual: @"9000"])
            {
                [_dict setValue:@"订单支付成功" forKey:@"9000"];

            }
            else if ([resultStatus  isEqual: @"8000"])
            {
                [_dict setValue:@"正在处理中" forKey:@"8000"];
            }
            else if ([resultStatus  isEqual: @"4000"])
            {
                [_dict setValue:@"订单支付失败" forKey:@"4000"];
            }
            else if ([resultStatus  isEqual: @"6001"])
            {
                [_dict setValue:@"用户中途取消" forKey:@"6001"];
            }
            else if ([resultStatus  isEqual: @"6002"])
            {
                [_dict setValue:@"网络连接出错" forKey:@"6002"];
            }
            [_invokeResult SetResultNode: _dict];
            [_scritEngine Callback:_callbackName :_invokeResult];
        }];
    }
}

@end