//
//  SingleTopicListViewController_IPad.h
//  JingYingCar
//
//  Created by JiaMing Yan on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate_IPad.h"

@interface SingleTopicListViewController_IPad : UIViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    NSInteger type;
    
    NSMutableArray *arr_topicList;
    
    UITableView *tbl_topicList;
    
    BOOL isGettingBefore;
    BOOL isGettingLater;
    
    UIActivityIndicatorView *indViewLarge;
    
    NSMutableArray *arr_requests;
}

@property (nonatomic) NSInteger type;

@end
