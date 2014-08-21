//
//  RCPictureCellContentView.m
//  Message
//
//  Created by xuzepei on 8/5/14.
//  Copyright (c) 2014 TapGuilt Inc. All rights reserved.
//

#import "RCPictureCellContentView.h"
#import "RCImageLoader.h"
#import "Item.h"


#define LINE_COLOR [RCTool colorWithHex:0xdbe0e4]
#define TEXT_COLOR [RCTool colorWithHex:0x000000]
#define FONT_SIZE 15
#define BUTTON_RECT CGRectMake(220,self.bounds.size.height - 36,89,29)
#define BLUE_TEXT_COLOR [RCTool colorWithHex:0x02a3f1]

@implementation RCPictureCellContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGSize)getFitImageSize:(CGSize)size
{
    CGFloat offset_width = 8.0f;
    CGFloat image_height = 160.0f;
    
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    if(size.width >= size.height)
    {
        while (width > ([RCTool getScreenSize].width - offset_width*4) || height > image_height){
            
            width--;
            
            height = size.height*width/size.width;
        }
    }
    else
    {
        while (width > ([RCTool getScreenSize].width - offset_width*4) || height > image_height){
            
            height--;
            
            width = size.width*height/size.height;
        }
    }
    
    return CGSizeMake(width, height);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(nil == self.item)
        return;
    
    Item* item0 = (Item*)self.item;
    
    if([RCTool isIpad])
    {
        CGFloat offset_x = 20.0f;
        CGFloat offset_y = 20.0f;
        
        if(self.image)
        {
            [self.image drawInRect:CGRectMake(offset_x, offset_y, 100, 100)];
        }
        
        offset_y += 4.0;
        [TEXT_COLOR set];
        NSString* text = item0.text;
        if([text length])
        {
            [text drawInRect:CGRectMake(offset_x*2 + 100, offset_y, [RCTool getScreenSize].width -(offset_x*3 + 100), 60) withFont:[UIFont systemFontOfSize:22] lineBreakMode:NSLineBreakByTruncatingTail];
        }
        
        [[RCTool colorWithHex:0x818181] set];
        offset_y = 100.0f;
        NSString* name = item0.name;
        if([name length])
        {
            [name drawInRect:CGRectMake(offset_x*2 + 100, offset_y, ([RCTool getScreenSize].width - (offset_x*2 + 100))/2.0, 20) withFont:[UIFont systemFontOfSize:18] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
        }
        
        NSString* shareCount = item0.sharecount;
        if([shareCount length])
        {
            UIImage* image = [UIImage imageNamed:@"post"];
            if(image)
            {
                [image drawInRect:CGRectMake(offset_x*2 + 100+ ([RCTool getScreenSize].width - (offset_x*2 + 100))/2.0, offset_y + 2, 18, 18)];
            }
            [shareCount drawInRect:CGRectMake(offset_x*2 + 100+ ([RCTool getScreenSize].width - (offset_x*2 + 100))/2.0 + 30, offset_y, ([RCTool getScreenSize].width - (offset_x*2 + 100))/2.0, 20) withFont:[UIFont systemFontOfSize:18] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
        }
    }
    else
    {
        CGFloat offset_x = 10.0f;
        CGFloat offset_y = 10.0f;
        
        if(self.image)
        {
            [self.image drawInRect:CGRectMake(offset_x, offset_y, 60, 60)];
        }
        
        [TEXT_COLOR set];
        NSString* text = [NSString stringWithFormat:@"%@%@%@%@",item0.text,item0.text,item0.text,item0.text];;
        if([text length])
        {
            [text drawInRect:CGRectMake(offset_x*2 + 60, offset_y-2, [RCTool getScreenSize].width -(offset_x*3 + 60), 50) withFont:[UIFont systemFontOfSize:17] lineBreakMode:NSLineBreakByTruncatingTail];
        }
        
        [[RCTool colorWithHex:0x818181] set];
        offset_y = 56.0f;
        NSString* name = item0.name;
        if([name length])
        {
            [name drawInRect:CGRectMake(offset_x*2 + 60, offset_y, ([RCTool getScreenSize].width - (offset_x*2 + 60))/2.0, 20) withFont:[UIFont systemFontOfSize:13] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
        }
        
        NSString* shareCount = item0.sharecount;
        if([shareCount length])
        {
            UIImage* image = [UIImage imageNamed:@"post"];
            if(image)
            {
                [image drawInRect:CGRectMake(offset_x*2 + 100+ ([RCTool getScreenSize].width - (offset_x*2 + 100))/2.0, offset_y+2, 14, 14)];
            }
            [shareCount drawInRect:CGRectMake(offset_x*2 + 100+ ([RCTool getScreenSize].width - (offset_x*2 + 100))/2.0 + 26, offset_y, ([RCTool getScreenSize].width - (offset_x*2 + 100))/2.0, 20) withFont:[UIFont systemFontOfSize:13] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
        }
    }

}

- (void)updateContent:(id)item delegate:(id)delegate token:(NSDictionary*)token
{
    [super updateContent:item delegate:delegate token:token];

    Item* item0 = (Item*)item;
    
    self.image = [UIImage imageNamed:@"pic_default"];
    self.imageUrl = item0.imgurl;

    if([self.imageUrl length])
    {
        UIImage* image = [RCTool getImageFromLocal:self.imageUrl];
        if(image)
            self.image = image;
        else
        {
            [[RCImageLoader sharedInstance] saveImage:self.imageUrl
                                             delegate:self
                                                token:nil];
        }
    }
  
    [self setNeedsDisplay];
}

- (void)succeedLoad:(id)result token:(id)token
{
	NSDictionary* dict = (NSDictionary*)result;
	NSString* urlString = [dict valueForKey: @"url"];
    
	if([urlString isEqualToString: self.imageUrl])
	{
		self.image = [RCTool getImageFromLocal:self.imageUrl];
		[self setNeedsDisplay];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

@end
