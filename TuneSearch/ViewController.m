//
//  ViewController.m
//  TuneSearch
//
//  Created by Jack Borthwick on 6/15/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import "ViewController.h"
#import "ItemTableViewCell.h"
#import "ItunesItems.h"
@interface ViewController ()

@property (nonatomic, strong) Reachability          *hostReach;
@property (nonatomic, strong) Reachability          *internetReach;
@property (nonatomic, strong) Reachability          *wifiReach;
@property (nonatomic, strong) NSString              *searchTerm;
@property (nonatomic, strong) IBOutlet UITextField  *searchField;
@property (nonatomic, strong) NSString              *hostName;
@property (nonatomic, strong) NSMutableArray        *itunesItemArray;

@end

@implementation ViewController

BOOL internetAvailable;
BOOL serverAvailable;

#pragma mark - sharing methods

- (IBAction)shareButtonPressed:(id)sender {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:@[@"I was searching %@ and I thought you might enjoy it as well",_searchField.text] applicationActivities:nil];
    [self presentViewController:activityVC animated:true completion:nil];
}

#pragma mark - Interactivity Methods



- (IBAction)downloadFileText:(id)sender {
    NSLog(@"download text pressed");
    if(serverAvailable){
        _itunesItemArray = [[NSMutableArray alloc]init];
        _searchTerm = _searchField.text;
        NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/search?term=%@",_hostName, _searchTerm]];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:fileURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
        [NSURLConnection sendAsynchronousRequest: urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (([data length] > 0) && (error == nil)) {
                NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"Got Data: %@",dataString);
                NSError *jsonError = nil;
                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                _itemArray = [(NSDictionary *) json objectForKey:@"results"];//create an array of dictionary items to read the array of dictionary items from the json
                //NSLog(@"THIS MANY ARTISTS  %li",_itemArray.count);
                if (_itemArray.count >0) {
                    int x = 0;
                    for (ItunesItems *itunesItem in _itemArray) {
                        ItunesItems *newItem = [[ItunesItems alloc] init];
                        newItem.itemName = [(NSDictionary *) itunesItem objectForKey:@"artistName"];
                        newItem.itemImageURL = [(NSDictionary *) itunesItem objectForKey:@"artworkUrl30"];
                        newItem.itemID = [(NSDictionary *) itunesItem objectForKey:@"artistId"];
                        newItem.otherItemID = [(NSDictionary *) itunesItem objectForKey:@"trackId"];
                        [_itunesItemArray addObject:newItem];
                        NSLog(@"now this many in itunes array %li",_itunesItemArray.count);
                        if ([self fileIsLocal:newItem.itemImageURL]) {
                            NSLog(@"found %@",newItem.itemImageURL);
                        }
                        else {
                            NSLog(@"not found %@",newItem.itemImageURL);
                            NSURL *tmpURL = [[NSURL alloc] initWithString:newItem.itemImageURL];
                            NSString *fileName = [NSString stringWithFormat:@"%@%@", [newItem itemID],[newItem otherItemID]];
                            [self getImageFromServer:fileName fromURL:newItem.itemImageURL];
                        }
                        x++;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_itemTableView reloadData];
                });
            } else if (([data length] == 0) && (error == nil)) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"No Data Found" message:@"It looks like we weren't able to find a file" delegate:self
                                      cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            } else if (error.code == -1009) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Internet Disabled" message:@"It looks like your device may not be connected to the Internet. Please make sure the Internet is on and try the update again." delegate:self
                                      cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            } else if (error != nil) {
                NSLog(@"Error = %@", error);
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Unknown Error" message:[NSString stringWithFormat:@"An error has occured. Please contact support. Error %@",error] delegate:self
                                      cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }

        }];
    }
    else {
        UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"NO INTERNET" message:@"NO INTERNET" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:nil, nil];
        [noInternetAlert show];
    }
}

- (void)getImageFromServer:(NSString *) localFilename fromURL:(NSString *)remoteFilename {
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingFormat:@"%@",localFilename];
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(filePath);
    NSURL *remoteURL = [[NSURL alloc] initWithString:remoteFilename];
    NSData *imageData = [NSData dataWithContentsOfURL:remoteURL]; //this is the line that goes and gets the image
    UIImage *imageTemp = [UIImage imageWithData:imageData];
    if(imageTemp != nil){
        [imageData writeToFile:filePath atomically:false];
        NSLog(@"gotxxxxxxxxx %@",localFilename);
    }
}

- (BOOL)fileIsLocal:(NSString *)filename {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingFormat:@"%@",filename];
    return [fileManager fileExistsAtPath:filePath];
}

#pragma mark - Table View Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"this many in array %li",_itemArray.count);
    return _itemArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"Cell";
    ItemTableViewCell *cell = (ItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    NSDictionary *artistDict = [_itemArray objectAtIndex:indexPath.row];
    cell.itemNameLabel.text = [[_itunesItemArray objectAtIndex:indexPath.row]itemName];
    cell.itemKind.text = [artistDict objectForKey:@"kind"];
    cell.genreLabel.text = [artistDict objectForKey:@"primaryGenreName"];
    

    NSURL *tmpURL = [[NSURL alloc] initWithString:[[_itunesItemArray objectAtIndex:indexPath.row]itemImageURL]];
    NSString *fileName = [NSString stringWithFormat:@"%@%@", [[_itunesItemArray objectAtIndex:indexPath.row]itemID],[[_itunesItemArray objectAtIndex:indexPath.row] otherItemID]];
    NSLog(@"FILE NAME FILE NAME %@%@",fileName,tmpURL);
    NSString *savedImagePath = [NSTemporaryDirectory() stringByAppendingFormat:@"%@",fileName];
    if ([UIImage imageNamed:savedImagePath]==nil) {
        NSLog(@"IMAGE IS NIL IMAGE IS NIL");
    }
    cell.itemImageView.image = [UIImage imageNamed:savedImagePath];

    return cell;
}
#pragma mark - Connectivity Methods

- (void)updateReachabilityStatus:(Reachability *)curReach {
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if(curReach == _hostReach) {
        switch (netStatus)
        {
            case NotReachable:
            {
                NSLog(@"Server Not Available");
                serverAvailable = NO;
                break;
            }
                
            case ReachableViaWWAN:
            {
                NSLog(@"Server Reachable via WWAN");
                serverAvailable = YES;
                break;
            }
            case ReachableViaWiFi:
            {
                NSLog(@"Server Reachable via WiFi");
                serverAvailable = YES;
                break;
            }
        }
    }
    if(curReach == _internetReach || curReach == _wifiReach) {
        switch (netStatus)
        {
            case NotReachable:
            {
                NSLog(@"Internet Not Available");
                internetAvailable = NO;
                break;
            }
                
            case ReachableViaWWAN:
            {
                NSLog(@"Internet Reachable via WWAN");
                internetAvailable = YES;
                break;
            }
            case ReachableViaWiFi:
            {
                NSLog(@"Internet Reachable via WiFi");
                internetAvailable = YES;
                break;
            }
        }
    }
}

- (void)reachabilityChanged:(NSNotification*)note
{
    Reachability* curReach = [note object];
    [self updateReachabilityStatus:curReach];
}

#pragma mark - life cyle methods
- (void)viewDidLoad {
    [super viewDidLoad];
    _hostName = @"itunes.apple.com";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];//any time kreachability changes we will run reachability changed
    _hostReach = [Reachability reachabilityWithHostName:_hostName];
    [_hostReach startNotifier];
    [self updateReachabilityStatus:_hostReach];
    
    _internetReach = [Reachability reachabilityForInternetConnection];
    [_internetReach startNotifier];
    [self updateReachabilityStatus:_internetReach];
    
    _wifiReach = [Reachability reachabilityForLocalWiFi];
    [_wifiReach startNotifier];
    [self updateReachabilityStatus:_wifiReach];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
