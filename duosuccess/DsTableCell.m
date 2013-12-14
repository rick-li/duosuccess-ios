//
//  DsTableCell.m
//  duosuccess
//
//  Created by Rick Li on 12/11/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsTableCell.h"
#import "UIImage+iPhone5.h"

@implementation DsTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if(selected)
    {
//        UIImage* bg = [UIImage tallImageNamed:@"ipad-list-item-selected.png"];
//        UIImage* disclosureImage = [UIImage tallImageNamed:@"ipad-arrow-selected.png"];
//        
//        [bgImageView setImage:bg];
//        [disclosureImageView setImage:disclosureImage];
//        
//        [titleLabel setTextColor:[UIColor whiteColor]];
//        [titleLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];
//        [titleLabel setShadowOffset:CGSizeMake(0, -1)];
//        
//        
//        [textLabel setTextColor:[UIColor whiteColor]];
//        [textLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];
//        [textLabel setShadowOffset:CGSizeMake(0, -1)];
        
    }
    else
    {
//        UIImage* bg = [UIImage tallImageNamed:@"ipad-list-element.png"];
//        UIImage* disclosureImage = [UIImage tallImageNamed:@"ipad-arrow.png"];
//        
//        [bgImageView setImage:bg];
//        [disclosureImageView setImage:disclosureImage];
//        
//        [titleLabel setTextColor:[UIColor colorWithRed:0.0 green:68.0/255 blue:118.0/255 alpha:1.0]];
//        [titleLabel setShadowColor:[UIColor whiteColor]];
//        [titleLabel setShadowOffset:CGSizeMake(0, 1)];
//        
//        
//        [textLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
//        [textLabel setShadowColor:[UIColor whiteColor]];
//        [textLabel setShadowOffset:CGSizeMake(0, 1)];
        
    }
    
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
