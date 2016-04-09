//
//  FPAVisualiser.m
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 08/04/2016.
//  Copyright © 2016 Daniel Harvey. All rights reserved.
//

#import "FPAVisualiser.h"
#import "FPAMainViewController.h"

@implementation FPAVisualiser

-(id)initWithViewController:(FPAMainViewController *)viewController visualNumber:(NSUInteger)visualNumber {
    FPAVisualiser *me = [super init];
    if (me) {
        me.mvc=viewController;
        me.visualNumber=visualNumber;
        me.drawColor= [UIColor whiteColor]; // good start
        me.x=0;
        me.y=0;
        me.backgroundColor=[UIColor clearColor];
 //       CGRect parentFrame=me.mvc.view.frame;
        CGRect halfFrame=CGRectMake(0, me.mvc.view.frame.size.height/2, me.mvc.view.frame.size.width, me.mvc.view.frame.size.height/2);
        me.frame=halfFrame;
        [self.mvc.view addSubview:me];
        [self.mvc.view bringSubviewToFront:self.mvc.blurb];
    }
    return me;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing codes
//    [super drawRect:rect];
    if (self.alpha==0) return; // don't bother if invisible
    
    UIColor *lineColor;
    CFTimeInterval touchLength=CACurrentMediaTime()-self.mvc.touchTime;
    
    if (touchLength>6) {
        lineColor=[self getRandomColor];
        lineColor=[lineColor colorWithAlphaComponent:self.z];
    } else {
        lineColor=[self.mvc getTextColor];
        float darkness=self.visualNumber/self.mvc.numberOfPlayers;
        lineColor=[self getDarkenColor:lineColor darkness:darkness]; // different colour for each one
        lineColor=[lineColor colorWithAlphaComponent:self.z];
    }
    
    UIColor *fillColor=[self getDarkenColor:lineColor darkness:0.8];
    
    float left=self.x*(rect.size.width*2)/2;
    float top=self.y*rect.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetBlendMode(context, kCGBlendModeLighten);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    
    float width=3;
    
    CGContextSetLineWidth(context, width);
    
    float lineLeft=left-(rect.size.width/2);

    float lineRight=left+(rect.size.width/2);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, lineLeft, rect.size.height+10.0f);
    CGPathAddLineToPoint(pathRef, NULL, left, rect.size.height-top);
    CGPathAddLineToPoint(pathRef, NULL, lineRight, rect.size.height+10.0f);

    CGContextAddPath(context, pathRef);
    CGContextFillPath(context);
    
    CGContextAddPath(context, pathRef);
    CGContextStrokePath(context);
    
    CGPathRelease(pathRef);
}

-(UIColor *)getRandomColor {
    srand48(arc4random());
    float red = (drand48()/2)+0.5;
    srand48(arc4random());
    float green = (drand48()/2)+0.5;
    srand48(arc4random());
    float blue = (drand48()/2)+0.5;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}


-(UIColor *)getDarkenColor:(UIColor *)color darkness:(float)darkness {
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    float red=components[0];
    float green=components[1];
    float blue=components[2];
    float alpha=CGColorGetAlpha(color.CGColor);
    
    return [UIColor colorWithRed:red*darkness green:green*darkness blue:blue*darkness alpha:alpha];
}

@end
