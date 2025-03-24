-- Создание базы данных для гостиницы
CREATE DATABASE HotelDB;

USE HotelDB;

-- Таблица ролей пользователей
CREATE TABLE UserRoles (
    RoleID INT PRIMARY KEY AUTO_INCREMENT,
    RoleName VARCHAR(50) NOT NULL UNIQUE
);

-- Таблица пользователей (сотрудников)
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Login VARCHAR(50) NOT NULL UNIQUE,
    Password VARCHAR(100) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    RoleID INT NOT NULL,
    IsActive BOOLEAN NOT NULL DEFAULT 1,
    IsBlocked BOOLEAN NOT NULL DEFAULT 0,
    NeedChangePassword BOOLEAN NOT NULL DEFAULT 1,
    LastLoginDate DATETIME,
    CONSTRAINT FK_Users_RoleID FOREIGN KEY (RoleID) REFERENCES UserRoles(RoleID)
);

-- Таблица типов номеров
CREATE TABLE RoomTypes (
    RoomTypeID INT PRIMARY KEY AUTO_INCREMENT,
    TypeName VARCHAR(50) NOT NULL,
    Description VARCHAR(500),
    BasePrice DECIMAL(10, 2) NOT NULL
);

-- Таблица статусов номеров
CREATE TABLE RoomStatuses (
    StatusID INT PRIMARY KEY AUTO_INCREMENT,
    StatusName VARCHAR(50) NOT NULL,
    Description VARCHAR(255)
);

-- Таблица номеров (номерной фонд)
CREATE TABLE Rooms (
    RoomID INT PRIMARY KEY AUTO_INCREMENT,
    RoomNumber VARCHAR(10) NOT NULL UNIQUE,
    RoomTypeID INT NOT NULL,
    Floor INT NOT NULL,
    Capacity INT NOT NULL,
    StatusID INT NOT NULL,
    Description VARCHAR(500),
    CONSTRAINT FK_Rooms_RoomTypeID FOREIGN KEY (RoomTypeID) REFERENCES RoomTypes(RoomTypeID),
    CONSTRAINT FK_Rooms_StatusID FOREIGN KEY (StatusID) REFERENCES RoomStatuses(StatusID)
);

-- Таблица гостей
CREATE TABLE Guests (
    GuestID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    PassportNumber VARCHAR(20) NOT NULL,
    PassportSeries VARCHAR(20) NOT NULL,
    BirthDate DATE NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(100),
    RegistrationDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Таблица бронирований
CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY AUTO_INCREMENT,
    GuestID INT NOT NULL,
    RoomID INT NOT NULL,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    BookingDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    AdultCount INT NOT NULL DEFAULT 1,
    ChildCount INT NOT NULL DEFAULT 0,
    TotalPrice DECIMAL(10, 2) NOT NULL,
    IsPaid BOOLEAN NOT NULL DEFAULT 0,
    BookingStatusID INT NOT NULL,
    UserID INT NOT NULL,
    CONSTRAINT FK_Bookings_GuestID FOREIGN KEY (GuestID) REFERENCES Guests(GuestID),
    CONSTRAINT FK_Bookings_RoomID FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID),
    CONSTRAINT FK_Bookings_UserID FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT CHK_Bookings_Dates CHECK (CheckOutDate > CheckInDate)
);

-- Таблица проживаний (фактически заселенные гости)
CREATE TABLE Stays (
    StayID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT NOT NULL,
    ActualCheckInDate DATETIME,
    ActualCheckOutDate DATETIME,
    CardKeyActivated BOOLEAN NOT NULL DEFAULT 0,
    CardKeyDeactivationDate DATETIME,
    CONSTRAINT FK_Stays_BookingID FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID),
    CONSTRAINT CHK_Stays_Dates CHECK (ActualCheckOutDate IS NULL OR ActualCheckOutDate > ActualCheckInDate)
);

-- Таблица персонала для уборки
CREATE TABLE CleaningStaff (
    StaffID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT NOT NULL,
    CONSTRAINT FK_CleaningStaff_UserID FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Таблица графика уборки
CREATE TABLE CleaningSchedule (
    ScheduleID INT PRIMARY KEY AUTO_INCREMENT,
    RoomID INT NOT NULL,
    StaffID INT NOT NULL,
    ScheduledDate DATE NOT NULL,
    CompletionDate DATETIME,
    CleaningStatusID INT NOT NULL,
    CONSTRAINT FK_CleaningSchedule_RoomID FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID),
    CONSTRAINT FK_CleaningSchedule_StaffID FOREIGN KEY (StaffID) REFERENCES CleaningStaff(StaffID)
);

-- Заполнение справочных таблиц начальными данными

-- Заполнение таблицы ролей
INSERT INTO UserRoles (RoleName) VALUES 
('Администратор'),
('Менеджер'),
('Администратор гостиницы'),
('Уборщик');

-- Заполнение таблицы статусов номеров
INSERT INTO RoomStatuses (StatusName, Description) VALUES 
('Свободен', 'Номер свободен и готов к заселению'),
('Занят', 'Номер занят гостями'),
('Грязный', 'Номер требует уборки'),
('Назначен к уборке', 'Номер включен в график уборки'),
('Чистый', 'Номер убран и готов к заселению'),
('На ремонте', 'Номер находится на ремонте или обслуживании');

-- Создание администратора системы
INSERT INTO Users (Login, Password, FirstName, LastName, RoleID, IsActive, IsBlocked, NeedChangePassword) 
VALUES ('admin', SHA2('admin', 256), 'Администратор', 'Системы', 1, 1, 0, 0);

-- Заполнение типов номеров (предполагаемые типы на основе общих знаний о гостиницах)
INSERT INTO RoomTypes (TypeName, Description, BasePrice) VALUES
('Стандарт', 'Стандартный номер с одной двуспальной кроватью', 3000.00),
('Люкс', 'Номер повышенной комфортности с гостиной и спальней', 6000.00),
('Полулюкс', 'Улучшенный номер с двуспальной кроватью и диваном', 4500.00),
('Семейный', 'Номер с двумя спальнями и общей гостиной', 5500.00),
('Одноместный', 'Компактный номер с односпальной кроватью', 2000.00);

-- Импорт данных из файла "Номерной фонд.xlsx"
-- Примечание: В реальном проекте здесь необходимо использовать LOAD DATA INFILE
-- для импорта данных из CSV-файла (преобразованного из Excel). Ниже представлен пример кода для ручного импорта.

-- Примерные данные для номеров (в реальном проекте заменить на данные из файла "Номерной фонд.xlsx")
INSERT INTO Rooms (RoomNumber, RoomTypeID, Floor, Capacity, StatusID, Description) VALUES
('101', 1, 1, 2, 5, 'Стандартный номер с видом на парк'),
('102', 1, 1, 2, 5, 'Стандартный номер с видом на улицу'),
('103', 3, 1, 3, 5, 'Полулюкс с видом на парк'),
('201', 2, 2, 4, 5, 'Люкс с видом на город'),
('202', 4, 2, 5, 5, 'Семейный номер с террасой'),
('203', 1, 2, 2, 5, 'Стандартный номер с балконом'),
('301', 2, 3, 4, 5, 'Люкс с джакузи'),
('302', 5, 3, 1, 5, 'Одноместный номер с видом на город'),
('303', 3, 3, 3, 5, 'Полулюкс с сауной'),
('401', 2, 4, 4, 5, 'Пентхаус-люкс с террасой');

-- Код для импорта данных из CSV-файла в реальном проекте (MySQL версия)
/*
-- Создаем временную таблицу для импорта данных
CREATE TEMPORARY TABLE TempRooms (
    RoomNumber VARCHAR(10),
    RoomType VARCHAR(50),
    Floor INT,
    Capacity INT,
    Description VARCHAR(500)
);

-- Импортируем данные из CSV-файла (преобразованного из Excel) во временную таблицу
LOAD DATA INFILE '/path/to/номерной_фонд.csv'
INTO TABLE TempRooms
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Вставляем данные из временной таблицы в таблицу Rooms
INSERT INTO Rooms (RoomNumber, RoomTypeID, Floor, Capacity, StatusID, Description)
SELECT 
    t.RoomNumber,
    rt.RoomTypeID,
    t.Floor,
    t.Capacity,
    (SELECT StatusID FROM RoomStatuses WHERE StatusName = 'Чистый'),
    t.Description
FROM 
    TempRooms t
JOIN 
    RoomTypes rt ON t.RoomType = rt.TypeName;

-- Удаляем временную таблицу
DROP TEMPORARY TABLE IF EXISTS TempRooms;
*/ 