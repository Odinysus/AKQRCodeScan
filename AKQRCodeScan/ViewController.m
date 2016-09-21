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
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"scan qrcode from capture and image";
    }
    return cell;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        AKCodeViewController *codeViewController = [[AKCodeViewController alloc] init];
        codeViewController.codeBlock = ^(NSString *value){
            NSLog(@"the qrcode is %@", value);
        };
        [self presentViewController:codeViewController animated:YES completion:nil];
    } else if (indexPath.row == 1) {
        
        AKCodeViewController *codeViewController = [[AKCodeViewController alloc] init];
        codeViewController.codeBlock = ^(NSString *value){
            NSLog(@"the qrcode is %@", value);
        };
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:codeViewController];
        // bar buton
        [self presentViewController:nav animated:YES completion:nil];
    }
    
}
@end
