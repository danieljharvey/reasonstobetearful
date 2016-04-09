//
//  FPAVisualiser.h
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 08/04/2016.
//  Copyright © 2016 Daniel Harvey. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FPAMainViewController;

// basically we send it a list of percentage values and it plots them on screen with dots

@interface FPAVisualiser : UIView

@property (nonatomic, weak) FPAMainViewController * mvc;
@property (nonatomic) NSUInteger visualNumber;
@property (nonatomic) float x; // left
@property (nonatomic) float y; // top
@property (nonatomic) float z; // opacity
@property (nonatomic, strong) UIColor * drawColor;

-(id)initWithViewController:(FPAMainViewController *)viewController visualNumber:(NSUInteger)visualNumber;
-(UIColor *)getRandomColor;
-(UIColor *)getDarkenColor:(UIColor *)color darkness:(float)darkness;

@end
