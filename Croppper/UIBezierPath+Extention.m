//
//  UIBezierPath+Extention.m
//  Croppper
//
//  Created by Hovhannes Stepanyan on 2/8/18.
//  Copyright © 2018 Hovhannes Stepanyan. All rights reserved.
//

#import "UIBezierPath+Extention.h"

@implementation UIBezierPath (Extention)

- (void)addLineFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2 {
    [self moveToPoint:p1];
    [self addLineToPoint:p2];
    [self stroke];
}

@end
