//
//  AdvertisingViewiPad.h
//  AdvertisingViewiPadDemo
//
//  Created by Levey on 2/21/12.
//  Copyright (c) 2012 Levey. All rights reserved.
//

@protocol AdvertisingViewiPadDelegate;
@interface AdvertisingViewiPad : UIView

@property (nonatomic, strong) id<AdvertisingViewiPadDelegate> delegate;
@property (nonatomic, strong) NSString *appstore;
@property (copy, nonatomic) void(^handlerBlock)(NSInteger anIndex);

// The options is a NSArray, contain some NSDictionaries, the NSDictionary contain 2 keys, one is "img", another is "text".
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions andDescription:(NSString*)desc;
- (id)initWithTitle:(NSString *)aTitle 
            options:(NSArray *)aOptions andDescription:(NSString*)desc handler:(void (^)(NSInteger))aHandlerBlock;

// If animated is YES, PopListView will be appeared with FadeIn effect.
- (void)showInView:(UIView *)aView animated:(BOOL)animated;
@end

@protocol AdvertisingViewiPadDelegate <NSObject>
@optional
- (void)AdvertisingViewiPadDidCancel;
- (void)agreeToTryApp:(NSString*)url;
- (void)noAgreeToTryApp:(int)type;
@end