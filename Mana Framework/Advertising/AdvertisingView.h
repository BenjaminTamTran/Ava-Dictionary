//
//  AdvertisingView.h
//  AdvertisingViewDemo
//
//  Created by Levey on 2/21/12.
//  Copyright (c) 2012 Levey. All rights reserved.
//

@protocol AdvertisingViewDelegate;
@interface AdvertisingView : UIView

@property (nonatomic, strong) id<AdvertisingViewDelegate> delegate;
@property (nonatomic, strong) NSString *appstore;
@property (copy, nonatomic) void(^handlerBlock)(NSInteger anIndex);

// The options is a NSArray, contain some NSDictionaries, the NSDictionary contain 2 keys, one is "img", another is "text".
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions andDescription:(NSString*)desc;
- (id)initWithTitle:(NSString *)aTitle 
            options:(NSArray *)aOptions andDescription:(NSString*)desc handler:(void (^)(NSInteger))aHandlerBlock;

// If animated is YES, PopListView will be appeared with FadeIn effect.
- (void)showInView:(UIView *)aView animated:(BOOL)animated;
@end

@protocol AdvertisingViewDelegate <NSObject>
@optional
- (void)AdvertisingViewDidCancel;
- (void)agreeToTryApp:(NSString*)url;
- (void)noAgreeToTryApp:(int)type;
@end