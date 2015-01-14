//
//  TKPaginatorView.h
//  TestSwipeWebView
//
//  Created by Toan Le on 27/12/2012.
//  Copyright (c) 2012 Toan Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


typedef enum {
	TKPageViewAnimationNone,
	TKPageViewAnimationTop,
	TKPageViewAnimationBottom
} TKPageViewAnimation;

typedef enum {
	TKPageViewPaginationDirectionHorizontal,
	TKPageViewPaginationDirectionVertical
} TKPageViewPaginationDirection;

@protocol TKPaginatorViewDataSource;
@protocol TKPaginatorViewDelegate;
@class TKPageView;
@class TKPageControl;


@interface TKPaginatorView : UIView

// Configuring
#if defined(__IPHONE_5_0) && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
@property (nonatomic, strong) id<TKPaginatorViewDataSource> dataSource;
@property (nonatomic, strong) id<TKPaginatorViewDelegate> delegate;
#else
@property (nonatomic, unsafe_unretained) id<TKPaginatorViewDataSource> dataSource;
@property (nonatomic, unsafe_unretained) id<TKPaginatorViewDelegate> delegate;
#endif

// UI
@property (nonatomic, strong, readonly) UIScrollView *scrollView;


@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, assign, readonly) NSInteger numberOfPages;
@property (nonatomic, assign) CGFloat pageGapWidth;
@property (nonatomic, assign) NSInteger numberOfPagesToPreload;
@property (nonatomic, assign) CGRect swipeableRect;
@property (nonatomic, assign) TKPageViewPaginationDirection paginationDirection;

- (void)reloadData;
- (void)reloadDataRemovingCurrentPage:(BOOL)removeCurrentPage;
- (void)setCurrentPageIndex:(NSInteger)targetPage animated:(BOOL)animated;
- (CGRect)frameForPageAtIndex:(NSInteger)page;
- (TKPageView *)pageForIndex:(NSInteger)page;
- (TKPageView *)dequeueReusablePageWithIdentifier:(NSString *)identifier;
- (TKPageView *)currentPage;

@end


@protocol TKPaginatorViewDataSource <NSObject>

@required

- (NSInteger)numberOfPagesForPaginatorView:(TKPaginatorView *)paginatorView;
- (TKPageView *)paginatorView:(TKPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex;

@end


@protocol TKPaginatorViewDelegate <NSObject>

@optional

- (void)paginatorViewDidBeginPaging:(TKPaginatorView *)paginatorView;
- (void)paginatorView:(TKPaginatorView *)paginatorView willDisplayView:(UIView *)view atIndex:(NSInteger)pageIndex;
- (void)paginatorView:(TKPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex;

@end
