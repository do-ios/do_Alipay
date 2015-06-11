//
//  do_Alipay_Auth.h
//  DoAlipay_SM
//
//  Created by guoxj on 15/6/10.
//  Copyright (c) 2015年 DoAlipay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface do_Alipay_Auth : NSObject

@property(strong)NSString *apiName;
@property(strong)NSString *appName;
@property(strong)NSString *appID;
@property(strong)NSString *bizType;
@property(strong)NSString *pid;
@property(strong)NSString *productID;
@property(strong)NSString *scope;
@property(strong)NSString *targetID;
@property(strong)NSString *authType;
@property(strong)NSString *signDate;
@property(strong)NSString *service;

- (NSString *)description;

@end
