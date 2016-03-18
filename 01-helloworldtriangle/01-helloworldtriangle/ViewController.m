//
//  ViewController.m
//  01-helloworldtriangle
//
//  Created by peironggao on 16/3/16.
//  Copyright © 2016年 gaopeirong. All rights reserved.
//

#import "ViewController.h"
#import "GLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GLView *view = [[GLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
}



@end
