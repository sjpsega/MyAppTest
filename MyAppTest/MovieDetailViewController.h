//
// Created by sjpsega on 13-12-8.
// Copyright (c) 2013 sjpsega. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface MovieDetailViewController : UIViewController
@property (nonatomic, strong)id data;

- (instancetype)initWithData:(id)data;

+ (instancetype)controllerWithData:(id)data;

@end