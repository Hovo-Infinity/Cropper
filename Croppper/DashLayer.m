//
//  DashLayer.m
//  Croppper
//
//  Created by Hovhannes Stepanyan on 2/8/18.
//  Copyright © 2018 Hovhannes Stepanyan. All rights reserved.
//

#import "UIBezierPath+Extention.h"
#import "DashLayer.h"

@implementation DashLayer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.frame = frame;
        self.strokeColor = [UIColor blackColor].CGColor;
        self.fillColor = [UIColor clearColor].CGColor;
        self.lineDashPattern = @[@10, @5, @5, @5];
        CGPoint p1 = CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame));
        CGPoint p2 = CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame));
        CGPoint p3 = CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame));
        CGPoint p4 = CGPointMake(CGRectGetMinX(frame), CGRectGetMaxY(frame));
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0.f, 0.f, frame.size.width, frame.size.height)];
        path.lineWidth = 3.f;
        path.lineCapStyle = kCGLineCapRound;
        CGFloat dashes[] = {path.lineWidth , path.lineWidth * 2.f};
        [path setLineDash:dashes count:2 phase:0];
        [path addLineFromPoint:p1 toPoint:p2];
        [path addLineFromPoint:p2 toPoint:p3];
        [path addLineFromPoint:p3 toPoint:p4];
        [path addLineFromPoint:p4 toPoint:p1];
        [[UIColor redColor] setStroke];
        [path stroke];
        [[UIColor clearColor] setFill];
        [path fill];
        self.path = path.CGPath;
    }
    return self;
}

@end
