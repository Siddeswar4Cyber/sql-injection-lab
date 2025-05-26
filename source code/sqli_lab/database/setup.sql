-- Create users table
CREATE TABLE IF NOT EXISTS users (
    user_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    user VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL,
    avatar VARCHAR(50) NOT NULL,
    security_level INT NOT NULL,
    PRIMARY KEY (user_id)
);

-- Insert sample data
INSERT INTO users (first_name, last_name, user, password, avatar, security_level) VALUES
('Admin', 'User', 'admin', '5f4dcc3b5aa765d61d8327deb882cf99', '1.jpg', 1),
('Gordon', 'Brown', 'gordonb', 'e99a18c428cb38d5f260853678922e03', '2.jpg', 1),
('Hack', 'Me', '1337', '8d3533d95745afd99bb68da053c48486', '3.jpg', 1),
('Pablo', 'Picasso', 'pablo', '0d107d09f5bbe40cade3de5c71e9e9b7', '4.jpg', 1),
('Bob', 'Smith', 'smithy', '5f4dcc3b5aa765d61d8327deb882cf99', '5.jpg', 1);

-- Create guestbook table
CREATE TABLE IF NOT EXISTS guestbook (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    comment TEXT NOT NULL,
    PRIMARY KEY (id)
);

-- Create command injection table
CREATE TABLE IF NOT EXISTS commands (
    id INT NOT NULL AUTO_INCREMENT,
    cmd VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
);

-- Create xss table
CREATE TABLE IF NOT EXISTS xss (
    id INT NOT NULL AUTO_INCREMENT,
    stored TEXT NOT NULL,
    PRIMARY KEY (id)
);

-- Create file upload table
CREATE TABLE IF NOT EXISTS uploads (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(50) NOT NULL,
    size INT NOT NULL,
    data MEDIUMBLOB NOT NULL,
    PRIMARY KEY (id)
);

-- Create brute force table
CREATE TABLE IF NOT EXISTS brute_force (
    id INT NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
);

-- Insert brute force data
INSERT INTO brute_force (username, password) VALUES
('admin', 'password'),
('gordonb', 'abc123'),
('1337', '1337'),
('pablo', 'letmein'),
('smithy', 'password');
