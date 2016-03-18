//
//  GLView.h
//  02-Animation
//
//  Created by peironggao on 16/3/16.
//  Copyright © 2016年 gaopeirong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLView : UIView

@property (nonatomic, assign) float modelX;
@property (nonatomic, assign) float modelY;
@property (nonatomic, assign) float modelZ;

@property (nonatomic, assign) float scaleZ;

@property (nonatomic, assign) float rotateZ;
@property (nonatomic, assign) float rotateY;
@property (nonatomic, assign) float rotateX;

@property (nonatomic, assign) float height;

- (void)toggleDisplayLink;

@end
