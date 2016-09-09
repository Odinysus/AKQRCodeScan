//
//  ViewController.m
//  QRCodeScane
//
//  Created by qiang on 9/6/16.
//  Copyright © 2016 akite. All rights reserved.
//

#import "ViewController.h"
#import "AKCodeViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"scan detected two-dimensional tabcode";
    }
    return cell;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        AKCodeViewController *codeViewController = [[AKCodeViewController alloc] init];
        codeViewController.codeBlock = ^(NSString *value){
            NSLog(@"the qrcode is %@", value);
        };
        [self presentViewController:codeViewController animated:YES completion:nil];
    
}
@end
