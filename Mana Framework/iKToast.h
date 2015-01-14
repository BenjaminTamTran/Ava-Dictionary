//
//  iKToast.h
//  testToast
//
//  Created by Firstiar Noorwinanto on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    iKToastPositionTop,
    iKToastPositionBottom,
    iKToastPositionMiddle
} iKToastPosition;

@interface iKToast : NSObject {
    NSMutableArray *stack;
    NSInteger duration;
    CGFloat distance;
    iKToastPosition position;
    BOOL stacked;
    CGRect showFrame;
    CGRect hideFrame;
}

@property (retain) NSMutableArray *stack;
@property (assign) NSInteger duration;
@property (assign) CGFloat distance;
@property (assign) iKToastPosition position;
@property (assign) BOOL stacked;

-(void)addToast:(UIView*)toastItem;
-(void)removeToast:(UIView*)toastItem;
-(void)removeFirstToast;
-(NSInteger)toastCount;

-(void)showToastMessage:(NSString*)message;
-(void)showToastView:(UIView*)toastView;

+(iKToast*)sharedInstance;

+(void)showToastWithString:(NSString*)message duration:(CGFloat)duration withDistance:(CGFloat)distance inPosition:(iKToastPosition)position;
+(void)showToastWithView:(UIView*)view duration:(CGFloat)duration withDistance:(CGFloat)distance inPosition:(iKToastPosition)position;

+(UIView*)getMessageView:(NSString*)message;

@end
