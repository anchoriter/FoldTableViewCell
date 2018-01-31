//
//  NewsCell.m
//  FoldTableViewCellDemo
//
//  Created by Anchoriter on 2018/1/31.
//  Copyright © 2018年 Anchoriter. All rights reserved.
//

#import "NewsCell.h"
#import "Masonry.h"
#import "NewsModel.h"

@interface NewsCell()

@property (nonatomic, strong) UILabel *newsText;        // 新闻文本
@property (nonatomic, strong) UILabel *foldLabel;       // 展开按钮
@property (nonatomic, strong) UILabel *newsDate;        // 日期
@property (nonatomic, strong) UIView *bottomSpaceView;  // 底部分割线

@end

@implementation NewsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.clipsToBounds = YES;
        [self setupUI];
    }
    return self;
}
- (void)setupUI
{

    [self.contentView addSubview:self.newsText];
    [self.contentView addSubview:self.newsDate];
    [self.contentView addSubview:self.foldLabel];
    [self.contentView addSubview:self.bottomSpaceView];
    
    [self.newsText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(16);
        make.right.mas_equalTo(-10);
    }];

    self.newsText.preferredMaxLayoutWidth = SCREEN_WIDTH-10-10-1;
    
    [self.newsDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.newsText.mas_bottom).offset(12);
        make.right.mas_equalTo(-10);
        make.width.mas_equalTo(85);
//        make.height.mas_equalTo(20);
    }];
    
    [self.bottomSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.newsDate.mas_bottom).mas_offset(10);
        make.left.mas_equalTo(self.newsText.mas_left);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(0);
    }];
    
    [self.foldLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.newsText.mas_left);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(44);
        make.centerY.mas_equalTo(self.newsDate.mas_centerY);
    }];
}
-(void)setNewsModel:(NewsModel *)newsModel{
    _newsModel = newsModel;
    
    self.newsText.text = newsModel.desc;
    // 可以在这里修改行间距，下面在计算文本高度的时候也要对应设置
    // 如果不需要修改，可以省去这一步，但注意下面获取高度的时候不要再设置行间距
    if (self.newsText.text.length > 0) {
        NSMutableAttributedString *img_text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", newsModel.desc]];

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:3];
        [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        [img_text addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.newsText.text.length)];

        self.newsText.attributedText = img_text;
    }
    // 获取文本内容宽度，计算展示全部文本所需高度
    CGFloat contentW = SCREEN_WIDTH-2*10 ;
    NSString *contentStr = self.newsText.text;
    
    NSMutableParagraphStyle *descStyle = [[NSMutableParagraphStyle alloc]init];
    [descStyle setLineSpacing:3];//行间距
    
    CGRect textRect = [contentStr
                       boundingRectWithSize:CGSizeMake(contentW, MAXFLOAT)
                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                       attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0f], NSParagraphStyleAttributeName : descStyle}
                       context:nil];
    // 这里的高度60是通过指定显示三行文字时，通过打印得到的一个临界值，根据需要自行修改
    // 超过三行文字，折叠按钮不显示
    if (textRect.size.height > 60) {
        
        self.foldLabel.hidden = NO;
        // 修改按钮的折叠打开状态
        if (newsModel.isOpening) {

            self.newsText.numberOfLines = 0;
            self.foldLabel.text = @"收起";
        }else{
            
            self.newsText.numberOfLines = 3;
            self.foldLabel.text = @"展开";
        }
    }else{
        
        self.newsText.numberOfLines = 0;
        self.foldLabel.hidden = YES;
    }
    
    NSTimeInterval time = [newsModel.pubdate doubleValue];
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSString *dateStr = [dateFormatter stringFromDate:detaildate];
    if (dateStr.length > 0) {
        //日期
        self.newsDate.text = [dateStr substringWithRange:NSMakeRange(0, 10)];
    }
    
    
}

#pragma mark - Gesture
/**
 *  折叠展开按钮的点击事件
 *
 *  @param recognizer 点击手势
 */
- (void)foldNewsOrNoTap:(UITapGestureRecognizer *)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateEnded){
        
        if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(clickFoldLabel:)]) {
            
            [self.cellDelegate clickFoldLabel:self];
        }
    }
}

#pragma mark - lazy
-(UILabel *)foldLabel{
    if (!_foldLabel) {
        _foldLabel = [[UILabel alloc] init];
        _foldLabel.font = [UIFont systemFontOfSize:14.f];
        _foldLabel.textColor = [UIColor redColor];
        _foldLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *foldTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foldNewsOrNoTap:)];
        [_foldLabel addGestureRecognizer:foldTap];
        _foldLabel.hidden = YES;
        
        [_foldLabel sizeToFit];
    }
    return _foldLabel;
}
- (UIView *)bottomSpaceView
{
    if (nil == _bottomSpaceView)
    {
        _bottomSpaceView = [[UIView alloc] init];
        _bottomSpaceView.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1];
    }
    return _bottomSpaceView;
}

//日期
- (UILabel *)newsDate
{
    if (nil == _newsDate)
    {
        _newsDate = [[UILabel alloc] init];
        _newsDate.textColor = [UIColor blackColor];
        _newsDate.font = [UIFont systemFontOfSize:12.f];
        _newsDate.textAlignment = NSTextAlignmentRight;
        _newsDate.numberOfLines = 1;
    }
    
    return _newsDate;
}
//新闻文本
- (UILabel *)newsText
{
    if (nil == _newsText)
    {
        _newsText = [[UILabel alloc] init];
        _newsText.textColor = [UIColor blackColor];
        _newsText.font = [UIFont systemFontOfSize:18.0f];
    }
    
    return _newsText;
}

@end






















