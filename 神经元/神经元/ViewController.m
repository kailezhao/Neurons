//
//  ViewController.m
//  神经元
//
//  Created by WT－WD on 17/7/24.
//  Copyright © 2017年 none. All rights reserved.
//

#import "ViewController.h"
#import "NeuronsView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   NeuronsView *view = [[NeuronsView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
