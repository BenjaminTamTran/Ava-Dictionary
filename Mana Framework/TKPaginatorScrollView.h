//
//  TKPaginatorScrollView.h
//  TestSwipeWebView
//
//  Created by Toan Le on 27/12/2012.
//  Copyright (c) 2012 Toan Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKPaginatorScrollView : UIScrollView

#if defined(__IPHONE_5_0) && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
@property (nonatomic, weak) id<UIScrollViewDelegate> privateDelegate;
#else
@property (nonatomic, unsafe_unretained) id<UIScrollViewDelegate> privateDelegate;
#endif

@end
