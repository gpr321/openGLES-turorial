//
//  ViewController.m
//  02-Animation
//
//  Created by peironggao on 16/3/16.
//  Copyright © 2016年 gaopeirong. All rights reserved.
//

#import "ViewController.h"
#import "GLView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet GLView *glView;

@property (weak, nonatomic) IBOutlet UIView *menuView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}
- (IBAction)translateX:(UISlider *)sender
{
    _glView.modelX = sender.value;
}

- (IBAction)translateY:(UISlider *)sender
{
    _glView.modelY = sender.value;
}

- (IBAction)translateZ:(UISlider *)sender
{
    _glView.modelZ = sender.value;
}

- (IBAction)rotateZ:(UISlider *)sender
{
    _glView.rotateZ = sender.value * M_PI;
}

- (IBAction)rotateY:(UISlider *)sender
{
    _glView.rotateY = sender.value * M_PI;
}

- (IBAction)rotateX:(UISlider *)sender
{
    _glView.rotateX = sender.value * M_PI;
}

- (IBAction)toggle
{
    [_glView toggleDisplayLink];
}

- (IBAction)changeHeight:(UISlider *)sender
{
    _glView.height = sender.value;
}

@end
