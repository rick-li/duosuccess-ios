//
//  DsPaperController.m
//  duosuccess
//
//  Created by Rick Li on 12/13/13.
//  Copyright (c) 2013 Rick Li. All rights reserved.
//

#import "DsPaperController.h"
#import "DsFileStore.h"
#import "DsEventStore.h"
#import "UIImage+iPhone5.h"

@interface DsPaperController ()

@end

@implementation DsPaperController

@synthesize paperView;
@synthesize remainLabel;
@synthesize remainContainer;

DsFileStore *fileStore;
DsEventStore *eventStore;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    remainContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dtabbar.png"]];
	// Do any additional setup after loading the view.
    fileStore = [DsFileStore sharedInstance];
    eventStore = [DsEventStore sharedInstance];
    
    NSString *imageFileUrl = fileStore.imageFileUrl;
    self.paperView.image = [UIImage imageWithContentsOfFile:imageFileUrl];
    
    
    UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"trash"] style:UIBarButtonItemStylePlain target:self action:@selector(deletePaper)];
    
    
    self.navigationItem.rightBarButtonItem = trashButton;
    NSDictionary *prefDict = [[NSUserDefaults standardUserDefaults] objectForKey:eventStore.paperPrefKey];
    NSDate *now = [NSDate date];
    NSDate *dueDate = [prefDict valueForKey:eventStore.paperDateKey];
    if(!dueDate){
        NSLog(@"Unexpected, delete current paper.");
        [fileStore removePaperImage];
        [[DsEventStore sharedInstance] removePaperReminder];
        [self.navigationController popViewControllerAnimated:true];
        return;
    }
    
    if([dueDate compare:now] == NSOrderedAscending){
        self.remainLabel.text = NSLocalizedString(@"energyPaperExpired", "");
    }else{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle= kCFDateFormatterShortStyle;
        formatter.timeStyle = kCFDateFormatterMediumStyle;
        self.remainLabel.text = [NSLocalizedString(@"willExpireAt", @"Will expire at: ") stringByAppendingString:[formatter stringFromDate:dueDate]];
    }

    self.title = NSLocalizedString(@"myPaper", @"My Paper");
}

-(void) deletePaper{
    NSLog(@"Delete paper is clicked.");
    
    
    UIAlertView *checkAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirmEnergyPaper", @"energy paper") message:NSLocalizedString(@"energyPaperRemoved", @"energy Paper Removed") delegate:(self) cancelButtonTitle: NSLocalizedString(@"no","") otherButtonTitles:NSLocalizedString(@"yes",""), nil];
    checkAlert.tag = 0;
    
    [checkAlert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 0){
        if(buttonIndex == 1){
            [fileStore removePaperImage];
            [[DsEventStore sharedInstance] removePaperReminder];
            UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"energyPaper", @"energy paper") message:NSLocalizedString(@"energyPaperRemoved", @"energy Paper Removed") delegate:(self) cancelButtonTitle:@"OK" otherButtonTitles:nil];
            confirmAlert.tag = 1;
            
            [confirmAlert show];
        }
    }else if(alertView.tag == 1){
        
        [self.navigationController popViewControllerAnimated:true];
        
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:true];
    
}

@end
