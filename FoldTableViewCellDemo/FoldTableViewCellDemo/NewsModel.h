//
//  NewsModel.h
//  FoldTableViewCellDemo
//
//  Created by Anchoriter on 2018/1/31.
//  Copyright © 2018年 Anchoriter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsModel : NSObject

/** 新闻内容 */
@property (nonatomic, copy) NSString *desc;
/** 修改时间 */
@property (nonatomic, copy) NSString *pubdate;




/** 是否展开 */
@property (nonatomic, assign) BOOL isOpening;

@end
