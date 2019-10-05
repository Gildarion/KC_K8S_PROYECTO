CREATE DATABASE FlaskBlogApp;

USE FlaskBlogApp;

CREATE TABLE `blog_user` (
  `user_id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_name` VARCHAR(45) NULL,
  `user_username` VARCHAR(45) NULL,
  `user_password` VARCHAR(85) NULL,
  PRIMARY KEY (`user_id`));

CREATE TABLE `tbl_blog` (
  `blog_id` int(11) NOT NULL AUTO_INCREMENT,
  `blog_title` varchar(45) DEFAULT NULL,
  `blog_description` varchar(5000) DEFAULT NULL,
  `blog_user_id` int(11) DEFAULT NULL,
  `blog_date` datetime DEFAULT NULL,
  `blog_file_path` VARCHAR(200) NULL,
  `blog_accomplished` INT NULL DEFAULT 0,
  `blog_private` INT NULL DEFAULT 0,
  PRIMARY KEY (`blog_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

CREATE TABLE `tbl_likes` (
  `blog_id` INT NOT NULL,
  `like_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NULL,
  `blog_like` INT NULL DEFAULT 0,
  PRIMARY KEY (`like_id`));

SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addBlog`(
    IN p_title varchar(45),
    IN p_description varchar(1000),
    IN p_user_id bigint,
    IN p_file_path varchar(200),
    IN p_is_private int,
    IN p_is_done int
)
BEGIN
    insert into tbl_blog(
        blog_title,
        blog_description,
        blog_user_id,
        blog_date,
        blog_file_path,
        blog_private,
        blog_accomplished
    )
    values
    (
        p_title,
        p_description,
        p_user_id,
        NOW(),
        p_file_path,
        p_is_private,
        p_is_done
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_createUser`(
    IN p_name VARCHAR(20),
    IN p_username VARCHAR(20),
    IN p_password VARCHAR(85)
)
BEGIN
    IF ( select exists (select 1 from blog_user where user_username = p_username) ) THEN
     
        select 'Username Exists !!';
     
    ELSE
     
        insert into blog_user
        (
            user_name,
            user_username,
            user_password
        )
        values
        (
            p_name,
            p_username,
            p_password
        );
     
    END IF;
END$$

CREATE PROCEDURE `sp_deleteBlog` (
IN p_blog_id bigint,
IN p_user_id bigint
)
BEGIN
delete from tbl_blog where blog_id = p_blog_id and blog_user_id = p_user_id;
END$$
 
CREATE DEFINER=`root`@`localhost` FUNCTION `hasLiked`(
    p_blog int,
    p_user int
) RETURNS int(11)
BEGIN  
    select blog_like into @myval from tbl_likes where blog_id =  p_blog and user_id = p_user;
RETURN @myval;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetBlogById`(
IN p_blog_id bigint,
In p_user_id bigint
)
BEGIN
select blog_id,blog_title,blog_description,blog_file_path,blog_private,blog_accomplished from tbl_blog where blog_id = p_blog_id and blog_user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getLikeStatus`(
    IN p_blog_id int,
    IN p_user_id int
)
BEGIN
    select getSum(p_blog_id),hasLiked(p_blog_id,p_user_id);
END$$

USE `FlaskBlogApp`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAllBlogs`()
BEGIN
    select blog_id,blog_title,blog_description,blog_file_path from tbl_blog where blog_private = 0;
END$$
 
CREATE PROCEDURE `sp_GetBlogByUser` (
IN p_user_id bigint
)
BEGIN
    select * from tbl_blog where blog_user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_validateLogin`(
IN p_username VARCHAR(20)
)
BEGIN
	select * from blog_user where user_username = p_username;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getSum`(
    p_blog_id int
) RETURNS int(11)
BEGIN
    select sum(blog_like) into @sm from tbl_likes where blog_id = p_blog_id;
RETURN @sm;
END$$
 
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddUpdateLikes`(
    p_blog_id int,
    p_user_id int,
    p_like int
)
BEGIN
    if (select exists (select 1 from tbl_likes where blog_id = p_blog_id and user_id = p_user_id)) then
 
        update tbl_likes set blog_like = p_like where blog_id = p_blog_id and user_id = p_user_id;
         
    else
         
        insert into tbl_likes(
            blog_id,
            user_id,
            blog_like
        )
        values(
            p_blog_id,
            p_user_id,
            p_like
        );
 
    end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateBlog`(
IN p_title varchar(45),
IN p_description varchar(1000),
IN p_blog_id bigint,
In p_user_id bigint,
IN p_file_path varchar(200),
IN p_is_private int,
IN p_is_done int
)
BEGIN
update tbl_blog set
    blog_title = p_title,
    blog_description = p_description,
    blog_file_path = p_file_path,
    blog_private = p_is_private,
    blog_accomplished = p_is_done
    where blog_id = p_blog_id and blog_user_id = p_user_id;
END$$