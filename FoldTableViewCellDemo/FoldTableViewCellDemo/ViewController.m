//
//  ViewController.m
//  FoldTableViewCellDemo
//
//  Created by Anchoriter on 2018/1/31.
//  Copyright © 2018年 Anchoriter. All rights reserved.
//

#import "ViewController.h"
#import "NewsCell.h"
#import "NewsModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <YYModel/YYModel.h>

static NSString *NewsCellIdentifier = @"newsCellIdentifier";

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,NewsCellCellDelegate>

@property (nonatomic, strong) UITableView *newsTableView;

@property (nonatomic, strong) NSArray *newsDataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0];
    
    // 添加视图
    [self setSubViews];
    
    [self loadData];
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        self.newsTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
#endif
    
}
-(void)setSubViews{
    
    self.newsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.newsTableView.delegate = self;
    self.newsTableView.dataSource = self;
    self.newsTableView.estimatedRowHeight = 0;
    self.newsTableView.estimatedSectionHeaderHeight = 0;
    self.newsTableView.estimatedSectionFooterHeight = 0;
    [self.newsTableView registerClass:[NewsCell class] forCellReuseIdentifier:NewsCellIdentifier];
    [self.view addSubview:self.newsTableView];
}
-(void)loadData{
    
    NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"newsData" ofType:@"json"]];
    // YYModel字典转模型
    self.newsDataArray = [NSArray yy_modelArrayWithClass:[NewsModel class] json:jsonData];
}




-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.newsDataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NewsCell *newsCell = [tableView dequeueReusableCellWithIdentifier:NewsCellIdentifier];
    if (!newsCell) {
        newsCell = [[NewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NewsCellIdentifier];
    }
    newsCell.selectionStyle = UITableViewCellSelectionStyleNone;
    newsCell.cellDelegate = self;
    
    NewsModel *model = self.newsDataArray[indexPath.row];
    newsCell.newsModel = model;
    
    return newsCell;
}
#pragma mark - 折叠按钮点击代理
/**
 *  折叠按钮点击代理
 *
 *  @param cell 按钮所属cell
 */
-(void)clickFoldLabel:(NewsCell *)cell{
    
    NSIndexPath * indexPath = [self.newsTableView indexPathForCell:cell];
     NewsModel *model = self.newsDataArray[indexPath.row];
    
    model.isOpening = !model.isOpening;
    [self.newsTableView beginUpdates];
    [self.newsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.newsTableView endUpdates];
}
/**
 *  设置cell高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.newsDataArray.count > 0)
    {
        NewsModel *model = [self.newsDataArray objectAtIndex:indexPath.row];
        // 动态计算cell高度
        // 这里使用了forkingdog的框架
        // https://github.com/forkingdog/UITableView-FDTemplateLayoutCell
        // UITableView+FDTemplateLayoutCell这个分类牛逼的地方就在于自动计算行高了
        // 如果我们在没有缓存的情况下，只要你使用了它其实高度的计算不需要我们来管，我们只需要[self.tableView reloadData]就完全足够了
        // 但是如果有缓存的时候，这个问题就来了，你会发现，点击展开布局会乱，有一部分会看不到，这是因为高度并没有变化，一直用的是缓存的高度，所以解决办法如下
        
        
        if (model.isOpening) {
            // 使用不缓存的方式
            return [self.newsTableView fd_heightForCellWithIdentifier:NewsCellIdentifier configuration:^(id cell) {
                
                [self handleCellHeightWithNewsCell:cell indexPath:indexPath];
            }];
        }else{
            // 使用缓存的方式
            return [self.newsTableView fd_heightForCellWithIdentifier:NewsCellIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
                
                [self handleCellHeightWithNewsCell:cell indexPath:indexPath];
            }];
        }
    } else{
        
        return 10;
    }
}

/**
 处理cell高度
 */
-(void)handleCellHeightWithNewsCell:(id)cell indexPath:(NSIndexPath *)indexPath{
    NewsCell *newsCell = (NewsCell *)cell;
    newsCell.newsModel = self.newsDataArray[indexPath.row];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
@end















