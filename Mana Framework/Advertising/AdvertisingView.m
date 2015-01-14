//
//  AdvertisingView.m
//  AdvertisingViewDemo
//
//  Created by Levey on 2/21/12.
//  Copyright (c) 2012 Levey. All rights reserved.
//

#import "AdvertisingView.h"

#define POPLISTVIEW_SCREENINSET 40.
#define POPLISTVIEW_HEADER_HEIGHT 50.
#define RADIUS 5.
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

@interface AdvertisingView (private)
- (void)fadeIn;
- (void)fadeOut;
@end

@implementation AdvertisingView {
    NSString *_title;
    NSString *_appStore;
    UIScrollView *_imageScroll;
}

#pragma mark - initialization & cleaning up
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions andDescription:(NSString*)desc {
    CGRect rect = [[UIScreen mainScreen] applicationFrame]; // portrait bounds
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        rect.size = CGSizeMake(rect.size.height, rect.size.width);
    }
    if (self = [super initWithFrame:rect]) {
        self.backgroundColor = [UIColor clearColor];
        _title = [aTitle copy];
        CGFloat height = (rect.size.width - 2 * POPLISTVIEW_SCREENINSET)*0.75f;
        if (IS_IPHONE5) {
            height = (rect.size.width - 2 * POPLISTVIEW_SCREENINSET);
        }
        _imageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(POPLISTVIEW_SCREENINSET,
                                                                     POPLISTVIEW_SCREENINSET + POPLISTVIEW_HEADER_HEIGHT + 5.0,
                                                                     (rect.size.width - 2 * POPLISTVIEW_SCREENINSET),
                                                                     height)];
        _imageScroll.showsHorizontalScrollIndicator = YES;
        _imageScroll.scrollEnabled = YES;
        _imageScroll.userInteractionEnabled = YES;
        _imageScroll.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreeToTryApp)];
        [_imageScroll addGestureRecognizer:tap];
        [self addSubview:_imageScroll];
        CGFloat scrollWidth = 0.0f;
        for (UIImage *someImage in aOptions) {
            UIImageView *theView = [[UIImageView alloc] initWithFrame:
                                    CGRectMake(scrollWidth, 0, _imageScroll.frame.size.width, _imageScroll.frame.size.height)];
            theView.image = someImage;
            
            theView.contentMode = UIViewContentModeScaleAspectFit;
            [_imageScroll addSubview:theView];
            scrollWidth += _imageScroll.frame.size.width*0.6f;
        }
        scrollWidth += _imageScroll.frame.size.width*0.4f;
        _imageScroll.contentSize = CGSizeMake(scrollWidth, _imageScroll.frame.size.height);
        UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(_imageScroll.frame.origin.x + 20.0, _imageScroll.frame.origin.y +  _imageScroll.frame.size.height, 200.0, 50.0)];
        description.text = desc;
        description.textAlignment = NSTextAlignmentLeft;
        description.tag = 10;
        description.backgroundColor = [UIColor clearColor];
        description.lineBreakMode = YES;
        description.numberOfLines = 3;
        description.font = [UIFont systemFontOfSize:12.];
        description.textColor = [UIColor whiteColor];
        [self addSubview:description];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self
                   action:@selector(agreeToTryApp)
         forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitle:@"Try it!" forState:UIControlStateNormal];
        button.frame = CGRectMake(description.frame.origin.x, description.frame.origin.y +  description.frame.size.height + 10.0f, 200.0, 35.0);
        [self addSubview:button];
        
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button2 addTarget:self
                   action:@selector(noAgreeToTryApp)
         forControlEvents:UIControlEventTouchUpInside];
        button2.backgroundColor = [UIColor whiteColor];
        [button2 setTitle:@"No thanks!" forState:UIControlStateNormal];
        button2.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y +  40.0f, 200.0, 35.0);
        [self addSubview:button2];
    }
    return self;    
}

- (id)initWithTitle:(NSString *)aTitle
            options:(NSArray *)aOptions andDescription:(NSString*)desc handler:(void (^)(NSInteger))aHandlerBlock {
    
    if(self = [self initWithTitle:aTitle options:aOptions andDescription:desc])
        self.handlerBlock = aHandlerBlock;
    
    return self;
}

//Tam Tran
//add place to Favorites
- (void)agreeToTryApp{
    if ([_delegate respondsToSelector:@selector(agreeToTryApp:)]){
        [_delegate agreeToTryApp:self.appstore];
    }
    [self fadeOut];
}

//Tam Tran
//take screen shoot
- (void)noAgreeToTryApp{
    if ([_delegate respondsToSelector:@selector(noAgreeToTryApp:)]){
        [_delegate noAgreeToTryApp:1];
    }
    [self fadeOut];
}
#pragma mark - Private Methods
- (void)fadeIn {
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];

}

- (void) orientationDidChange: (NSNotification *) not {
    CGRect rect = [[UIScreen mainScreen] applicationFrame]; // portrait bounds
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        rect.size = CGSizeMake(rect.size.height, rect.size.width);
    }
    [self setFrame:rect];
    [self setNeedsDisplay];
}

- (void)fadeOut {
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                          selector: @selector(orientationDidChange:)
                                          name: UIApplicationDidChangeStatusBarOrientationNotification
                                          object: nil];
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}
#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // tell the delegate the cancellation
    if ([_delegate respondsToSelector:@selector(AdvertisingViewDidCancel)])
        [_delegate AdvertisingViewDidCancel];
    
    // dismiss self
//    [self fadeOut];
}

#pragma mark - DrawDrawDraw
- (void)drawRect:(CGRect)rect {
    CGRect bgRect = CGRectInset(rect, POPLISTVIEW_SCREENINSET, POPLISTVIEW_SCREENINSET);
    CGRect titleRect = CGRectMake(POPLISTVIEW_SCREENINSET + 10, POPLISTVIEW_SCREENINSET + 5.0,
                                  rect.size.width -  2 * (POPLISTVIEW_SCREENINSET + 10), 60);
    CGRect separatorRect = CGRectMake(POPLISTVIEW_SCREENINSET, POPLISTVIEW_SCREENINSET + POPLISTVIEW_HEADER_HEIGHT - 2,
                                      rect.size.width - 2 * POPLISTVIEW_SCREENINSET, 2);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw the background with shadow
    CGContextSetShadowWithColor(ctx, CGSizeZero, 6., [UIColor colorWithWhite:0 alpha:.75].CGColor);
    [[UIColor colorWithWhite:0 alpha:.75] setFill];
    
    
    float x = POPLISTVIEW_SCREENINSET;
    float y = POPLISTVIEW_SCREENINSET;
    float width = bgRect.size.width;
    float height = bgRect.size.height;
    CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, x, y + RADIUS);
	CGPathAddArcToPoint(path, NULL, x, y, x + RADIUS, y, RADIUS);
	CGPathAddArcToPoint(path, NULL, x + width, y, x + width, y + RADIUS, RADIUS);
	CGPathAddArcToPoint(path, NULL, x + width, y + height, x + width - RADIUS, y + height, RADIUS);
	CGPathAddArcToPoint(path, NULL, x, y + height, x, y + height - RADIUS, RADIUS);
	CGPathCloseSubpath(path);
	CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGPathRelease(path);
    
    // Draw the title and the separator with shadow
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0.5f, [UIColor blackColor].CGColor);
    [[UIColor colorWithRed:0.020 green:0.549 blue:0.961 alpha:1.] setFill];
    [_title drawInRect:titleRect withFont:[UIFont systemFontOfSize:15.]];
    CGContextFillRect(ctx, separatorRect);
}

@end
