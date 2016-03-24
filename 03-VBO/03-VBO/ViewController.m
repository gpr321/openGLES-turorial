//
//  ViewController.m
//  03-VBO
//
//  Created by peironggao on 16/3/19.
//  Copyright © 2016年 gaopeirong. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OpenGLView *glView = [[OpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:glView];
}

@end
