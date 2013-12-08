//
// Created by sjpsega on 13-12-8.
// Copyright (c) 2013 sjpsega. All rights reserved.
//


#import <SDWebImage/UIImageView+WebCache.h>
#import "MovieDetailViewController.h"


@implementation MovieDetailViewController {
    IBOutlet UILabel *titleLable;
    IBOutlet UILabel *yearLabel;
    IBOutlet UIImageView *img;
}

- (instancetype)initWithData:(id)data {
    self = [super init];
    if (self) {
        self.data = data;
    }

    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    titleLable.text = self.data[@"title"];
    yearLabel.text = self.data[@"year"];
    [img setImageWithURL:self.data[@"images"][@"large"]];
}

@end