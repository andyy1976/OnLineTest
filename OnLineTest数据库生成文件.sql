------------------------------------------------ 设置缓存依赖项 ------------------------------------------------
        --cd C:\Windows\Microsoft.NET\Framework\v2.0.50727
        --aspnet_regsql -C "Data Source=localhost;Initial Catalog=OnLineTest;Integrated Security=True" -ed -et -t "Authority"
        --aspnet_regsql -C "Data Source=localhost;Initial Catalog=OnLineTest;Integrated Security=True" -ed -et -t "UserAuthority"
        --aspnet_regsql -C "Data Source=localhost;Initial Catalog=OnLineTest;Integrated Security=True" -ed -et -t "UserGroup"
        --aspnet_regsql -C "Data Source=localhost;Initial Catalog=OnLineTest;Integrated Security=True" -ed -et -t "UserRank"



------------------------------------------------ 生成数据库部分 ------------------------------------------------


use master -- 设置当前数据库为master,以便访问sysdatabases表
if exists(select * from sysdatabases where name='OnLineTest') 
drop database OnLineTest      
CREATE DATABASE [OnLineTest] ON  PRIMARY 
(
	 NAME = N'OnLineTest', 
	 FILENAME = N'C:\OnLineTest.mdf' , 
	 SIZE = 10240KB , 
	 FILEGROWTH = 1024KB 
 )
 LOG ON 
( 
	NAME = N'OnLineTest_log', 
	FILENAME = N'C:\OnLineTest_log.ldf' , 
	SIZE = 1024KB , 
	FILEGROWTH = 10%
)
GO

------------------------------------------------生成数据表部分----------------------------------------------


------------------------------------------------ 生成用户组表 ------------------------------------------------

use OnLineTest
if exists (select * from sysobjects where name='UserGroup')
drop table UserGroup
	CREATE TABLE UserGroup --用户组
	(
		UserGroupId int identity(1,1) primary key,--用户组Id int identity primary key
		UserGroupName varchar(20) unique,--用户组名称 varchar(20) unique
		UserGroupRemark text null,--用户组备注
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '用户组实例', 'user',  dbo, 'table',  UserGroup
EXEC sp_addextendedproperty 'MS_Description', '用户组ID号 int identity primary key', 'user', dbo, 'table', UserGroup, 'column', UserGroupId
EXEC sp_addextendedproperty 'MS_Description', '用户组名称 varchar(20) unique', 'user', dbo, 'table', UserGroup, 'column', UserGroupName
EXEC sp_addextendedproperty 'MS_Description', '用户组备注 text null', 'user', dbo, 'table', UserGroup, 'column', UserGroupRemark  
GO
------------------------------------------------ 生成用户表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='Users')
drop table Users
	CREATE TABLE Users
	(
		UserId int identity(1,1) primary key,-----用户ID号
		UserName varchar(20) not null unique,-----登录名
		UserPassword varchar(200) not null,----登录密码，要求使用MD5格式存储
		UserChineseName nvarchar(20) null,------用户名称
		UserImageName nvarchar(100) not null default('default.jpg'),
		UserEmail varchar(50) not null unique,-----用户电子邮件
		IsValidate bit not null default 0,-----是否通过电子邮件验证
		Tel varchar(20) null,
		UserScore int not null default 0 ,-----用户的论坛分值
		UserRegisterDatetime datetime not null default getdate(),-----用户注册时间
		UserLoginStatus bit not null default 0,------用户是否登录标记0为未登录,1为登录
		UserGroupId int not null default(1) references UserGroup(UserGroupId),
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '用户实例', 'user',  dbo, 'table',  Users
EXEC sp_addextendedproperty 'MS_Description', '用户Id号 int identity(1,1) primary key', 'user', dbo, 'table', Users, 'column', UserId
EXEC sp_addextendedproperty 'MS_Description', '用户名 varchar(20) not null unique', 'user', dbo, 'table', Users, 'column', UserName
EXEC sp_addextendedproperty 'MS_Description', '用户密码（使用MD5加密） varchar(200) not null', 'user', dbo, 'table', Users, 'column', UserPassword
EXEC sp_addextendedproperty 'MS_Description', '用户中文名 nvarchar(20) null', 'user', dbo, 'table', Users, 'column', UserChineseName
EXEC sp_addextendedproperty 'MS_Description', '用户图像名称 nvarchar(100) not null default(''default.jpg'')', 'user', dbo, 'table', Users, 'column', UserImageName
EXEC sp_addextendedproperty 'MS_Description', '用户电子邮件 varchar(50) not null unique', 'user', dbo, 'table', Users, 'column', UserEmail
EXEC sp_addextendedproperty 'MS_Description', '用户是否通过验证标记 bit not null default 0', 'user', dbo, 'table', Users, 'column', IsValidate
EXEC sp_addextendedproperty 'MS_Description', '用户电话号码 varchar(20) null', 'user', dbo, 'table', Users, 'column', Tel
EXEC sp_addextendedproperty 'MS_Description', '用户论坛分数 int not null default 0', 'user', dbo, 'table', Users, 'column', UserScore
EXEC sp_addextendedproperty 'MS_Description', '用户注册时间 datetime not null default getdate()', 'user', dbo, 'table', Users, 'column', UserRegisterDatetime
EXEC sp_addextendedproperty 'MS_Description', '外键，用户所属的用户组 int not null default(1) references UserGroup(UserGroupId)', 'user', dbo, 'table', Users, 'column', UserGroupId
Go

------------------------------------------------ 生成用户等级组 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='UserRank')
drop table UserRank
	create table UserRank-----用户等级表
	(
		UserRankId int identity(1,1) primary key,-----等级ID
		UserRankName nvarchar(50) not null unique,-----等级对应的中文名称
		MinScore int not null check(MinScore>=0),-----等级所对应的最低分
		MaxScore int not null check(MaxScore>=0),-----等级所对应的最高分
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称EXEC sp_addextendedproperty 'MS_Description',  '用户等级实例', 'user',  dbo, 'table',  UserRank
EXEC sp_addextendedproperty 'MS_Description',  '用户等级实例', 'user',  dbo, 'table',  UserRank
EXEC sp_addextendedproperty 'MS_Description', '用户等级Id int identity(1,1) primary key', 'user', dbo, 'table', UserRank, 'column', UserRankId	
EXEC sp_addextendedproperty 'MS_Description', '用户等级对应的中文名称 nvarchar(20) not null unique', 'user', dbo, 'table', UserRank, 'column', UserRankName	
EXEC sp_addextendedproperty 'MS_Description', '等级所对应的最低分值 int not null check(MinScore>=0)', 'user', dbo, 'table', UserRank, 'column', MinScore	
EXEC sp_addextendedproperty 'MS_Description', '等级所对应的最高分值 int not null check(MaxScore>=0)', 'user', dbo, 'table', UserRank, 'column', MaxScore	
GO

------------------------------------------------ 生成权限表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='Authority')
drop table Authority
	create table Authority-----权限表
	(
		AuthorityId int identity(1,1) primary key,-----权限ID
		AuthorityName nvarchar(20) not null,-----此项权限的中文名称
		AuthorityDeep int not null,-----此权限的深度(第一级定义为0)
		AuthorityParentId int not null,-----此项权限的父编号(第一级的父编号为0)
		AuthorityScore int  not null,-----此项权限（动作）所对应的分值(可以为负值)
		AuthorityHandlerPage varchar(50) not null unique,-----此项权限的处理页面
		AuthorityOrderNum int default 0,-------此项权限的排序号
		AuthorityRemark text not null,-----此项权限所的备注
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description', '权限实例', 'user',  dbo, 'table',  Authority
EXEC sp_addextendedproperty 'MS_Description', 'int identity(1,1) primary key,-----权限ID', 'user', dbo, 'table', Authority, 'column', AuthorityId		
EXEC sp_addextendedproperty 'MS_Description', 'nvarchar(20) not null,-----此项权限的中文名称','user', dbo, 'table', Authority, 'column', AuthorityName	
EXEC sp_addextendedproperty 'MS_Description', 'int not null,-----此权限的深度(第一级定义为0) ', 'user', dbo, 'table', Authority, 'column', AuthorityDeep
EXEC sp_addextendedproperty 'MS_Description', 'int not null,-----此项权限的父编号(第一级的父编号为0)', 'user', dbo, 'table', Authority, 'column', AuthorityParentId
EXEC sp_addextendedproperty 'MS_Description', ' int  not null,-----此项权限（动作）所对应的分值(可以为负值)', 'user', dbo, 'table', Authority, 'column', AuthorityScore	
EXEC sp_addextendedproperty 'MS_Description', ' varchar(50) not null,-----此项权限的处理页面', 'user', dbo, 'table', Authority, 'column', AuthorityHandlerPage	
EXEC sp_addextendedproperty 'MS_Description', 'int default 0,-------此项权限的排序号', 'user', dbo, 'table', Authority, 'column', AuthorityOrderNum	
EXEC sp_addextendedproperty 'MS_Description', 'text not null,-----此项权限所的备注', 'user', dbo, 'table', Authority, 'column', AuthorityRemark		
GO
  
------------------------------------------------ 生成用户权限表 ------------------------------------------------   
    
use OnLineTest
if exists (select*from sysobjects where name='UserAuthority')
drop table UserAuthority
	create table UserAuthority-----用户权限表
	(
		UserAuthorityId int identity(1,1) primary key,-----用户权限ID
		AuthorityId int  not null references Authority(AuthorityId),-----外键，用户权限
		UserGroupId int not null references UserGroup(UserGroupId),-----用户权限所对应的用户组
		UserRankId int not null references UserRank(UserRankId), -----此权限所对应的用户等级（外键）
		UserAuthoriryRemark text not null,-----用户权限备注
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description', '用户权限实例', 'user',  dbo, 'table',  UserAuthority
EXEC sp_addextendedproperty 'MS_Description', '用户权限Id int identity(1,1) primary key', 'user', dbo, 'table', UserAuthority, 'column', UserAuthorityId
EXEC sp_addextendedproperty 'MS_Description', '外键，用户权限int  not null references Authority(AuthorityId),', 'user', dbo, 'table', UserAuthority, 'column', AuthorityId		
EXEC sp_addextendedproperty 'MS_Description', '外键 用户权限所对应的用户组ID int not null references UserGroup(UserGroupId)', 'user', dbo, 'table', UserAuthority, 'column', UserGroupId	
EXEC sp_addextendedproperty 'MS_Description', '外键 权限所对应的用户等级ID int not null references UserRank(UserRankId)', 'user', dbo, 'table', UserAuthority, 'column', UserRankId	
EXEC sp_addextendedproperty 'MS_Description', '备注（此项权限所的备注） text not null', 'user', dbo, 'table', UserAuthority, 'column', UserAuthoriryRemark		
GO

------------------------------------------------ 生成科目表 ------------------------------------------------
           
use OnLineTest
if exists (select*from sysobjects where name='Subject')
drop table Subject
	create table Subject-----设置科目表
	(
		SubjectId int identity(1,1) primary key,-----科目ID
		SubjectName nvarchar(50) not null,-----科目名称
		SubjectRemark text null,-----科目备注
		IsVerified bit not null default(0),-----是否通过审核标记
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '科目实例', 'user',  dbo, 'table',  Subject
EXEC sp_addextendedproperty 'MS_Description', '科目ID  int identity(1,1) primary key', 'user', dbo, 'table', Subject, 'column', SubjectId
EXEC sp_addextendedproperty 'MS_Description', '科目名称 nvarchar(50) not null', 'user', dbo, 'table', Subject, 'column', SubjectName
EXEC sp_addextendedproperty 'MS_Description', '备注 text null', 'user', dbo, 'table', Subject, 'column', SubjectRemark
EXEC sp_addextendedproperty 'MS_Description', '是否通过审核标记 bit not null default(0)', 'user', dbo, 'table', Subject, 'column', IsVerified
GO

------------------------------------------------ 生成试卷代码表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='PaperCodes')
drop table PaperCodes
	create table PaperCodes-----试卷代码表
	(
		PaperCodeId int identity(1,1) primary key,-----试卷代码ID
		SubjectId int not null references Subject(SubjectId),-----试卷代码所对应的科目ID，外键
		PaperCode int not null unique,-----试卷代码
		ChineseName nvarchar(100) not null,-----试卷代码所对应的中文名称
		PaperCodePassScore int not null,-----试卷代码的及格分数线
		PaperCodeTotalScore int not null,-----试卷代码的总分
		TimeRange int not null,-----试卷代码考试的时长
		PaperCodeRemark text null,-----试卷代码的备注
		IsVerified bit not null default(0),-----是否通过审核标记
		foreign key(SubjectId) references Subject(SubjectId),-----设置外键
		CONSTRAINT CK_UserRank CHECK (PaperCodePassScore>0 AND PaperCodeTotalScore>0 and PaperCodeTotalScore>PaperCodePassScore and TimeRange>0)-----设置几个值的约束
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '试卷代码实例', 'user',  dbo, 'table',  PaperCodes
EXEC sp_addextendedproperty 'MS_Description', '试卷代码ID int identity(1,1) primary key', 'user', dbo, 'table', PaperCodes, 'column', PaperCodeId
EXEC sp_addextendedproperty 'MS_Description', '外键，试卷代码所对应的科目ID int not null references Subject(SubjectId)', 'user', dbo, 'table', PaperCodes, 'column',SubjectId
EXEC sp_addextendedproperty 'MS_Description', '试卷代码 int not null unique', 'user', dbo, 'table', PaperCodes, 'column', PaperCode
EXEC sp_addextendedproperty 'MS_Description', '试卷代码所对应的中文名称 nvarchar(100) not null', 'user', dbo, 'table', PaperCodes, 'column', ChineseName
EXEC sp_addextendedproperty 'MS_Description', '试卷代码的及格分数线 int not null PaperCodePassScore>0  PaperCodeTotalScore>PaperCodePassScore', 'user', dbo, 'table', PaperCodes, 'column', PaperCodePassScore
EXEC sp_addextendedproperty 'MS_Description', '试卷代码的总分数 int not null PaperCodeTotalScore>0 PaperCodeTotalScore>PaperCodePassScore', 'user', dbo, 'table', PaperCodes, 'column', PaperCodeTotalScore
EXEC sp_addextendedproperty 'MS_Description', '试卷代码的考试时长 int not null TimeRange>0', 'user', dbo, 'table', PaperCodes, 'column', TimeRange
EXEC sp_addextendedproperty 'MS_Description', '试卷代码的备注 text null', 'user', dbo, 'table', PaperCodes, 'column', PaperCodeRemark
EXEC sp_addextendedproperty 'MS_Description', '试卷代码是否通过审核标记 bit not null default(0)', 'user', dbo, 'table', PaperCodes, 'column', IsVerified
GO

------------------------------------------------ 生成教材表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='TextBook')
drop table TextBook
	create table TextBook-----设置试卷代码所对应的教材
	(
		TextBookId int identity(1,1) primary key,-----教材ID
		PaperCodeId int not null,-----试卷代码ID，外键一门课程可以有多本教材
		TextBookName nvarchar(200) not null,-----教材名称
		ISBN nvarchar(50) not null,-----教材的ISBN号码
		IsVerified bit not null default(0),-----是否通过审核标记
		remark text null,---------教材备注，这里主要表现教材的出版机构、出版时间、特别说明等内容
		foreign key(PaperCodeId) references PaperCodes(PaperCodeId)-----设置外键
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '教材实例', 'user',  dbo, 'table',  TextBook
EXEC sp_addextendedproperty 'MS_Description', '教材ID int identity(1,1) primary key', 'user', dbo, 'table', TextBook, 'column', TextBookId
EXEC sp_addextendedproperty 'MS_Description', '外键,教材所对应的试卷代码ID(一门课程可以有多本教材) int not null', 'user', dbo, 'table', TextBook, 'column', PaperCodeId
EXEC sp_addextendedproperty 'MS_Description', '教材名称 nvarchar(200) null', 'user', dbo, 'table', TextBook, 'column', TextBookName
EXEC sp_addextendedproperty 'MS_Description', '书号 nvarchar(50) null', 'user', dbo, 'table', TextBook, 'column', ISBN
EXEC sp_addextendedproperty 'MS_Description', '是否通过审核标记 bit not null default(0)', 'user', dbo, 'table', TextBook, 'column', IsVerified
GO

------------------------------------------------ 生成教材章节表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='Chapter')
drop table Chapter
create table Chapter------教材所对应的章节表
	(
		ChapterId int identity(1,1) primary key,-----章节ID
		TextBookId int not null,------教材ID，外键
		ChapterName nvarchar(200) not null,-----章节名称
		ChapterParentNo int not null,-----父节点编号
		ChapterDeep int not null,------章节深度
		ChapterRemark text null,-----备注
		IsVerified bit not null default(0),-----是否通过审核标记
		foreign key(TextBookId) references TextBook(TextBookId)-----设置外键
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '教材章节表', 'user',  dbo, 'table',  Chapter
EXEC sp_addextendedproperty 'MS_Description', '章节ID int identity(1,1) primary key', 'user', dbo, 'table', Chapter, 'column', ChapterId
EXEC sp_addextendedproperty 'MS_Description', '外键,章节所对应的教材ID int not null references TextBook(TextBookId)', 'user', dbo, 'table', Chapter, 'column',TextBookId 
EXEC sp_addextendedproperty 'MS_Description', '章节名称 nvarchar(200) not null', 'user', dbo, 'table', Chapter, 'column', ChapterName
EXEC sp_addextendedproperty 'MS_Description', '章节的父节点编号 int not null', 'user', dbo, 'table', Chapter, 'column',ChapterParentNo 
EXEC sp_addextendedproperty 'MS_Description', '章节深度 int not null', 'user', dbo, 'table', Chapter, 'column', ChapterDeep
EXEC sp_addextendedproperty 'MS_Description', '备注 text null', 'user', dbo, 'table', Chapter, 'column',ChapterRemark 
EXEC sp_addextendedproperty 'MS_Description', '是否通过审核标记 bit not null default(0)', 'user', dbo, 'table', Chapter, 'column', IsVerified
GO

------------------------------------------------ 生成试题难度系数表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='Difficulty')
drop table Difficulty
create table Difficulty-----试题的难度系数
	(
		DifficultyId int identity(1,1) primary key,-----难度系数ID
		DifficultyRatio int not null default 5 check( DifficultyRatio>=0 and DifficultyRatio<=10),-----难度系数0-10
		DifficultyDescrip nvarchar(20) not null,-----难度系数对应的描述
		DifficultyRemark text null-----备注
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '试题的难度系数实例', 'user',  dbo, 'table',  Difficulty
EXEC sp_addextendedproperty 'MS_Description', '难度系数ID int identity(1,1) primary key', 'user', dbo, 'table', Difficulty, 'column', DifficultyId
EXEC sp_addextendedproperty 'MS_Description', '难度系数0-10(0最容易,10最难) int not null default 5 check( DifficultyRatio>=0 and DifficultyRatio<=10)', 'user', dbo, 'table', Difficulty, 'column', DifficultyRatio
EXEC sp_addextendedproperty 'MS_Description', '难度系数对应的描述 nvarchar(20) not null', 'user', dbo, 'table', Difficulty, 'column', DifficultyDescrip
EXEC sp_addextendedproperty 'MS_Description', '备注 text null', 'user', dbo, 'table', Difficulty, 'column', DifficultyRemark
GO

------------------------------------------------ 生成考区信息表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='ExamZone')
drop table ExamZone
create table ExamZone-----考区信息
	(
		ExamZoneId int identity(1,1) primary key,-----ID
		ExamZoneName nvarchar(20) not null,-----考区名称
		IsVerified bit not null default(0),-----是否通过审核标记
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '考区信息实例', 'user',  dbo, 'table',  ExamZone
EXEC sp_addextendedproperty 'MS_Description', '考区ID int identity(1,1) primary key', 'user', dbo, 'table', ExamZone, 'column', ExamZoneId
EXEC sp_addextendedproperty 'MS_Description', '考区名称 nvarchar(20) not null', 'user', dbo, 'table', ExamZone, 'column', ExamZoneName
EXEC sp_addextendedproperty 'MS_Description', '是否通过审核标记 bit not null default(0)', 'user', dbo, 'table', ExamZone, 'column', IsVerified
GO

------------------------------------------------ 生成真题信息表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='PastExamPaper')
drop table PastExamPaper
create table PastExamPaper-----历年真题信息（这里不包括试题信息）
	(
		PastExamPaperId int identity(1,1) primary key,-----ID
		PaperCodeId int not null references PaperCodes(PaperCodeId),-----真题对应的试卷代码
		ExamZoneId int not null references ExamZone(ExamZoneId),-----真题对应的考区信息
		PastExamPaperPeriodNo int not null,-----期数
		PastExamPaperDatetime datetime null,-----考试的时间
		IsVerified bit not null default(0),-----是否通过审核标记
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '历年真题信息实例(仅介绍信息,相关试题不在实例)', 'user',  dbo, 'table',  PastExamPaper
EXEC sp_addextendedproperty 'MS_Description', '历年真题信息ID int identity(1,1) primary key', 'user', dbo, 'table', PastExamPaper, 'column', PastExamPaperId
EXEC sp_addextendedproperty 'MS_Description', '外键,真题所对应的试卷代码ID int not null references PaperCodes(PaperCodeId)', 'user', dbo, 'table', PastExamPaper, 'column', PaperCodeId
EXEC sp_addextendedproperty 'MS_Description', '外键,真题所对应的考区ID int not null references ExamZone(ExamZoneId)', 'user', dbo, 'table', PastExamPaper, 'column', ExamZoneId
EXEC sp_addextendedproperty 'MS_Description', '真题对应的期数 int not null', 'user', dbo, 'table', PastExamPaper, 'column', PastExamPaperPeriodNo
EXEC sp_addextendedproperty 'MS_Description', '真题对应的考试时间 datetime null', 'user', dbo, 'table', PastExamPaper, 'column', PastExamPaperDatetime
EXEC sp_addextendedproperty 'MS_Description', '真题信息是否通过审核 bit not null default(0)', 'user', dbo, 'table', PastExamPaper, 'column', IsVerified
GO

------------------------------------------------ 生成试题表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='Question')
drop table Question
create table Question-----试题表
	(
		QuestionId int identity(1,1) primary key,-----试题ID
		QuestionTitle text not null,-----题目
		AnswerA text  not null,-----选项A
		AnswerB text  not null,-----选项B
		AnswerC text  not null,-----选项C
		AnswerD text  not null,-----选项D
		CorrectAnswer int  not null check(CorrectAnswer in(1,2,3,4)),-----参考答案
		Explain text null,-----解析
		ImageAddress nvarchar(100) null,-----图形名称
		DifficultyId int not null references Difficulty(DifficultyId),-----难度系数
		UserId int not null references Users(UserId),-----上传人ID
		UpLoadTime datetime not null default getdate(),-----上传时间
		VerifyTimes int not null default 0,-----被审核次数（三次以上有效）
		IsVerified bit not null default 0,-----是否审核通过0为不通过，1为通过,只有审核通过，才将试题更新到审核后的状态，否则不更新
		IsDelte bit not null default 0,-----软删除标记
		IsSupported int not null default 0,-----被赞次数
		IsDeSupported int not null default 0,-----被踩次数
		PaperCodeId int not null references PaperCodes(PaperCodeId),-----试题所对应的试卷代码
		TextBookId int null references TextBook(TextBookId),-----试题对应的教材
		ChapterId int null references Chapter(ChapterId),-----试题所对应的章节
		PastExamPaperId int null references PastExamPaper(PastExamPaperId),-----试题是否是历年真题
		PastExamQuestionId int null check(PastExamQuestionId>0 and PastExamQuestionId<=160), -----如果是真题，则在真题中的题号
		Remark text  null ---------备注
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '试题实例', 'user',  dbo, 'table',  Question
EXEC sp_addextendedproperty 'MS_Description', '试题ID int identity(1,1) primary key', 'user', dbo, 'table', Question, 'column', QuestionId
EXEC sp_addextendedproperty 'MS_Description', '题目 text not null', 'user', dbo, 'table', Question, 'column', QuestionTitle
EXEC sp_addextendedproperty 'MS_Description', '选项A text  not null', 'user', dbo, 'table', Question, 'column', AnswerA
EXEC sp_addextendedproperty 'MS_Description', '选项B text  not null', 'user', dbo, 'table', Question, 'column', AnswerB
EXEC sp_addextendedproperty 'MS_Description', '选项C text  not null', 'user', dbo, 'table', Question, 'column', AnswerC
EXEC sp_addextendedproperty 'MS_Description', '选项D text  not null', 'user', dbo, 'table', Question, 'column', AnswerD
EXEC sp_addextendedproperty 'MS_Description', '参考答案 int  not null check(CorrectAnswer in(1,2,3,4))', 'user', dbo, 'table', Question, 'column', CorrectAnswer
EXEC sp_addextendedproperty 'MS_Description', '题目对应的图形(如果有) nvarchar(100) null', 'user', dbo, 'table', Question, 'column', ImageAddress
EXEC sp_addextendedproperty 'MS_Description', '外键,难度系数 int not null references Difficulty(DifficultyId)', 'user', dbo, 'table', Question, 'column', DifficultyId
EXEC sp_addextendedproperty 'MS_Description', '外键,上传此试题的用户 int not null references Users(UserId)', 'user', dbo, 'table', Question, 'column', UserId
EXEC sp_addextendedproperty 'MS_Description', '上传的时间 datetime not null default getdate()', 'user', dbo, 'table', Question, 'column', UpLoadTime
EXEC sp_addextendedproperty 'MS_Description', '被审核的次数(三次以后进入终审) int not null default 0', 'user', dbo, 'table', Question, 'column', VerifyTimes
EXEC sp_addextendedproperty 'MS_Description', '是否审核通过标记,0为不通过,1为通过,只有通过审核以后,才将试题更新到审核后的状态,否则不更新 bit not null default 0', 'user', dbo, 'table', Question, 'column', IsVerified
EXEC sp_addextendedproperty 'MS_Description', '软删除标记 bit not null default 0', 'user', dbo, 'table', Question, 'column', IsDelte
EXEC sp_addextendedproperty 'MS_Description', '被赞次数 int not null default 0', 'user', dbo, 'table', Question, 'column', IsSupported
EXEC sp_addextendedproperty 'MS_Description', '被踩次数 int not null default 0', 'user', dbo, 'table', Question, 'column', IsDeSupported
EXEC sp_addextendedproperty 'MS_Description', '外键,题目所属的试卷代码ID int not null references PaperCodes(PaperCodeId)', 'user', dbo, 'table', Question, 'column', PaperCodeId
EXEC sp_addextendedproperty 'MS_Description', '外键,题目对应的教材(因为一个试卷代码可以有多本教材) int null references TextBook(TextBookId)', 'user', dbo, 'table', Question, 'column', TextBookId
EXEC sp_addextendedproperty 'MS_Description', '试题所对应的章节 int null references Chapter(ChapterId)', 'user', dbo, 'table', Question, 'column', ChapterId
EXEC sp_addextendedproperty 'MS_Description', '试题是否是历年真题,null表示不是真题 int null references PastExamPaper(PastExamPaperId)', 'user', dbo, 'table', Question, 'column', PastExamPaperId
GO

------------------------------------------------ 生成试题审核状态表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='VerifyStatus')
drop table VerifyStatus
create table VerifyStatus-----审核过程中的各个状态
	(
		VerifyStatusId int identity(1,1) primary key,-----审核状态ID
		QuestionId int not null references Question(QuestionId),-----与试题库中对应的试题ID（要审核通过以后才能更新到试题库）
		UserId int not null references Users(UserId),-----审核人ID
		VerifyTimes int not null default 1,-----审核次数（三次为通过）
		IsPass bit not null default 0,-----是否通过标记
		VerifyTime datetime not null default getdate(),-----审核时间
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '试题在审核过程中的状态实例', 'user',  dbo, 'table',  VerifyStatus
EXEC sp_addextendedproperty 'MS_Description', 'ID int identity(1,1) primary key', 'user', dbo, 'table', VerifyStatus, 'column', VerifyStatusId
EXEC sp_addextendedproperty 'MS_Description', '外键,与试题实例ID相对应(要审核通过以后才能更新到试题库) int not null references Question(QuestionId)', 'user', dbo, 'table', VerifyStatus, 'column', QuestionId
EXEC sp_addextendedproperty 'MS_Description', '外键,审核人用户ID int not null references Users(UserId)', 'user', dbo, 'table', VerifyStatus, 'column', UserId
EXEC sp_addextendedproperty 'MS_Description', '审核次数 int not null default 1', 'user', dbo, 'table', VerifyStatus, 'column', VerifyTimes
EXEC sp_addextendedproperty 'MS_Description', '是否通过标记(通过时,更新此字段) bit not null default 0', 'user', dbo, 'table', VerifyStatus, 'column', IsPass
EXEC sp_addextendedproperty 'MS_Description', '审核时间 datetime not null default getdate()', 'user', dbo, 'table', VerifyStatus, 'column', VerifyTime
GO

------------------------------------------------ 生成练习记录表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='LogPractice')
drop table LogPractice
create table LogPractice-----保存练习的习题
	(
		LogPracticeId int identity(1,1) primary key,-----ID
		userId int not null references Users(UserId),-----用户ID
		QuestionId int not null references Question(QuestionId),-----试题ID
		LogPracticeTime datetime not null default getdate(),-----练习时间
		LogPracticeAnswer int null check(LogpracticeAnswer in(1,2,3,4)),-----练习时给出的答案
		LogPracetimeRemark text null-----备注
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '记录平时练习的习题实例', 'user',  dbo, 'table',  LogPractice
EXEC sp_addextendedproperty 'MS_Description', 'ID int identity(1,1) primary key', 'user', dbo, 'table', LogPractice, 'column', LogPracticeId
EXEC sp_addextendedproperty 'MS_Description', '外键,练习的用户 int not null references Users(UserId)', 'user', dbo, 'table', LogPractice, 'column', userId
EXEC sp_addextendedproperty 'MS_Description', '外键,练习的试题 int not null references Question(QuestionId)', 'user', dbo, 'table', LogPractice, 'column', QuestionId
EXEC sp_addextendedproperty 'MS_Description', '练习的时间 datetime not null default getdate()', 'user', dbo, 'table', LogPractice, 'column', LogPracticeTime
EXEC sp_addextendedproperty 'MS_Description', '练习时选择的答案 int null check(LogpracticeAnswer in(1,2,3,4))', 'user', dbo, 'table', LogPractice, 'column', LogPracticeAnswer
EXEC sp_addextendedproperty 'MS_Description', '作者练习时写的备注 text null', 'user', dbo, 'table', LogPractice, 'column', LogPracetimeRemark
GO

------------------------------------------------ 生成测试记录表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='LogTest')
drop table LogTest
create table LogTest-----保存平时测试信息（不包含测试试题）
	(
		LogTestId int identity(1,1) primary key,-----ID
		UserId int not null references Users(UserId),-----用户ID
		LogTestStartTime datetime not null default getdate(),-----测试时间
        LogTestEndTime datetime null,		
        PaperCodeId int not null references PaperCodes(PaperCodeId),-----科目ID
		DifficultyId int not null references Difficulty(DifficultyId),-----难度系数ID
		LogTestScore int not null default 0-----测试的得分，默认为0分
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '保存平时测试信息实例(不包含测试试题)', 'user',  dbo, 'table',  LogTest
EXEC sp_addextendedproperty 'MS_Description', 'ID int identity(1,1) primary key', 'user', dbo, 'table', LogTest, 'column', LogTestId
EXEC sp_addextendedproperty 'MS_Description', '外键,进行测试的用户 int not null references Users(UserId)', 'user', dbo, 'table', LogTest, 'column', UserId
EXEC sp_addextendedproperty 'MS_Description', '测试开始时间 datetime not null default getdate()', 'user', dbo, 'table', LogTest, 'column', LogTestStartTime
EXEC sp_addextendedproperty 'MS_Description', '测试结束时间(如果为null则表明试卷提交错误或没有正常提交) datetime null', 'user', dbo, 'table', LogTest, 'column', LogTestEndTime
EXEC sp_addextendedproperty 'MS_Description', '外键,测试的科目 int not null references PaperCodes(PaperCodeId)', 'user', dbo, 'table', LogTest, 'column', PaperCodeId
EXEC sp_addextendedproperty 'MS_Description', '外键,测试的难度系数 int not null references Difficulty(DifficultyId)', 'user', dbo, 'table', LogTest, 'column', DifficultyId
EXEC sp_addextendedproperty 'MS_Description', '测试的得分 int not null default 0', 'user', dbo, 'table', LogTest, 'column', LogTestScore
GO

------------------------------------------------ 生成测试习题表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='LogTestQuestion')
drop table LogTestQuestion
create table LogTestQuestion-----保存平时测试信息（包含试题信息）
	(
		LogTestQuestionId int identity(1,1) primary key,-----ID
		LogTestId int not null references LogTest(LogTestId),-----外键 测试信息ID
		QuestionId int not null references Question(QuestionId),-----外键 试题ID
		LogTestQuestionAnswer int null check(LogTestQuestionAnswer in(1,2,3,4)),-----测试时给出的答案
		LogTestQuestionRemark text null-----备注
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '保存平时测试试题实例', 'user',  dbo, 'table',  LogTestQuestion
EXEC sp_addextendedproperty 'MS_Description', 'ID int identity(1,1) primary key', 'user', dbo, 'table', LogTestQuestion, 'column', LogTestQuestionId
EXEC sp_addextendedproperty 'MS_Description', '外键,对应的测试信息 int not null references LogTest(LogTestId)', 'user', dbo, 'table', LogTestQuestion, 'column', LogTestId
EXEC sp_addextendedproperty 'MS_Description', '外键,对应的试题实例 int not null references Question(QuestionId)', 'user', dbo, 'table', LogTestQuestion, 'column', QuestionId
EXEC sp_addextendedproperty 'MS_Description', '测试时给出的答案 int null check(LogTestQuestionAnswer in(1,2,3,4))', 'user', dbo, 'table', LogTestQuestion, 'column', LogTestQuestionAnswer
EXEC sp_addextendedproperty 'MS_Description', '测试时用户给出的备注 text null', 'user', dbo, 'table', LogTestQuestion, 'column', LogTestQuestionRemark
GO

------------------------------------------------ 生成登录记录表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='LogLogin')
drop table LogLogin
create table LogLogin-----登录记录
	(
		LogLoginId int identity(1,1) primary key,-----ID
		UserId int not null references Users(UserID),-----用户ID
		LogLoginTime datetime not null default getdate(),-----登录时间
		LogLogoutTime datetime,-----登出时间
		LogLoginIp varchar(20) not null default('127.0.0.1'),-----登录IP
		LogLoginOperatiionSystem nvarchar(200) null,-----登录时所用的操作系统
		LogLoginWebServerClient varchar(100) null,-----登录时所用的浏览器类型
		Remark varchar(100) null-----备注
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '用户登录记录实例', 'user',  dbo, 'table',  LogLogin
EXEC sp_addextendedproperty 'MS_Description', 'ID int identity(1,1) primary key', 'user', dbo, 'table', LogLogin, 'column', LogLoginId
EXEC sp_addextendedproperty 'MS_Description', '外键,登录的用户 int not null references Users(UserID)', 'user', dbo, 'table', LogLogin, 'column', UserId
EXEC sp_addextendedproperty 'MS_Description', '用户登录的时间 datetime not null default getdate()', 'user', dbo, 'table', LogLogin, 'column', LogLoginTime
EXEC sp_addextendedproperty 'MS_Description', '用户退出的时间 datetime not null default getdate()', 'user', dbo, 'table', LogLogin, 'column', LogLogoutTime
EXEC sp_addextendedproperty 'MS_Description', '用户登录的IP varchar(20) not null default(''127.0.0.1'')', 'user', dbo, 'table', LogLogin, 'column', LogLoginIp
EXEC sp_addextendedproperty 'MS_Description', 'nvarchar(200) null,-----登录时所用的操作系统', 'user', dbo, 'table', LogLogin, 'column', LogLoginOperatiionSystem
EXEC sp_addextendedproperty 'MS_Description', 'varchar(100) null-----登录时所用的浏览器类型', 'user', dbo, 'table', LogLogin, 'column', LogLoginWebServerClient
EXEC sp_addextendedproperty 'MS_Description', 'varchar(100) null-----备注,0成功登录,1成功退出', 'user', dbo, 'table', LogLogin, 'column', Remark
GO

------------------------------------------------ 生成得分记录表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='UserScoreDetail')
drop table UserScoreDetail
create table UserScoreDetail-----用户得分的详细记录
	(
		UserScoreDetailId int identity(1,1) primary key,-----ID
		UserId int not null references Users(UserID),-----用户ID
		UserAuthorityId int not null references UserAuthority(UserAuthorityId),-----用户权限，可以理解为执行的操作，可以根据每个操作的得分值判断得分情况
		UserScoreDetailTime datetime not null default getdate()-----执行操作的时间
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '用户论坛分的得分详细记录实例', 'user',  dbo, 'table',  UserScoreDetail
EXEC sp_addextendedproperty 'MS_Description', 'ID int identity(1,1) primary key', 'user', dbo, 'table', UserScoreDetail, 'column', UserScoreDetailId
EXEC sp_addextendedproperty 'MS_Description', '外键,得分的用户 int not null references Users(UserID)', 'user', dbo, 'table', UserScoreDetail, 'column', UserId
EXEC sp_addextendedproperty 'MS_Description', '外键,用户权限,也即用户干什么事情得分 int not null references UserAuthority(UserAuthorityId)', 'user', dbo, 'table', UserScoreDetail, 'column', UserAuthorityId
EXEC sp_addextendedproperty 'MS_Description', '执行操作的时间 datetime not null default getdate()', 'user', dbo, 'table', UserScoreDetail, 'column', UserScoreDetailTime
GO

------------------------------------------------ 生成用户生成试卷信息 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='UserCreatePaper')
drop table UserCreatePaper
create table UserCreatePaper-----用于保存用户生成试卷信息（不包含试题信息）
	(
		UserCreatePaperId int identity(1,1) primary key,-----ID
		UserId int not null references Users(UserId),-----用户ID
		PaperCodeId int not null references PaperCodes(PaperCodeId),-----试卷代码Id
		DifficultyId int not null references Difficulty(DifficultyId),-----难度系数
		UserCreatePaperTime datetime not null default getdate()-----生成时间
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '保存用户生存试卷信息(不包含试题)实例', 'user',  dbo, 'table',  UserCreatePaper
EXEC sp_addextendedproperty 'MS_Description', 'ID int identity(1,1) primary key', 'user', dbo, 'table', UserCreatePaper, 'column', UserCreatePaperId
EXEC sp_addextendedproperty 'MS_Description', '外键,生成试卷的用户 int not null references Users(UserId)', 'user', dbo, 'table', UserCreatePaper, 'column', UserId
EXEC sp_addextendedproperty 'MS_Description', '外键,生成试卷的试卷代码 int not null references PaperCodes(PaperCodeId)', 'user', dbo, 'table', UserCreatePaper, 'column', PaperCodeId
EXEC sp_addextendedproperty 'MS_Description', '外键,生成试卷的难度系数 int not null references Difficulty(DifficultyId)', 'user', dbo, 'table', UserCreatePaper, 'column', DifficultyId
EXEC sp_addextendedproperty 'MS_Description', '生成时间 datetime not null default getdate()', 'user', dbo, 'table', UserCreatePaper, 'column', UserCreatePaperTime
GO

------------------------------------------------ 生成保存用户生成试卷包含试题记录表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='UserCreatePaperQuestione')
drop table UserCreatePaperQuestione
create table UserCreatePaperQuestione-----保存用户生成试卷信息（包含试题信息）
	(
		UserCreatePaperQuestioneId int identity(1,1) primary key,-----ID
		UserCreatePaperId int not null references UserCreatePaper(UserCreatePaperId),-----试卷信息ID
		QuestionId int not null references Question(QuestionId)-----试题ID
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '保存用户生成试卷的试题实例', 'user',  dbo, 'table',  UserCreatePaperQuestione
EXEC sp_addextendedproperty 'MS_Description', 'ID  int identity(1,1) primary key', 'user', dbo, 'table', UserCreatePaperQuestione, 'column', UserCreatePaperQuestioneId
EXEC sp_addextendedproperty 'MS_Description', '外键,试题所对应的生成试卷信息 int not null references UserCreatePaper(UserCreatePaperId)', 'user', dbo, 'table', UserCreatePaperQuestione, 'column', UserCreatePaperId
EXEC sp_addextendedproperty 'MS_Description', '外键,对应的试题 int not null references Question(QuestionId)', 'user', dbo, 'table', UserCreatePaperQuestione, 'column', QuestionId
GO

------------------------------------------------ 生成试题评论表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='Comment')
drop table Comment
create table Comment-----保存用户对试题的评论
	(
		CommentId int identity(1,1) primary key,-----ID
		QuestionId int not null references Question(QuestionId),-----外键 试题ID
		UserId int not null references Users(UserId),-----外键 用户ID
		CommentContent text not null,-----评论的内容
		CommentTime datetime not null default getdate(),-----发表评论的时间
		QuoteCommentId int null references Comment(CommentId),-----引用的评论
		IsDeleted bit not null default 0,-----是否删除	
		DeleteUserId int null references Users(UserId),-----外键 删除评论人
		DeleteCommentTime datetime null -----删除评论时间
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '用户对试题的评论实例', 'user',  dbo, 'table',  Comment
EXEC sp_addextendedproperty 'MS_Description', 'ID int identity(1,1) primary key', 'user', dbo, 'table', Comment, 'column', CommentId
EXEC sp_addextendedproperty 'MS_Description', '外键,评论所对应的试题 int not null references Question(QuestionId)', 'user', dbo, 'table', Comment, 'column', QuestionId
EXEC sp_addextendedproperty 'MS_Description', '外键,发表评论的用户 int not null references Users(UserId)', 'user', dbo, 'table', Comment, 'column', UserId
EXEC sp_addextendedproperty 'MS_Description', '评论内容 text not null', 'user', dbo, 'table', Comment, 'column', CommentContent
EXEC sp_addextendedproperty 'MS_Description', '评论时间 datetime not null default getdate()', 'user', dbo, 'table', Comment, 'column', CommentTime
EXEC sp_addextendedproperty 'MS_Description', '引用的评论 int null references Comment(CommentId)', 'user', dbo, 'table', Comment, 'column', QuoteCommentId
EXEC sp_addextendedproperty 'MS_Description', '是否删除 bit not null default 0', 'user', dbo, 'table', Comment, 'column', IsDeleted
EXEC sp_addextendedproperty 'MS_Description', '外键 删除评论人 int null references Users(UserId)', 'user', dbo, 'table', Comment, 'column', DeleteUserId
EXEC sp_addextendedproperty 'MS_Description', '删除评论时间 datetime null', 'user', dbo, 'table', Comment, 'column', DeleteCommentTime
GO

------------------------------------------------ 生成站内信表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='Message_table')
drop table Message_table
create table Message_table-----站内信
	(
		MessageId int identity(1,1) primary key,-----ID
		MessageParentId int null,-----如果是回复的话,标明回复哪一条站内信
		MessageTO int not null references Users(UserId),-----收信人
		MessageFrom int not null references Users(UserId),-----发信人
		MessageContent text not null,-----站内信内容
		MessageSendTime datetime default getdate(),-----发信时间
		MessageIsRead bit not null default 0,-----是否阅读
		MessageReadTime datetime null,-- check(if(MessageIsRead==1)MessageReadTime not null),-----阅读时间
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '站内信实例', 'user',  dbo, 'table',  Message_table
EXEC sp_addextendedproperty 'MS_Description', 'ID int identity(1,1) primary key', 'user', dbo, 'table', Message_table, 'column', MessageId
EXEC sp_addextendedproperty 'MS_Description', '自身的外键,如果是回复的话,标明回复哪一条站内信 int null ', 'user', dbo, 'table', Message_table, 'column', MessageParentId
EXEC sp_addextendedproperty 'MS_Description', '外键,收信用户 int not null references Users(UserId)', 'user', dbo, 'table', Message_table, 'column', MessageTO
EXEC sp_addextendedproperty 'MS_Description', '外键,发信用户 int not null references Users(UserId)', 'user', dbo, 'table', Message_table, 'column', MessageFrom
EXEC sp_addextendedproperty 'MS_Description', '信件内容 text not null', 'user', dbo, 'table', Message_table, 'column', MessageContent
EXEC sp_addextendedproperty 'MS_Description', '发送时间 datetime default getdate()', 'user', dbo, 'table', Message_table, 'column', MessageSendTime
EXEC sp_addextendedproperty 'MS_Description', '是否阅读标记 bit not null default 0', 'user', dbo, 'table', Message_table, 'column', MessageIsRead
EXEC sp_addextendedproperty 'MS_Description', '如果阅读,阅读时间 datetime null', 'user', dbo, 'table', Message_table, 'column', MessageReadTime
GO

------------------------------------------------ 生成搜索热词表 ------------------------------------------------

use OnLineTest
if exists (select*from sysobjects where name='SuggestionKeywords')
drop table SuggestionKeywords
create table SuggestionKeywords-----搜索的热词
	(
		SuggestionKeywordsId int identity(1,1) primary key,-----ID
		SuggestionKeywords varchar(100) not null,-----热词//这里要注意长度的问题,varchar100,只能存50个字符,nvarchar100可以存100个
		SuggestionKeywordsCreateTime datetime not null default getdate(),-----创建时间
		SuggestionKeywordsNum int not null-----搜索次数
	)
	
---参数说明:1\参数是属性的名称;2\添加属性所对应的值;3\層級 0 物件的類型;4\層級 0 物件類型的名稱;5\層級 1 物件的類型;6\層級 1 物件的名称;7\層級 2 物件的類型;8\層級 2 物件的名称
EXEC sp_addextendedproperty 'MS_Description',  '搜索的热词实例', 'user',  dbo, 'table',  SuggestionKeywords
EXEC sp_addextendedproperty 'MS_Description', 'int identity(1,1) primary key,-----ID', 'user', dbo, 'table', SuggestionKeywords, 'column', SuggestionKeywordsId
EXEC sp_addextendedproperty 'MS_Description', 'varchar(100) not null,-----热词//这里要注意长度的问题,varchar100,只能存50个字符,nvarchar100可以存100个', 'user', dbo, 'table', SuggestionKeywords, 'column', SuggestionKeywords
EXEC sp_addextendedproperty 'MS_Description', 'datetime not null default getdate(),-----创建时间', 'user', dbo, 'table', SuggestionKeywords, 'column', SuggestionKeywordsCreateTime
EXEC sp_addextendedproperty 'MS_Description', 'int not null-----搜索次数', 'user', dbo, 'table', SuggestionKeywords, 'column', SuggestionKeywordsNum
GO

--============================================= 生成存储过程部分 ================================================
------------------------------------------------ 根据用户ID统计得分明细--------------------------------------
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].UserScoreDetailByUserId') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].UserScoreDetailByUserId
GO
create procedure UserScoreDetailByUserId( --创建存储过程，定义几个变量
@UserId int
)
as
select * from(
	select userscoredetailid,userid,a.userauthorityid,userscoredetailtime,authorityid,usergroupid,userrankid,userauthoriryremark 
	from userscoredetail as a  right join userauthority  as b on a.userauthorityid=b.userauthorityid where a.Userid=@UserId
	) as c 
		inner join authority as d 
			on c.authorityid=d.authorityid
			go
--declare
--@id int;
--set @id=1;
--exec UserScoreDetailByUserId @id
------------------------------------------------ 根据用户ID统计得分收入总量和得分条数--------------------------------------
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].ShouruUserScoreDetailByUserId') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].ShouruUserScoreDetailByUserId
GO
create procedure ShouruUserScoreDetailByUserId(
@UserId int, 
@shouru int out,
@num int out)
as
select @num=count(*), @shouru=sum(authorityscore) from(
	select userscoredetailid,userid,a.userauthorityid,userscoredetailtime,authorityid,usergroupid,userrankid,userauthoriryremark 
	from userscoredetail as a  right join userauthority  as b on a.userauthorityid=b.userauthorityid where a.Userid=@UserId
	) as c 
		inner join authority as d 
			on c.authorityid=d.authorityid
			 where authorityscore>0
go

--declare
--@id int,
--@shouru int,
--@s int;
--set @id=1;
--exec ShouruUserScoreDetailByUserId @id,@shouru out,@s out
--select @shouru, @s


------------------------------------------------ 根据用户ID统计得分支出问题--------------------------------------
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].ZhichuUserScoreDetailByUserId') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].ZhichuUserScoreDetailByUserId
GO
create procedure ZhichuUserScoreDetailByUserId( --创建存储过程，定义几个变量
@UserId int, 
@shouru int out,
@num int out)
as
select @num=count(*), @shouru=sum(authorityscore) from(
	select userscoredetailid,userid,a.userauthorityid,userscoredetailtime,authorityid,usergroupid,userrankid,userauthoriryremark 
	from userscoredetail as a  right join userauthority  as b on a.userauthorityid=b.userauthorityid where a.Userid=@UserId
	) as c 
		inner join authority as d 
			on c.authorityid=d.authorityid
			 where authorityscore<0
go

--declare
--@id int,
--@shouru int,
--@s int;
--set @id=1;
--exec ZhichuUserScoreDetailByUserId @id,@shouru out,@s out
--select @shouru, @s

------------------------------------------------ 对于Authority表的增删改存储过程(注意调整其中的排序)--------------------------------------
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].OperateAuthoritybyTran') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].OperateAuthoritybyTran
GO
create procedure OperateAuthoritybyTran --创建存储过程，定义几个变量
@model nvarchar(20)=null,
@AuthorityId int=-1 ,
@AuthorityName nvarchar(20)=null,
@AuthorityDeep int=null,
@AuthorityParentId int=null,
@AuthorityScore int=null,
@AuthorityHandlerPage varchar(50)=null,
@AuthorityOrderNum int=null, 
@AuthorityRemark text=null
as 
set  XACT_ABORT on;  --设置是否自动回滚
declare @result int;
set @result=@AuthorityId;
begin tran --开始执行事务
if @model='add'
begin
update Authority set AuthorityOrderNum+=1 where AuthorityParentId=@AuthorityParentId and AuthorityOrderNum>=@AuthorityOrderNum;
INSERT INTO [OnLineTest].[dbo].[Authority]
           ([AuthorityName]
           ,[AuthorityDeep]
           ,[AuthorityParentId]
           ,[AuthorityScore]
           ,[AuthorityHandlerPage]
           ,[AuthorityOrderNum]
           ,[AuthorityRemark])
     VALUES
          (@AuthorityName
           ,@AuthorityDeep
           ,@AuthorityParentId
           ,@AuthorityScore
           ,@AuthorityHandlerPage
           ,@AuthorityOrderNum
           ,@AuthorityRemark);
           select @result=@@IDENTITY;
end
else if @model='delete'
begin
update Authority set AuthorityOrderNum-=1 where AuthorityParentId=@AuthorityParentId and AuthorityOrderNum>@AuthorityOrderNum;
delete from Authority where AuthorityId=@AuthorityId;
end
else if @model='update'
begin
declare @OriginalAuthorityParentId int,@OriginalAutorityOrderNum int;
select @OriginalAuthorityParentId=AuthorityParentId,@OriginalAutorityOrderNum=AuthorityOrderNum from Authority where AuthorityId=@AuthorityId;
update Authority set AuthorityOrderNum-=1 where AuthorityParentId=@OriginalAuthorityParentId and AuthorityOrderNum>=@OriginalAutorityOrderNum;
update Authority set AuthorityOrderNum+=1 where AuthorityParentId=@AuthorityParentId and AuthorityOrderNum>=@AuthorityOrderNum;
UPDATE [OnLineTest].[dbo].[Authority]
   SET [AuthorityName] = @AuthorityName
      ,[AuthorityDeep] = @AuthorityDeep
      ,[AuthorityParentId] = @AuthorityParentId
      ,[AuthorityScore] = @AuthorityScore
      ,[AuthorityHandlerPage] = @AuthorityHandlerPage
      ,[AuthorityOrderNum] = @AuthorityOrderNum
      ,[AuthorityRemark] = @AuthorityRemark
 WHERE AuthorityId=@AuthorityId
end
commit tran --在以上操作过程中如果没有错误，则提交执行，否则会自动执行回滚
return @result;
go
------------------------------------------------ 插入网站权限数据的存储过程 ------------------------------------------------
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].InsertAuthorityData') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
-- 删除存储过程
drop procedure [dbo].InsertAuthorityData
GO
CREATE PROC InsertAuthorityData 
@AuthorityName nvarchar(20),
@AuthorityDeep int,
@AuthorityParentId int,
@AuthorityScore int,
@AuthorityHandlerPage varchar(50),
@AuthorityOrderNum int, 
@AuthorityRemark text
AS 
declare @ID int;
if @ID is null
begin 
Set @ID = 0
end 
else 
begin 
set @ID=@@IDENTITY
end 
INSERT INTO [OnLineTest].[dbo].[Authority]
           ([AuthorityName]
           ,[AuthorityDeep]
           ,[AuthorityParentId]
           ,[AuthorityScore]
           ,[AuthorityHandlerPage]
           ,[AuthorityOrderNum]
           ,[AuthorityRemark])
     VALUES
          (@AuthorityName
           ,@AuthorityDeep
           ,@AuthorityParentId
           ,@AuthorityScore
           ,@AuthorityHandlerPage
           ,@AuthorityOrderNum
           ,@AuthorityRemark)
GO


--============================================= 插入有效数据部分 ================================================


----------------------------------------------- 初始化超级管理员 ------------------------------------------------
INSERT INTO [OnLineTest].[dbo].[UserGroup]
           ([UserGroupName]
           ,[UserGroupRemark])
     VALUES
           (
           '超级管理员',
           '超级管理员'
           )
declare @GroupId int;
set @GroupId=@@IDENTITY;
INSERT INTO [OnLineTest].[dbo].[Users]
           ([UserName]
           ,[UserPassword]
           ,[UserChineseName]
           ,[UserEmail]
           ,[IsValidate]
           ,[Tel]
           ,[UserScore]
           ,[UserGroupId])
     VALUES
           ('yxshu'
           ,'774366b94a31723caedecca846cf2d60'
           ,'余项树'
           ,'yxshu@qq.com'
           ,1
           ,'15872367795'
           ,0
           ,@GroupId)
GO

------------------------------------------------ 插入网站权限数据 ------------------------------------------------
--参数的意义
--@AuthorityName nvarchar(20),
--@AuthorityDeep int,
--@AuthorityParentId int,
--@AuthorityScore int,
--@AuthorityHandlerPage varchar(50),
--@AuthorityOrderNum int, 
--@AuthorityRemark text
declare @id int;
EXECUTE  InsertAuthorityData '账户管理',0,0 ,0,'AccountManager',1,'账户管理-一级目录'
set @id=@@IDENTITY;
EXECUTE  InsertAuthorityData '个人中心',1,@id,0,'IndividualCenter.aspx',1,'个人中心-二级目录'
--EXECUTE  InsertAuthorityData '设置等级',1,@id,0,'SetUserRank.aspx',2,'设置等级-二级目录'
EXECUTE  InsertAuthorityData '编辑用户组',1,@id,0,'EditUserGroup.aspx',3,'编辑用户组-二级目录'
Go
declare @id int;
EXECUTE  InsertAuthorityData '测试与练习',0,0 ,0,'TestAndPractice',2,'测试与练习-一级目录'
set @id=@@IDENTITY;
EXECUTE  InsertAuthorityData '编辑试题',1,@id,0,'EditQuestion.aspx',1,'编辑试题-二级目录，只能编辑本人新增的且没有审核的试题，包括新增'
EXECUTE  InsertAuthorityData '日常练习',1,@id,0,'Practice.aspx',2,'日常练习-二级目录'
EXECUTE  InsertAuthorityData '按章练习',1,@id,0,'PracticeByChapter.aspx',3,'按章练习-二级目录'
EXECUTE  InsertAuthorityData '练习真题',1,@id,0,'PracticeAuthorityQuestion.aspx',4,'练习真题-二级目录'
EXECUTE  InsertAuthorityData '模拟考试',1,@id,0,'SimulateTest.aspx',5,'模拟考试-二级目录'
EXECUTE  InsertAuthorityData '真题考试',1,@id,0,'TestAuthorityQuestion.aspx',6,'真题考试-二级目录'
EXECUTE  InsertAuthorityData '审核试题',1,@id,0,'VerifyQuestion.aspx',7,'审核试题-二级目录'
EXECUTE  InsertAuthorityData '终审试题',1,@id,0,'FinalVerityQuestion.aspx',8,'终审试题-二级目录'
--EXECUTE  InsertAuthorityData '设置难度系数',1,@id,0,'SetDifficulty.aspx',9,'设置难度系数-二级目录'
EXECUTE  InsertAuthorityData '生成模拟试卷',1,@id,0,'CreateSimulatePaper.aspx',10,'生成模拟试卷-二级目录'
Go
declare @id int;
EXECUTE  InsertAuthorityData '试题评论',0,0 ,0,'Comment',3,'试题评论-一级目录'
set @id=@@IDENTITY;
EXECUTE  InsertAuthorityData '查看评论',1,@id,0,'ChckComment.aspx',1,'查看评论-二级目录'
Go
declare @id int;
EXECUTE  InsertAuthorityData '查看记录',0,0 ,0,'CheckRecord',4,'查看记录-一级目录'
set @id=@@IDENTITY;
EXECUTE  InsertAuthorityData '创建试题记录',1,@id,0,'CheckCreateQuestionLog.aspx',1,'创建试题记录-二级目录'
EXECUTE  InsertAuthorityData '查看练习记录',1,@id,0,'CheckLogPractice.aspx',2,'查看练习记录-二级目录'
EXECUTE  InsertAuthorityData '查看测试记录',1,@id,0,'CheckLogTest.aspx',3,'查看测试记录-二级目录'
EXECUTE  InsertAuthorityData '查看登录记录',1,@id,0,'CheckLogLogin.aspx',4,'查看登录记录-二级目录'
EXECUTE  InsertAuthorityData '审核试题记录',1,@id,0,'CheckVerifyQuestionLog.aspx',5,'审核试题记录-二级目录'
EXECUTE  InsertAuthorityData '查看得分记录',1,@id,0,'CheckUserScoreDetail.aspx',6,'查看得分记录-二级目录'
EXECUTE  InsertAuthorityData '查看生成试卷记录',1,@id,0,'CheckUserCreatePaperLog.aspx',7,'查看生成试卷记录-二级目录'
Go
declare @id int;
EXECUTE  InsertAuthorityData '站内信',0,0 ,0,'InsideMessage',5,'站内信-一级目录'
set @id=@@IDENTITY;
EXECUTE  InsertAuthorityData '查看站内信',1,@id,0,'CheckInsideMessage.aspx',1,'查看站内信-二级目录'
Go
declare @id int;
EXECUTE  InsertAuthorityData '历年真题',0,0 ,0,'AuthorityQuesetion',6,'历年真题-一级目录'
set @id=@@IDENTITY;
EXECUTE  InsertAuthorityData '查看真题信息',1,@id,0,'CheckPastExamPaper.aspx',1,'查看真题信息-二级目录'
--EXECUTE  InsertAuthorityData '审核考试信息',1,@id,0,'VerityPastExamPaper.aspx',2,'审核考试信息-二级目录'
EXECUTE  InsertAuthorityData '查看考区信息',1,@id,0,'CheckExamZone.aspx',3,'查看考区信息-二级目录'
--EXECUTE  InsertAuthorityData '审核考区信息',1,@id,0,'VerifyExamZone.aspx',4,'审核考区信息-二级目录'
Go
declare @id int;
EXECUTE  InsertAuthorityData '权限维护',0,0 ,0,'RightMaintenance',7,'权限维护-一级目录'
set @id=@@IDENTITY;
EXECUTE  InsertAuthorityData '编辑根权限',1,@id,0,'EditAuthority.aspx',1,'编辑根权限-二级目录'
EXECUTE  InsertAuthorityData '编辑用户权限',1,@id,0,'EditUserAuthority.aspx',2,'编辑用户权限-二级目录'
Go
declare @id int;
EXECUTE  InsertAuthorityData '科目设置',0,0 ,0,'SubjectSet',8,'科目设置-一级目录'
set @id=@@IDENTITY;
EXECUTE  InsertAuthorityData '查看科目',1,@id,0,'CheckSubject.aspx',1,'查看科目-二级目录'
--EXECUTE  InsertAuthorityData '审核科目',1,@id,0,'VerifySubject.aspx',2,'审核科目-二级目录'
EXECUTE  InsertAuthorityData '查看代码',1,@id,0,'CheckPaperCodes.aspx',3,'查看代码-二级目录'
--EXECUTE  InsertAuthorityData '审核代码',1,@id,0,'VerityPaperCodes.aspx',4,'审核代码-二级目录'
Go
declare @id int;
EXECUTE  InsertAuthorityData '教材维护',0,0 ,0,'TextbookMaintenance',9,'教材维护-一级目录'
set @id=@@IDENTITY;
EXECUTE  InsertAuthorityData '查看教材信息',1,@id,0,'CheckTextBook.aspx',1,'查看教材信息-二级目录'
EXECUTE  InsertAuthorityData '审核教材信息',1,@id,0,'VerityTextBook.aspx',2,'审核教材信息-二级目录'
EXECUTE  InsertAuthorityData '查看章节信息',1,@id,0,'CheckChapter.aspx',3,'查看章节信息-二级目录'
EXECUTE  InsertAuthorityData '审核章节信息',1,@id,0,'VerityChapter.aspx',4,'审核章节信息-二级目录'
Go
declare @id int;
EXECUTE  InsertAuthorityData '其它',0,0 ,0,'Other',10,'其它-一级目录'
set @id=@@IDENTITY;
EXECUTE  InsertAuthorityData '搜索关键词',1,@id,0,'EditSuggestionKeywords.aspx',1,'搜索关键词-二级目录'
Go
---============================================= 插入测试数据部分 =============================================


------------------------------------------------ 插入用户组测试数据 ------------------------------------------------

declare @CommUserGroupId int;
declare @StuUserGroupId int;
declare @TeaUserGroupId int;
declare @1admUserGroupId int;
declare @2admUserGroupId int;
declare @3admUserGroupId int;
INSERT INTO [OnLineTest].[dbo].[UserGroup]
           ([UserGroupName]
           ,[UserGroupRemark])
     VALUES
           (
           '普通用户',
           '具有最低权限的普通用户'
           )
set @CommUserGroupId=@@IDENTITY;
INSERT INTO [OnLineTest].[dbo].[UserGroup]
           ([UserGroupName]
           ,[UserGroupRemark])
     VALUES
           (
           '学生用户',
           '学生用户'
           )
set @StuUserGroupId=@@IDENTITY;
INSERT INTO [OnLineTest].[dbo].[UserGroup]
           ([UserGroupName]
           ,[UserGroupRemark])
     VALUES
           (
           '教师用户',
           '教师用户'
           )
set @TeaUserGroupId=@@IDENTITY;
INSERT INTO [OnLineTest].[dbo].[UserGroup]
           ([UserGroupName]
           ,[UserGroupRemark])
     VALUES
           (
           '一级管理员',
           '一级管理员'
           )
set @1admUserGroupId=@@IDENTITY;
INSERT INTO [OnLineTest].[dbo].[UserGroup]
           ([UserGroupName]
           ,[UserGroupRemark])
     VALUES
           (
           '二级管理员',
           '二级管理员'
           )
set @2admUserGroupId=@@IDENTITY;
INSERT INTO [OnLineTest].[dbo].[UserGroup]
           ([UserGroupName]
           ,[UserGroupRemark])
     VALUES
           (
           '三级管理员',
           '三级管理员'
           )
set @3admUserGroupId=@@IDENTITY;
------------------------------------------------ 插入用户测试数据 ------------------------------------------------
INSERT INTO [OnLineTest].[dbo].[Users]
           ([UserName]
           ,[UserPassword]
           ,[UserChineseName]
           ,[UserEmail]
           ,[IsValidate]
           ,[Tel]
           ,[UserScore]
           ,[UserGroupId])
     VALUES
           ('common'
           ,'774366b94a31723caedecca846cf2d60'
           ,'余项树'
           ,'common@qq.com'
           ,1
           ,'15848755795'
           ,23
           ,@CommUserGroupId)
INSERT INTO [OnLineTest].[dbo].[Users]
           ([UserName]
           ,[UserPassword]
           ,[UserChineseName]
           ,[UserEmail]
           ,[IsValidate]
           ,[Tel]
           ,[UserScore]
           ,[UserGroupId])
     VALUES
           ('thirdadmin'
           ,'774366b94a31723caedecca846cf2d60'
           ,'余项树3GradeAdmin'
           ,'thirdadmin@qq.com'
           ,1
           ,'15898745795'
           ,45
           ,@3admUserGroupId)
INSERT INTO [OnLineTest].[dbo].[Users]
           ([UserName]
           ,[UserPassword]
           ,[UserChineseName]
           ,[UserEmail]
           ,[IsValidate]
           ,[Tel]
           ,[UserScore]
           ,[UserGroupId])
     VALUES
           ('secondadmin'
           ,'774366b94a31723caedecca846cf2d60'
           ,'余项树2GradeAdmin'
           ,'secondadmin@qq.com'
           ,1
           ,'15872367795'
           ,99
           ,@2admUserGroupId)
INSERT INTO [OnLineTest].[dbo].[Users]
           ([UserName]
           ,[UserPassword]
           ,[UserChineseName]
           ,[UserEmail]
           ,[IsValidate]
           ,[Tel]
           ,[UserScore]
           ,[UserGroupId])
     VALUES
           ('firstadmin'
           ,'774366b94a31723caedecca846cf2d60'
           ,'余项树1GradeAdmin'
           ,'firstadmin@qq.com'
           ,1
           ,'15872367795'
           ,68
           ,@1admUserGroupId)
INSERT INTO [OnLineTest].[dbo].[Users]
           ([UserName]
           ,[UserPassword]
           ,[UserChineseName]
           ,[UserEmail]
           ,[IsValidate]
           ,[Tel]
           ,[UserScore]
           ,[UserGroupId])
     VALUES
           ('teacher'
           ,'774366b94a31723caedecca846cf2d60'
           ,'余项树Teacher'
           ,'teacher@qq.com'
           ,1
           ,'15872367795'
           ,36
           ,@TeaUserGroupId)
INSERT INTO [OnLineTest].[dbo].[Users]
           ([UserName]
           ,[UserPassword]
           ,[UserChineseName]
           ,[UserEmail]
           ,[IsValidate]
           ,[Tel]
           ,[UserScore]
           ,[UserGroupId])
     VALUES
           ('student'
           ,'774366b94a31723caedecca846cf2d60'
           ,'余项树Student'
           ,'student@qq.com'
           ,1
           ,'15872367795'
           ,90
           ,@StuUserGroupId)
GO
------------------------------------------------ 插入用户等级测试数据 ------------------------------------------------

INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('轮机助理(Assistant engineer)'
           ,0
           ,10)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('驾驶助理(Cadet)'
           ,11
           ,30)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('二水(OS)'
           ,31
           ,50)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('机工(Motor)'
           ,51
           ,75)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('一水(AB)'
           ,76
           ,100)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('二厨(Second cook)'
           ,101
           ,140)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('管事(Purser)'
           ,141
           ,200)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('木匠(carpenter)'
           ,201
           ,250)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('大厨(Chief cook)'
           ,201
           ,300)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('机工长( No.1 motorman)'
           ,301
           ,350)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('水手长(Bosun)'
           ,351
           ,450)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('三管轮(Fourth engineer)'
           ,451
           ,520)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('三副(Third office)'
           ,521
           ,590)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('二管轮(Third engineer)'
           ,591
           ,660)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('二副(Second officer)'
           ,661
           ,730)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('电子电气员(Electrical engineer)'
           ,731
           ,900)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('大管轨(Second engineer)'
           ,901
           ,1000)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('大副(Chief officer)'
           ,1001
           ,1100)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('政委'
           ,1101
           ,1200)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('轮机长(Chief engineer)'
           ,1201
           ,1300)
           INSERT INTO [OnLineTest].[dbo].[UserRank]
           ([UserRankName]
           ,[MinScore]
           ,[MaxScore])
     VALUES
           ('船长(Captain/Master)'
           ,1301
           ,65535)
GO
  ------------------------------------------------ 插入试题难度测试数据 ------------------------------------------------

INSERT INTO [OnLineTest].[dbo].[Difficulty]
           (DifficultyRatio
           ,[DifficultyDescrip])
     VALUES
           (0
           ,'不确定') 
  INSERT INTO [OnLineTest].[dbo].[Difficulty]
           (DifficultyRatio
           ,[DifficultyDescrip])
     VALUES
           (1
           ,'容易') 
  INSERT INTO [OnLineTest].[dbo].[Difficulty]
           (DifficultyRatio
           ,[DifficultyDescrip])
     VALUES
           (2
           ,'一般般') 
  INSERT INTO [OnLineTest].[dbo].[Difficulty]
           (DifficultyRatio
           ,[DifficultyDescrip])
     VALUES
           (3
           ,'还可以') 
  INSERT INTO [OnLineTest].[dbo].[Difficulty]
           (DifficultyRatio
           ,[DifficultyDescrip])
     VALUES
           (4
           ,'不简单') 
  INSERT INTO [OnLineTest].[dbo].[Difficulty]
           (DifficultyRatio
           ,[DifficultyDescrip])
     VALUES
           (5
           ,'有点意思') 
  INSERT INTO [OnLineTest].[dbo].[Difficulty]
           (DifficultyRatio
           ,[DifficultyDescrip])
     VALUES
           (6
           ,'有点难') 
  INSERT INTO [OnLineTest].[dbo].[Difficulty]
           (DifficultyRatio
           ,[DifficultyDescrip])
     VALUES
           (7
           ,'比较难') 
  INSERT INTO [OnLineTest].[dbo].[Difficulty]
           (DifficultyRatio
           ,[DifficultyDescrip])
     VALUES
           (8
           ,'相当难') 
  INSERT INTO [OnLineTest].[dbo].[Difficulty]
           (DifficultyRatio
           ,[DifficultyDescrip])
     VALUES
           (9
           ,'非常难') 
  INSERT INTO [OnLineTest].[dbo].[Difficulty]
           (DifficultyRatio
           ,[DifficultyDescrip])
     VALUES
           (10
           ,'难爆啦') 
GO     
------------------------------------------------ 插入用户权限测试数据(待整理) ------------------------------------------------

--INSERT INTO [OnLineTest].[dbo].[UserAuthority]
--           ([AuthorityId]
--           ,[UserGroupId]
--           ,[UserRankId]
--           ,[UserAuthoriryRemark])
--     VALUES
--           (1
--           ,1
--           ,1
--           ,'注册')
--Go
------------------------------------------------ 插入科目测试数据 ------------------------------------------------
declare @collistion int , @navigation int,  @struction int,  @manager int,@english int;
declare @Genglisth int, @Gyewu int;
declare @salioryewi int, @Hsalioryewu int, @Hsaliorenglish int;
declare @lenglish int,@ldongli int,@lzhuji int,@lfuji int,@ldianqi int,@lguanli int;
declare @jgyewu int,@Hjgyewu int,@Hjgyiyu int;
declare @dzdqdianqi int,@dzdqzidonghua int,@dzdqdaohang int,@dzdqgunali int,@dzdqyingwu int;
declare @dzjgyewu int,@dzjgyiyu int;
declare @Z01GRAQ INT,@Z01GRQS INT,@Z01FHMH INT,@Z01JBJJ INT;
declare @Z02JTJSTF INT,@Z04GJXF INT,@Z05JTJJ INT;
--declare @collistion  @navigation  @struction  @manager @english int,


INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('船舶操纵与避碰'
           ,'驾驶专业船舶操纵与避碰'
           ,1)    
set @collistion=@@identity;	
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('航海学'
           ,'驾驶专业航海学'
           ,1)
set @navigation=@@identity;
	   
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('船舶结构与货运'
           ,'驾驶专业船舶结构与货运'
           ,1)
set @struction=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('船舶管理'
           ,'驾驶专业船舶管理'
           ,1)
set @manager=@@identity;		   
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('航海英语'
           ,'驾驶专业航海英语'
           ,1)
set @english=@@identity;
		   
-- declare @Genglisth  @Gyewu int,
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('GMDSS英语'
           ,'GMDSS英语'
           ,1)
set @Genglisth=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('GMDSS综合业务'
           ,'GMDSS综合业务'
           ,1)
set @Gyewu=@@identity;
-- declare @salioryewi @Hsalioryewu  @Hsaliorenglish int,
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('值班水手业务'
           ,'驾驶专业值班水手业务'
           ,1)
set @salioryewi=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('高级值班水手业务'
           ,'驾驶专业高级值班水手业务'
           ,1)
set @Hsalioryewu=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('高级值班水手英语'
           ,'驾驶专业高级值班水手英语'
           ,1)
set @Hsaliorenglish=@@identity;
-- declare @lenglish @ldongli @lzhuji @lfuji @ldianqi @lguanli int
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('轮机英语'
           ,'轮机专业轮机英语'
           ,1)
set @lenglish=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('船舶动力装置'
           ,'轮机专业船舶动力装置'
           ,1)
set @ldongli=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('主推进动力装置'
           ,'轮机专业主推进动力装置'
           ,1)
set @lzhuji=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('船舶辅机'
           ,'轮机专业船舶辅机'
           ,1)
set @lfuji=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('船舶电气与自动化'
           ,'轮机专业船舶电气与自动化'
           ,1)
set @ldianqi=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('船舶管理'
           ,'轮机专业船舶管理'
           ,1)
set @lguanli=@@identity;
--declare @jgyewu @Hjgyewu @Hjgyiyu int,
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('值班机工业务'
           ,'轮机专业值班机工业务'
           ,1)
set @jgyewu=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('高级值班机工业务'
           ,'轮机专业高级值班机工业务'
           ,1)
set @Hjgyewu=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('高级值班机工英语'
           ,'轮机专业高级值班机工英语'
           ,1)
set @Hjgyiyu=@@identity;
--declare @dzdqdianqi @dzdqzidonghua @dzdqdaohang @dzdqgunali @dzdqyingwu int,
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('船舶电气'
           ,'电子电气员船舶电气'
           ,1)
set @dzdqdianqi=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('船舶机舱自动化'
           ,'电子电气员船舶机舱自动化'
           ,1)
set @dzdqzidonghua=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('信息技术与通信导航系统'
           ,'电子电气员信息技术与通信导航系统'
           ,1)
set @dzdqdaohang=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('船舶管理'
           ,'电子电气员船舶管理'
           ,1)
set @dzdqgunali=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('电子员英语'
           ,'电子电气员电子员英语'
           ,1)
set @dzdqyingwu=@@identity;
--declare @dzjgyewu @dzjgyiyu int;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('电子技工业务'
           ,'电子技工电子技工业务'
           ,1)
set @dzjgyewu=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('电子技工英语'
           ,'电子技工电子技工英语'
           ,1)
set @dzjgyiyu=@@identity;


/*declare @Z01GRAQ INT,@Z01GRQS INT,@Z01FHMH INT,@Z01JBJJ INT;
declare @Z02JTJSTF INT,@Z04GJXF INT,@Z05JTJJ INT;*/

INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('个人安全与社会责任'
           ,'基本安全培训-个人安全与社会责任'
           ,1)
set @Z01GRAQ=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('个人求生'
           ,'基本安全培训-个人求生'
           ,1)
set @Z01GRQS=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('防火与灭火'
           ,'基本安全培训-防火与灭火'
           ,1)
set @Z01FHMH=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('基本急救'
           ,'基本安全培训-基本急救'
           ,1)
set @Z01JBJJ=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('精通救生艇筏与救助艇培训'
           ,'Z02-精通救生艇筏与救助艇培训'
           ,1)
set @Z02JTJSTF=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('高级消防'
           ,'Z04-高级消防'
           ,1)
set @Z04GJXF=@@identity;
INSERT INTO [OnLineTest].[dbo].[Subject]
           ([SubjectName]
           ,[SubjectRemark]
           ,[IsVerified])
     VALUES
           ('精通急救'
           ,'Z05-精通急救'
           ,1)
set @Z05JTJJ=@@identity;

------------------------------------------------ 插入试卷代码测试数据 ------------------------------------------------
/* (
		PaperCodeId int identity(1,1) primary key,-----试卷代码ID
		SubjectId int not null references Subject(SubjectId),-----试卷代码所对应的科目ID，外键
		PaperCode int not null unique,-----试卷代码
		ChineseName nvarchar(100) not null,-----试卷代码所对应的中文名称
		PaperCodePassScore int not null,-----试卷代码的及格分数线
		PaperCodeTotalScore int not null,-----试卷代码的总分
		TimeRange int not null,-----试卷代码考试的时长
		PaperCodeRemark text null,-----试卷代码的备注
		IsVerified bit not null default(0),-----是否通过审核标记
		foreign key(SubjectId) references Subject(SubjectId),-----设置外键
		CONSTRAINT CK_UserRank CHECK (PaperCodePassScore>0 AND PaperCodeTotalScore>0 and PaperCodeTotalScore>PaperCodePassScore and TimeRange>0)-----设置几个值的约束
	) */

/*
declare @collistion  @navigation  @struction  @manager @english int,
declare @Genglisth  @Gyewu int,
declare @salioryewi @Hsalioryewu  @Hsaliorenglish int,
declare @lenglish @ldongli @lzhuji @lfuji @ldianqi @lguanli int,
declare @jgyewu @Hjgyewu @Hjgyiyu int,
declare @dzdqdianqi @dzdqzidonghua @dzdqdaohang @dzdqgunali @dzdqyingwu int,
declare @dzjgyewu @dzjgyiyu int;
	*/
	
declare @9205 int,@9105 int,@9303 int,@9405 int,@9003 int;	
declare @Z011GRAQ INT,@Z012GRQS INT,@Z013FHMH INT,@Z014JBJJ INT;
declare @Z020JTJSTF INT,@Z040GJXF INT,@Z050JTJJ INT;
	--@collistion 
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@collistion 
           ,9101
           ,'3000总吨及以上船舶船长'
           ,80
           ,100
           ,120
           ,1)
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@collistion 
           ,9102
           ,'500～3000总吨船舶船长'
           ,80
           ,100
           ,120
           ,1)	
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@collistion 
           ,9103
           ,'3000总吨及以上船舶大副'
           ,80
           ,100
           ,120
           ,1)	
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@collistion 
           ,9104
           ,'500～3000总吨船舶大副'
           ,80
           ,100
           ,120
           ,1)	
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@collistion 
           ,9105
           ,'3000总吨及以上船舶二/三副'
           ,80
           ,100
           ,120
           ,1)	
	set @9105=@@IDENTITY;
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@collistion 
           ,9106
           ,'500～3000总吨船舶二/三副'
           ,80
           ,100
           ,120
           ,1)	
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@collistion 
           ,9107
           ,'未满500总吨船舶船长'
           ,80
           ,100
           ,120
           ,1)	
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@collistion 
           ,9108
           ,'未满500总吨船舶大副'
           ,80
           ,100
           ,120
           ,1)	
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@collistion 
           ,9109
           ,'未满500总吨船舶二/三副'
           ,80
           ,100
           ,120
           ,1)			   
	--@navigation
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@navigation 
           ,9201
           ,'无限航区500总吨及以上船舶船长'
           ,70
           ,100
           ,120
           ,1)
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@navigation 
           ,9202
           ,'沿海航区500总吨及以上船舶船长'
           ,70
           ,100
           ,120
           ,1)
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@navigation 
           ,9203
           ,'无限航区500总吨及以上船舶大副'
           ,70
           ,100
           ,120
           ,1)
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@navigation 
           ,9204
           ,'沿海航区500总吨及以上船舶大副'
           ,70
           ,100
           ,120
           ,1)
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@navigation 
           ,9205
           ,'无限航区500总吨及以上船舶二/三副'
           ,70
           ,100
           ,120
           ,1)
    set @9205=@@IDENTITY;
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@navigation 
           ,9206
           ,'沿海航区500总吨及以上船舶二/三副'
           ,70
           ,100
           ,120
           ,1)
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@navigation 
           ,9207
           ,'未满500总吨船舶船长'
           ,70
           ,100
           ,120
           ,1)
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@navigation 
           ,9208
           ,'未满500总吨船舶大副'
           ,70
           ,100
           ,120
           ,1)
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@navigation 
           ,9209
           ,'未满500总吨船舶二/三副'
           ,70
           ,100
           ,120
           ,1)		   
	--@struction 
		INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@struction 
           ,9301
           ,'3000总吨及以上船舶船长/大副'
           ,70
           ,100
           ,120
           ,1)
		   		INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@struction 
           ,9302
           ,'500～3000总吨船舶船长/大副'
           ,70
           ,100
           ,120
           ,1)
		   		INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@struction 
           ,9303
           ,'3000总吨及以上船舶二/三副'
           ,70
           ,100
           ,120
           ,1)
    set @9303=@@IDENTITY;
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@struction 
           ,9304
           ,'500～3000总吨船舶二/三副'
           ,70
           ,100
           ,120
           ,1)
		   		INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@struction 
           ,9305
           ,'未满500总吨船舶大副'
           ,70
           ,100
           ,120
           ,1)
		   		INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@struction 
           ,9306
           ,'未满500总吨船舶二/三副'
           ,70
           ,100
           ,120
           ,1)
	--@manager 
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@manager 
           ,9401
           ,'无限航区500总吨及以上船舶船长'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@manager 
           ,9402
           ,'沿海航区500总吨及以上船舶船长'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@manager 
           ,9403
           ,'无限航区500总吨及以上船舶大副'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@manager 
           ,9404
           ,'沿海航区500总吨及以上船舶大副'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@manager 
           ,9405
           ,'无限航区500总吨及以上船舶二/三副'
           ,70
           ,100
           ,120
           ,1)
    set @9405=@@IDENTITY;
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@manager 
           ,9406
           ,'沿海航区500总吨及以上船舶二/三副'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@manager 
           ,9407
           ,'未满500总吨船舶船长'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@manager 
           ,9408
           ,'未满500总吨船舶大副'
           ,70
           ,100
           ,120
           ,1)
INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@manager 
           ,9409
           ,'未满500总吨船舶二/三副'
           ,70
           ,100
           ,120
           ,1)
	--@english
INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@english 
           ,9001
           ,'无限航区500总吨及以上船舶船长'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@english 
           ,9002
           ,'无限航区500总吨及以上船舶大副'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@english 
           ,9003
           ,'无限航区500总吨及以上船舶二/三副'
           ,70
           ,100
           ,120
           ,1)
 set @9003=@@IDENTITY;
--@Genglisth  
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Genglisth 
           ,1003
           ,'GMDSS通用操作员'
           ,70
           ,100
           ,120
           ,1)
--@Gyewu
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Gyewu 
           ,1013
           ,'GMDSS通用操作员'
           ,70
           ,100
           ,120
           ,1)
		   		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Gyewu 
           ,1014
           ,'GMDSS限用操作员'
           ,70
           ,100
           ,120
           ,1)
--@salioryewi
 		   		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@salioryewi 
           ,9601
           ,'500总吨及以上船舶值班水手'
           ,70
           ,100
           ,120
           ,1)
		   		   		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@salioryewi 
           ,9602
           ,'未满500总吨船舶值班水手'
           ,70
           ,100
           ,120
           ,1)
--@Hsalioryewu  
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Hsalioryewu 
           ,9701
           ,'无限航区500总吨及以上船舶高级值班水手'
           ,70
           ,100
           ,120
           ,1)
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Hsalioryewu 
           ,9702
           ,'沿海航区500总吨及以上船舶高级值班水手'
           ,70
           ,100
           ,120
           ,1)
--@Hsaliorenglish
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Hsalioryewu 
           ,9801
           ,'无限航区500总吨及以上船舶高级值班水手'
           ,70
           ,100
           ,120
           ,1)
--@lenglish 
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lenglish 
           ,8001
           ,'无限航区750KW及以上船舶轮机长'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lenglish 
           ,8002
           ,'无限航区750KW及以上船舶大管轮'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lenglish 
           ,8003
           ,'无限航区750KW及以上船舶二/三管轮'
           ,70
           ,100
           ,120
           ,1)
--@ldongli 
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@ldongli 
           ,8101
           ,'3000KW及以上船舶轮机长'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@ldongli 
           ,8102
           ,'750KW-3000KW船舶轮机长'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@ldongli 
           ,8103
           ,'未满750KW船舶轮机长'
           ,70
           ,100
           ,120
           ,1)
--@lzhuji 
	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lzhuji 
           ,8201
           ,'3000KW及以上船舶大管轮'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lzhuji 
           ,8202
           ,'750KW-3000KW船舶大管轮'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lzhuji 
           ,8203
           ,'3000KW及以上船舶二/三管轮'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lzhuji 
           ,8204
           ,'750KW-3000KW船舶二/三管轮'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lzhuji 
           ,8205
           ,'未满750KW船舶大管轮'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lzhuji 
           ,8206
           ,'未满750KW船舶二/三管轮'
           ,70
           ,100
           ,120
           ,1)
--@lfuji 
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lfuji 
           ,8301
           ,'3000KW及以上船舶大管轮'
           ,70
           ,100
           ,120
           ,1)
		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lfuji 
           ,8302
           ,'750KW-3000KW船舶大管轮'
           ,70
           ,100
           ,120
           ,1)
		   		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lfuji 
           ,8303
           ,'3000KW及以上船舶二/三管轮'
           ,70
           ,100
           ,120
           ,1)
		   		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lfuji 
           ,8304
           ,'750KW-3000KW船舶二/三管轮'
           ,70
           ,100
           ,120
           ,1)
		   		   	INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lfuji 
           ,8305
           ,'未满750KW船舶大管轮'
           ,70
           ,100
           ,120
           ,1)
INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lfuji 
           ,8306
           ,'未满750KW船舶二/三管轮'
           ,70
           ,100
           ,120
           ,1)
		   		   	
--@ldianqi 
INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@ldianqi 
           ,8401
           ,'3000KW及以上船舶大管轮 '
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@ldianqi 
           ,8402
           ,'750KW-3000KW船舶大管轮'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@ldianqi 
           ,8403
           ,'3000KW及以上船舶二/三管轮'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@ldianqi 
           ,8404
           ,'750KW-3000KW船舶二/三管轮'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@ldianqi 
           ,8405
           ,'未满750KW船舶大管轮'
           ,70
           ,100
           ,120
           ,1)
INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@ldianqi 
           ,8406
           ,'未满750KW船舶二/三管轮'
           ,70
           ,100
           ,120
           ,1)
--@lguanli
INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lguanli 
           ,8501
           ,'无限航区750KW及以上船舶轮机长'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lguanli 
           ,8502
           ,'沿海航区750KW及以上船舶轮机长'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lguanli 
           ,8503
           ,'无限航区750KW及以上船舶大管轮'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lguanli 
           ,8504
           ,'沿海航区750KW及以上船舶大管轮'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lguanli 
           ,8505
           ,'无限航区750KW及以上船舶二/三管轮'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lguanli 
           ,8506
           ,'沿海航区750KW及以上船舶二/三管轮'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lguanli 
           ,8507
           ,'未满750KW船舶轮机长'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lguanli 
           ,8508
           ,'未满750KW船舶大管轮'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@lguanli 
           ,8509
           ,'未满750KW船舶二/三管轮'
           ,70
           ,100
           ,120
           ,1)
--@jgyewu 
INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@jgyewu 
           ,8601
           ,'750KW及以上船舶值班机工'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@jgyewu 
           ,8602
           ,'未满750KW船舶值班机工'
           ,70
           ,100
           ,120
           ,1)
--@Hjgyewu 
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@jgyewu 
           ,8701
           ,'无限航区/沿海航区750KW及以上船舶高级值班机工'
           ,70
           ,100
           ,120
           ,1)
--@Hjgyiyu 
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Hjgyiyu 
           ,8801
           ,'无限航区750及以上船舶高级值班机工'
           ,70
           ,100
           ,120
           ,1)
--@dzdqdianqi 
INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@dzdqdianqi 
           ,7101
           ,'750kw及以上船舶电子员'
           ,70
           ,100
           ,120
           ,1)
--@dzdqzidonghua 
INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@dzdqzidonghua 
           ,7201
           ,'750kw及以上船舶电子员'
           ,70
           ,100
           ,120
           ,1)
--@dzdqdaohang 
INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@dzdqdaohang 
           ,7301
           ,'750kw及以上船舶电子员'
           ,70
           ,100
           ,120
           ,1)
--@dzdqgunali 
INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@dzdqgunali 
           ,7401
           ,'无限航区750kw及以上船舶电子员'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@dzdqgunali 
           ,7402
           ,'沿海航区750kw及以上船舶电子员'
           ,70
           ,100
           ,120
           ,1)
--@dzdqyingwu 
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@dzdqyingwu 
           ,7001
           ,'无限航区750KW及以上船舶电子员'
           ,70
           ,100
           ,120
           ,1)
--@dzjgyewu 
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@dzjgyewu 
           ,7501
           ,'无限航区750KW及以上船舶电子技工'
           ,70
           ,100
           ,120
           ,1)
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@dzjgyewu 
           ,7502
           ,'沿海航区750KW及以上船舶电子技工'
           ,70
           ,100
           ,120
           ,1)
--@dzjgyiyu
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@dzjgyiyu 
           ,7601
           ,'无限航区750KW及以上船舶电子技工'
           ,70
           ,100
           ,120
           ,1)
           
           
           
           

		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Z05JTJJ 
           ,50
           ,'Z05-精通急救'
           ,60
           ,100
           ,120
           ,1) 
    set @Z050JTJJ=@@IDENTITY;
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Z04GJXF 
           ,40
           ,'Z04-高级消防'
           ,60
           ,100
           ,120
           ,1) 
           set @Z040GJXF=@@IDENTITY;
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Z02JTJSTF 
           ,20
           ,'Z02-精通救生艇筏与救助筏'
           ,60
           ,100
           ,120
           ,1)  
           set @Z020JTJSTF=@@IDENTITY;
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Z01JBJJ 
           ,14
           ,'熟悉与基本安全培训-基本急救'
           ,60
           ,100
           ,120
           ,1) 
           set @Z014JBJJ=@@IDENTITY;
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Z01FHMH 
           ,13
           ,'熟悉与基本安全培训-防火与灭火'
           ,60
           ,100
           ,120
           ,1) 
           set @Z013FHMH=@@IDENTITY;
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Z01GRQS 
           ,12
           ,'熟悉与基本安全培训-个人求生'
           ,60
           ,100
           ,120
           ,1)  
           set @Z012GRQS=@@IDENTITY;  
		   INSERT INTO [OnLineTest].[dbo].[PaperCodes]
           ([SubjectId]
           ,[PaperCode]
           ,[ChineseName]
           ,[PaperCodePassScore]
           ,[PaperCodeTotalScore]
           ,[TimeRange]
           ,[IsVerified])
     VALUES
           (@Z01GRAQ 
           ,11
           ,'熟悉与基本安全培训-个人安全与社会责任'
           ,60
           ,100
           ,120
           ,1) 
           set @Z011GRAQ=@@IDENTITY;      

------------------------------------------------ 插入教材测试数据(待整理) ------------------------------------------------
/*
declare @Z011GRAQ INT,@Z012GRQS INT,@Z013FHMH INT,@Z014JBJJ INT;
declare @Z020JTJSTF INT,@Z040GJXF INT,@Z050JTJJ INT;
*/
INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@Z011GRAQ
           ,'个人安全与社会责任'
           ,'978-7-5629-4191-0'
           ,1) 
INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@Z012GRQS
           ,'个人求生'
           ,'978-7-5629-4192-7'
           ,1) 
INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@Z013FHMH
           ,'防火与灭火'
           ,'978-7-5629-4188-0'
           ,1) 
INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@Z014JBJJ
           ,'基本急救'
           ,'978-7-5629-4187-3'
           ,1) 
INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@Z020JTJSTF
           ,'救生艇筏和救助艇操作及管理'
           ,'978-7-5629-4190-3'
           ,1) 
INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@Z040GJXF
           ,'高级消防'
           ,'978-7-5629-4189-7'
           ,1) 
INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@Z050JTJJ
           ,'精通医疗急救'
           ,'978-7-5629-4186-6'
           ,1)           






INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@9205
           ,'航海学（航海地文、天文和仪器）'
           ,'978-7-114-09766-9'
           ,1) 
INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@9205
           ,'航海学（航海气象与海洋学）'
           ,'978-7-114-09755-3'
           ,1) 
   INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@9105
           ,'船舶操纵与避碰（船舶避碰）'
           ,'978-7-114-09728-7'
           ,1) 
      INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@9105
           ,'船舶操纵与避碰（船舶操纵）'
           ,'978-7-114-09754-6'
           ,1) 
   INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@9303
           ,'船舶结构与货运'
           ,'978-7-114-09801-7'
           ,1) 
   INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@9405
           ,'船舶管理（驾驶员）'
           ,'978-7-114-09727-0'
           ,1) 
   INSERT INTO [OnLineTest].[dbo].[TextBook]
           ([PaperCodeId]
           ,[TextBookName]
           ,[ISBN]
           ,[IsVerified])
     VALUES
           (@9003
           ,'航海英语（二、三副）'
           ,'978-7-114-09918-2'
           ,1) 
GO
------------------------------------------------ 插入章节测试数据 (待整理)------------------------------------------------

--INSERT INTO [OnLineTest].[dbo].[Chapter]
--           ([TextBookId]
--           ,[ChapterName]
--           ,[ChapterParentNo]
--           ,[ChapterDeep]
--           ,[ChapterRemark]
--           ,[IsVerified])
--     VALUES
--           (1
--           ,'航海基础知识'
--           ,0
--           ,0
--           ,'航海基础知识'
--           ,1)
--INSERT INTO [OnLineTest].[dbo].[Chapter]
--           ([TextBookId]
--           ,[ChapterName]
--           ,[ChapterParentNo]
--           ,[ChapterDeep]
--           ,[ChapterRemark]
--           ,[IsVerified])
--     VALUES
--           (1
--           ,'海图'
--           ,0
--           ,0
--           ,'海图'
--           ,1)
--INSERT INTO [OnLineTest].[dbo].[Chapter]
--           ([TextBookId]
--           ,[ChapterName]
--           ,[ChapterParentNo]
--           ,[ChapterDeep]
--           ,[ChapterRemark]
--           ,[IsVerified])
--     VALUES
--           (1
--           ,'船舶定位'
--           ,0
--           ,0
--           ,'船舶定位'
--           ,1)
--INSERT INTO [OnLineTest].[dbo].[Chapter]
--           ([TextBookId]
--           ,[ChapterName]
--           ,[ChapterParentNo]
--           ,[ChapterDeep]
--           ,[ChapterRemark]
--           ,[IsVerified])
--     VALUES
--           (1
--           ,'天球坐标系与时间系统'
--           ,0
--           ,0
--           ,'天球坐标系与时间系统'
--           ,1)
--INSERT INTO [OnLineTest].[dbo].[Chapter]
--           ([TextBookId]
--           ,[ChapterName]
--           ,[ChapterParentNo]
--           ,[ChapterDeep]
--           ,[ChapterRemark]
--           ,[IsVerified])
--     VALUES
--           (1
--           ,'罗经差的测定'
--           ,0
--           ,0
--           ,'罗经差的测定'
--           ,1)
--INSERT INTO [OnLineTest].[dbo].[Chapter]
--           ([TextBookId]
--           ,[ChapterName]
--           ,[ChapterParentNo]
--           ,[ChapterDeep]
--           ,[ChapterRemark]
--           ,[IsVerified])
--     VALUES
--           (1
--           ,'航线与航行方法'
--           ,0
--           ,0
--           ,'航线与航行方法'
--           ,1)
           
--INSERT INTO [OnLineTest].[dbo].[Chapter]
--           ([TextBookId]
--           ,[ChapterName]
--           ,[ChapterParentNo]
--           ,[ChapterDeep]
--           ,[ChapterRemark]
--           ,[IsVerified])
--     VALUES
--           (1
--           ,'航向与方位'
--           ,1
--           ,1
--           ,'航向与方法'
--           ,1)
--INSERT INTO [OnLineTest].[dbo].[Chapter]
--           ([TextBookId]
--           ,[ChapterName]
--           ,[ChapterParentNo]
--           ,[ChapterDeep]
--           ,[ChapterRemark]
--           ,[IsVerified])
--     VALUES
--           (1
--           ,'航速与航程'
--           ,1
--           ,1
--           ,'航速与航程'
--           ,1)
--INSERT INTO [OnLineTest].[dbo].[Chapter]
--           ([TextBookId]
--           ,[ChapterName]
--           ,[ChapterParentNo]
--           ,[ChapterDeep]
--           ,[ChapterRemark]
--           ,[IsVerified])
--     VALUES
--           (1
--           ,'识图'
--           ,2
--           ,1
--           ,'识图'
--           ,1)
--INSERT INTO [OnLineTest].[dbo].[Chapter]
--           ([TextBookId]
--           ,[ChapterName]
--           ,[ChapterParentNo]
--           ,[ChapterDeep]
--           ,[ChapterRemark]
--           ,[IsVerified])
--     VALUES
--           (1
--           ,'海图分类和使用'
--           ,2
--           ,1
--           ,'海图分类和使用'
--           ,1)
--INSERT INTO [OnLineTest].[dbo].[Chapter]
--           ([TextBookId]
--           ,[ChapterName]
--           ,[ChapterParentNo]
--           ,[ChapterDeep]
--           ,[ChapterRemark]
--           ,[IsVerified])
--     VALUES
--           (1
--           ,'方位定位'
--           ,3
--           ,1
--           ,'方位定位'
--           ,1)
--GO

------------------------------------------------ 插入考区测试数据(待整理) ------------------------------------------------

INSERT INTO [OnLineTest].[dbo].[ExamZone]
           ([ExamZoneName]
           ,[IsVerified])
     VALUES
           ('武汉'
           ,1)
INSERT INTO [OnLineTest].[dbo].[ExamZone]
           ([ExamZoneName]
           ,[IsVerified])
     VALUES
           ('上海'
           ,1)
INSERT INTO [OnLineTest].[dbo].[ExamZone]
           ([ExamZoneName]
           ,[IsVerified])
     VALUES
           ('大连'
           ,1)
INSERT INTO [OnLineTest].[dbo].[ExamZone]
           ([ExamZoneName]
           ,[IsVerified])
     VALUES
           ('广东'
           ,1)
INSERT INTO [OnLineTest].[dbo].[ExamZone]
           ([ExamZoneName]
           ,[IsVerified])
     VALUES
           ('天津'
           ,1)

GO
------------------------------------------------ 插入真题信息测试数据(待整理) ------------------------------------------------

INSERT INTO [OnLineTest].[dbo].[PastExamPaper]
           ([PaperCodeId]
           ,[ExamZoneId]
           ,[PastExamPaperPeriodNo]
           ,[PastExamPaperDatetime]
           ,[IsVerified])
     VALUES
           (1
           ,1
           ,42
           ,2008-06-20
           ,1)

------------------------------------------------ 插入试题测试数据(待整理) ------------------------------------------------

------------------------------------------------ 插入评论测试数据(待整理) ------------------------------------------------

--insert into Comment(QuestionId,UserId,CommentContent) values(2,1,'卡梅伦说，今年是英中关系发展的“黄金年”，英方热切期待习近平主席10月对英国进行国事访问。英方各部门已全面启动，希望与中方密切协作，积极筹备，向世界展示英中合作的积极成果和美好前景。英国坚定致力于发展对华关系，愿成为中方最开放的合作伙伴。英方')
--insert into Comment(QuestionId,UserId,CommentContent) values(32,2,'很多时候，只有站在历史的峰峦之上，才能更清晰地洞察时代风云，更准确地把握前进方向')
--insert into Comment(QuestionId,UserId,CommentContent) values(1,3,'调，中安合作共赢、共同发展互有需要、互有优势、互为机遇。双方应坚持从战略高度和长远角度把握中安关系发展正确方向，增强政治互信，支持对方自主选择和完善发展道路，在涉及各自核心利益和重大关切问题上相互理解和支持。双方要保持高层交往良好势头，密切政府部门、立法机构、地方等交流。双方应致力')
--insert into Comment(QuestionId,UserId,CommentContent) values(1,2,'。5年来，两国各领域友好合作取得显著成果，给两国人民带来实实在在的利益。相信总统先生此次访问')
--insert into Comment(QuestionId,UserId,CommentContent) values(5,1,'大关切问题上相互理解和支持。双方要保持高层交往良好势头，密切政府部门、立法机构、地方等交')
--insert into Comment(QuestionId,UserId,CommentContent) values(1,4,'强调，中安合作共赢、共同发展互有需要、互有优势、互为机遇。双方应坚持从战略高度和长远角度把握中安关系发展正确方向，增强政治互信，支持对方自主选择和完善发展道路，在涉及各自核心')
--insert into Comment(QuestionId,UserId,CommentContent) values(78,5,'择。中方愿同包括安哥拉在内的非洲友好国家保持密切沟通，通过中非合作论坛等为中非关系和互')
--insert into Comment(QuestionId,UserId,CommentContent) values(1,1,'我完全赞同习近平主席对安中关系的评价。安哥拉同中国保持着深厚互信和互利合作，为两国战略伙伴关系奠定了牢固的基础')
--insert into Comment(QuestionId,UserId,CommentContent) values(14,2,'我完全赞同习近平主席对安中关系的评价。安哥拉同中国保持着深厚互信和互利合作，为两国战略伙伴关系奠定了牢固的基础')
--insert into Comment(QuestionId,UserId,CommentContent) values(1,1,'我完全赞同习近平主席对安中关系的评价。安哥拉同中国保持着深厚互信和互利合作，为两国战略伙伴关系奠定了牢固的基础')
--insert into Comment(QuestionId,UserId,CommentContent) values(45,7,'我完全赞同习近平主席对安中关系的评价。安哥拉同中国保持着深厚互信和互利合作，为两国战略伙伴关系奠定了牢固的基础')
--insert into Comment(QuestionId,UserId,CommentContent) values(1,6,'中国企业到安哥拉投资兴业，参与安哥拉工业园区和基础设施建设，帮助安哥拉实现经济多元化')
--insert into Comment(QuestionId,UserId,CommentContent) values(1,1,'中国企业到安哥拉投资兴业，参与安哥拉工业园区和基础设施建设，帮助安哥拉实现经济多元化')
--insert into Comment(QuestionId,UserId,CommentContent) values(1,2,'中国企业到安哥拉投资兴业，参与安哥拉工业园区和基础设施建设，帮助安哥拉实现经济多元化')
--insert into Comment(QuestionId,UserId,CommentContent) values(7,1,'中安关系发展正确方向，增强政治互信，支持对方自主选择和完善发展道路，在涉及各自核心利益')
--insert into Comment(QuestionId,UserId,CommentContent) values(9,4,'中安关系发展正确方向，增强政治互信，支持对方自主选择和完善发展道路，在涉及各自核心利益')
--insert into Comment(QuestionId,UserId,CommentContent) values(10,1,'国需要这样契合群众需求的改革，才能留住科研人才，提升国家的整体科研水平')
--insert into Comment(QuestionId,UserId,CommentContent) values(11,5,'你肯定是船主或者是保险公司的不想倍多，我不要你算多了，你算40人，一个50万，是多少。两千万。//@那年那兔那小舞kuma：400X50W=20000W·怎来20E了···数死早//@newlane88：差的远，1人陪50万就是20多亿。')
--insert into Comment(QuestionId,UserId,CommentContent) values(14,1,'你肯定是船主或者是保险公司的不想倍多，我不要你算多了，你算40人，一个50万，是多少。两千万。//@那年那兔那小舞kuma：400X50W=20000W·怎来20E了···数死早//@newlane88：差的远，1人陪50万就是20多亿。')
--insert into Comment(QuestionId,UserId,CommentContent) values(51,3,'中国保监会10日通报，经过初步排查，保险业共承保“东方之星”客船翻沉事件中失事客船船东、相关旅行社、乘客和船员投')
--insert into Comment(QuestionId,UserId,CommentContent) values(5,1,'中国保监会10日通报，经过初步排查，保险业共承保“东方之星”客船翻沉事件中失事客船船东、相关旅行社、乘客和船员投')
--insert into Comment(QuestionId,UserId,CommentContent) values(65,3,'我这个体育老师没有这样交过一楼，要不问问楼下的音乐老师？//@似水如鱼2809：你数学是体育老师教的吗？//@newlane88：差的远，1人陪50万就是20多亿。')
--insert into Comment(QuestionId,UserId,CommentContent) values(24,1,'”的最后一次航行是用约两周时间穿过风景如画的三峡，前往重庆。该船5月28日从南京出发时，船上的405名游客当中包括58岁的天津农民吴建强和他的妻子李秀珍，以及他们在天津的6个朋友。')
--insert into Comment(QuestionId,UserId,CommentContent) values(7,2,'包括炖炸鱼、豆角、西红柿炒鸡蛋和米饭，是出发后吃得最好的一餐。吴说，他妻子吃得很高兴')
--insert into Comment(QuestionId,UserId,CommentContent) values(34,1,'包括炖炸鱼、豆角、西红柿炒鸡蛋和米饭，是出发后吃得最好的一餐。吴说，他妻子吃得很高兴')
--insert into Comment(QuestionId,UserId,CommentContent) values(1,1,'包括炖炸鱼、豆角、西红柿炒鸡蛋和米饭，是出发后吃得最好的一餐。吴说，他妻子吃得很高兴')

---=============================================测试查询 =============================================
use OnLineTest
--select * from Authority
--select * from Chapter
--select * from Comment
--select * from Difficulty
--select * from ExamZone
--select * from LogLogin
--select * from LogPractice
--select * from LogTest
--select * from LogTestQuestion
--select * from Message_table
--select * from PaperCodes
--select * from PastExamPaper
--select * from Question
--select * from Subject
--select * from TextBook
--select * from UserAuthority
--select * from UserCreatePaper
--select * from UserCreatePaperQuestione
--select * from UserGroup
--select * from UserRank
--select * from Users
--select * from UserScoreDetail
--select * from VerifyStatus 