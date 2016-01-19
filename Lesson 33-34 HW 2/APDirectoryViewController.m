//
//  APDirectoryViewController.m
//  Lesson 33-34 HW 2
//
//  Created by Alex on 17.01.16.
//  Copyright © 2016 Alex. All rights reserved.
//

#import "APDirectoryViewController.h"

@interface APDirectoryViewController ()


@property (strong, nonatomic) NSString* selectedPath;
@property (strong, nonatomic) NSString* directoryName;
@property (strong, nonatomic) NSArray* contents;

@property (strong, nonatomic) NSMutableArray* files;  // array for files
@property (strong, nonatomic) NSMutableArray* directories; // array for folders(directories sort)

@property (assign, nonatomic) unsigned long long currentFolderSize;

@end

@implementation APDirectoryViewController

- (id) initWithFolderPath:(NSString*) path
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        self.path = path;
    }
    
    return self;
}



- (void) setPath:(NSString *)path {
    
    _path = path;
    
    NSError* error = nil;
    
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path
                                                                        error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [self.tableView reloadData];
    
    self.navigationItem.title = [self.path lastPathComponent];
}




- (void) dealloc {
    NSLog(@"controller with path %@ has been deallocated", self.path);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.path) {
        self.path = @"/Users/Alex/Documents/TESTFOLDER";
    }
    
    //self.navigationItem.title = [self.path lastPathComponent];
    
    // lets make 2 buttons for adding and editing
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(editAction:)];
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addAction:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:editButton, addButton, nil];
    
    
    [self hideSecretFiles]; //  method to hide hidden like a  .DS_Store
    
    /*
    self.navigationItem.title = [self.path lastPathComponent]; // for showing last directory in path in title of a navy bar
    
    // if the controller is now 1st then go root

        */
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([self.navigationController.viewControllers count]  > 1) {
        UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:@"back to root"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(actionBackToRoot:)];
        self.navigationItem.rightBarButtonItem = item;
    }
    
    [self alphabetOrderOfDirectoriesAndFiles];
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    

    
    NSLog(@"path = %@", self.path);
    
    NSLog(@"view controllers on stack = %ld", [self.navigationController.viewControllers count]);
    
    NSLog(@"index on stack %ld", [self.navigationController.viewControllers indexOfObject:self]);
}

- (BOOL) isDirectoryAtIndexPath:(NSIndexPath*) indexPath {
    
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    
    NSString* filePath = [self.path stringByAppendingPathComponent:fileName];
    
    BOOL isDirectory = NO;
    
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    
    return isDirectory;
    
}


- (void) hideSecretFiles { // method to hide hidden
    
    for (NSString* string in self.contents) {
        
        NSString* firstSymbol = [string substringToIndex:1];
        
        if ([firstSymbol containsString:@"."]) {
            
            NSMutableArray* tempArray = [NSMutableArray arrayWithArray:self.contents];
            
            [tempArray removeObject:string];
            
            self.contents = tempArray;
            
        }
        
    }
    
}

- (void) alphabetOrderOfDirectoriesAndFiles { // method of a sort (upper folders , down files)
    
    self.files = [NSMutableArray array];
    self.directories = [NSMutableArray array];
    
    for (int i = 0; i < [self.contents count]; i++) {
        
        NSString* object = [self.contents objectAtIndex:i];
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        if ([self isDirectoryAtIndexPath:indexPath]) {
            
            [self.directories addObject:object];
            
        } else {
            
            [self.files addObject:object];
            
        }
        
    }
    
    self.directories = (NSMutableArray*)[self.directories sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.files = (NSMutableArray*)[self.files sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    self.contents = [NSArray arrayWithArray:self.directories]; // folders in a sort row
    
    self.contents = [self.contents arrayByAddingObjectsFromArray:self.files]; // then files
    
}



- (NSString*) folderSizeToCount:(NSMutableArray*) foldersArray { // Метод рекурсивно считает размер папки!
    // В метод передаем массив путей, по которым лежат папки.
  
    NSString* result;
    
    NSMutableArray* tempFoldersArray = [NSMutableArray array]; // временный массив
    
    if ([foldersArray count] > 0) { // Если есть директории, ищем файлы
        
        for (NSString* path in foldersArray) {
            
            self.tempFolderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
            // В зависимости от того, сколько у нас директорий, у каждой считываем контент
            
            for (int i = 0; i < [self.tempFolderContents count]; i++) {
                // Пробегаемся по контенту определенного пути, чтобы понять, где файлы, а где директории и, соответственно, их добавляем в массив для следующего прогона по методу
                
                NSString* objectName = [self.tempFolderContents objectAtIndex:i];
                
                NSString* objectPath = [path stringByAppendingPathComponent:objectName];
                
                BOOL isDirectory = NO;
                
                [[NSFileManager defaultManager] fileExistsAtPath:objectPath isDirectory:&isDirectory];
                
                if (isDirectory) {
                    
                    // Если директория, кладем путь до нее в массив
                    [tempFoldersArray addObject:objectPath];
                    
                } else {
                    // Если файл, считаем его размер и суммируем с предыдущими посчитанными.
                    
                    NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:objectPath error:nil];
                    
                    self.currentFolderSize = self.currentFolderSize + [attributes fileSize];
                    
                }
                
            }
            
        }
        
        // После того, как прошли по всем папкам, очищаем массив, а новые, найденные директории, на уровень глубже, добавляем в очищенный массив.
        [foldersArray removeAllObjects];
        
        foldersArray = tempFoldersArray;
        
        return [self folderSizeToCount:foldersArray]; // РЕКУРСИЯ
        
    } else {
        // Смотрим файлы по директориям, пока директорий не станет 0, тогда все посчитанные файлы считаем
        
        result = [self fileSizeFromValue:self.currentFolderSize];
        
        return result;
        
    }
    
    return nil;
    
}

#pragma mark - Actions

- (void) actionBackToRoot:(UIBarButtonItem*) sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) editAction:(UIBarButtonItem*) sender { //  Edit/Done button
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if (self.tableView.isEditing) {
        
        UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(editAction:)];
        
        self.navigationItem.rightBarButtonItem = editButton;
        
    }
    
    else {
        
        // Кнопки нужно пересоздавать (Edit ---> Done)
        UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                    target:self
                                                                                    action:@selector(editAction:)];
        
        self.navigationItem.rightBarButtonItem = editButton;
        
    }
    
}

- (void) addAction:(UIBarButtonItem*) sender { // Метод для добавления директорий
    
    
    //UIAlertController
    UIAlertAction *actionCancel = nil;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Create Directory"
                                                                             message:@"Enter the name"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
  
    
    // Cancel Button
    actionCancel = [UIAlertAction
                    actionWithTitle:NSLocalizedString(@"cancel", nil)
                    style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        // cancel
                        // Cancel code
                    }];
    
    
    [alertController addAction:actionCancel];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder  = @"Directory Name";
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingDidEnd];
    
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}



- (IBAction)actionInforCell:(id)sender {
    
    
    NSLog(@"actionInfoCell");
    
    UITableViewCell* cell = [sender superCell];
    
    if (cell) {
        
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        
        //UIAlertController
        UIAlertAction *actionCancel = nil;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Yahoo!"
                                            message:[NSString stringWithFormat:@"action %ld %ld", indexPath.section, indexPath.row]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        // Cancel Button
        actionCancel = [UIAlertAction
                        actionWithTitle:NSLocalizedString(@"ok!", nil)
                        style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                            // cancel
                            // Cancel code
                        }];
        
        
        [alertController addAction:actionCancel];
        [self presentViewController:alertController animated:YES completion:nil];
        
        // UIAlertView is depricated so look code upper
        
        /*        [[[UIAlertView alloc]
          initWithTitle:@"Yahoo!"
          message:[NSString stringWithFormat:@"action %ld %ld", indexPath.section, indexPath.row]
          delegate:nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil] show];
        */
        
    }
    
    
    
}



- (NSString*) fileSizeFromValue:(unsigned long long) size {
    
    static NSString* units[] = {@"B", @"KB", @"MB", @"GB", @"TB"};
    static int unitsCount = 5;
    
    int index = 0;
    
    double fileSize = (double)size;
    
    while (fileSize > 1024 && index < unitsCount) {
        fileSize /= 1024;
        index++;
    }
    
    return [NSString stringWithFormat:@"%.2f %@", fileSize, units[index]];
}


#pragma mark - UITableViewDataSource



/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 0;
}
*/


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.contents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* fileIdentifier = @"FileCell";
    static NSString* folderIdentifier = @"FolderCell";
    
    
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        
        APFolderCell *cell = [tableView dequeueReusableCellWithIdentifier:folderIdentifier];
        
        cell.folderName.text = fileName;
        
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        self.currentFolderSize = 0;
        
        NSMutableArray* foldersArray = [NSMutableArray arrayWithObject:path];
        
        cell.folderSize.text = [self folderSizeToCount:foldersArray];
        
        
        return cell;
        
    } else {
        
        APCell *cell = [tableView dequeueReusableCellWithIdentifier:fileIdentifier];
        
        cell.nameLabel.text = [NSString stringWithFormat:@"%@", fileName];
        
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        cell.sizeLabel.text = [self fileSizeFromValue:[attributes fileSize]];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:@"dd.MM.yyyy HH:mm"];
        
        NSDate* date = [attributes fileModificationDate];
        
        cell.dateLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
        
        return cell;
        
    }
    
    return nil;
}



#pragma mark - UITableViewDelegate



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Удаление папки/файла
    
    // удаляем файл из массива контента
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:self.contents];
    
    NSString* fileToDelete = [tempArray objectAtIndex:indexPath.row];
    
    [tempArray removeObject:fileToDelete];
    
    self.contents = tempArray;
    
    NSError* error = nil;
    
    NSString* path = [self.path stringByAppendingPathComponent:fileToDelete];
    
    // Убираем файлменеджером файл (безвозвратное удаление)
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    if (error) {
        
        NSLog(@"%@", [error localizedDescription]);
        
    }
    
    [self.tableView beginUpdates];
    // анимация удаления
    
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    [self.tableView endUpdates];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        return 44.f;
    } else {
        return 80.f;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isDirectoryAtIndexPath:indexPath]) {
        
        NSString* fileName = [self.contents objectAtIndex:indexPath.row];
        
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        
        // this is variant 1 how to init ViewController
        /*
        APDirectoryViewController* vc = [[APDirectoryViewController alloc] initWithFolderPath:path];
        
        [self.navigationController pushViewController:vc animated:YES];
        */
       
        
        // this is variant 2 how to init ViewController
        /*
        APDirectoryViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"APDirectoryViewController"];
        vc.path = path;
        [self.navigationController pushViewController:vc animated:YES];
         */
        
        // this is variant 3 how to init ViewController
        // first in main.storyboard make a buttom in a top and seque
        
        self.selectedPath = path;
        
        [self performSegueWithIdentifier:@"navigateDeep" sender:nil];
        
         // just for info UIStoryboard* storyboard = self.storyboard;
        
    }
        
    
}

#pragma mark - Seque

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    NSLog(@"shouldPerformSegueWithIdentifier - %@", identifier);
    
    return YES;
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"prepareForSegue - %@", segue.identifier);
    
    APDirectoryViewController* vc = segue.destinationViewController;
    
    vc.path = self.selectedPath;
    
}

#pragma mark - UIAlertViewDelegate


- (void)alertControllerTextFieldDidChange:(UITextField *)sender {
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    
        
        //go and get the action field
        
        UITextField *textField = alertController.textFields.firstObject;
        
        NSLog(@"what is alert text? - %@",textField.text);
        
        NSString* newDirectoryName = [textField text];
        
        NSString* path = [self.path stringByAppendingPathComponent:newDirectoryName];
        
        NSError* error = nil;
        
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&error];
        
        self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error];
        
        if (error) {
            
            NSLog(@"%@", [error localizedDescription]);
            
        }
        
        [self hideSecretFiles]; // прячем скрытые файлы, иначе после создания папки, они вновь появляются
        
        [self.tableView reloadData];
        
        [self alphabetOrderOfDirectoriesAndFiles];

    
}




@end
