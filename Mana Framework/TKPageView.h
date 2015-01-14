//
//  TKPageView.h
//  TestSwipeWebView
//
//  Created by Toan Le on 27/12/2012.
//  Copyright (c) 2012 Toan Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKPageView : UIView

@property (nonatomic, strong, readonly) NSString *reuseIdentifier;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)prepareForReuse;

@end
