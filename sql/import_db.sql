DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS questions_like;

CREATE TABLE users (
id INTEGER PRIMARY KEY,
fname VARCHAR(255) NOT NULL,
lname VARCHAR(255) NOT NULL

);

CREATE TABLE questions (
id INTEGER PRIMARY KEY,
title VARCHAR(255) NOT NULL,
body TEXT,
associated_author INTEGER NOT NULL,
FOREIGN KEY(associated_author) REFERENCES users(id)
);


CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  usr_id INTEGER,
  ques_id INTEGER,
  FOREIGN KEY(usr_id) REFERENCES users(id),
  FOREIGN KEY(ques_id) REFERENCES questions(id)
);

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  sub_ques_id INTEGER,
  parent_reply_id INTEGER,
  author_of_reply_id INTEGER,
  body TEXT,
  FOREIGN KEY(sub_ques_id) REFERENCES questions(id),
  FOREIGN KEY(parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY(author_of_reply_id) REFERENCES users(id)
);

CREATE TABLE questions_like (
id INTEGER PRIMARY KEY,
user_id INTEGER,
question_id INTEGER,
FOREIGN KEY(user_id) REFERENCES users(id),
FOREIGN KEY(question_id) REFERENCES questions(id)
);

INSERT INTO
users (fname, lname)
VALUES
('Aakash','Sarang'),
('Kahaan','Patel'),
('Whatever','Smith');

INSERT INTO
questions ( title, body, associated_author)
VALUES
('Join','Multiple joining tables',(SELECT id from users WHERE fname = 'Aakash')),
('Life','Why do we need SQL in life',(SELECT id from users WHERE fname = 'Kahaan')),
('everything','Messing up everything',(SELECT id from users WHERE fname = 'Whatever'));

INSERT INTO
question_follows(usr_id, ques_id)
VALUES
((SELECT id from users WHERE fname = 'Aakash'),(SELECT id from questions WHERE title = 'Life')),
((SELECT id from users WHERE fname = 'Aakash'),(SELECT id from questions WHERE title = 'Join')),
((SELECT id from users WHERE fname = 'Kahaan'),(SELECT id from questions WHERE title = 'Life')),
((SELECT id from users WHERE fname = 'Whatever'),(SELECT id from questions WHERE title = 'Life')),
((SELECT id from users WHERE fname = 'Whatever'),(SELECT id from questions WHERE title = 'Join')),
((SELECT id from users WHERE fname = 'Whatever'),(SELECT id from questions WHERE title = 'everything'));

INSERT INTO
replies(sub_ques_id, parent_reply_id, author_of_reply_id, body)
VALUES
((SELECT id from questions WHERE title = 'Life'), NULL, (SELECT id from users WHERE fname = 'Kahaan'), "Reply 1"),
((SELECT id from questions WHERE title = 'everything'), NULL, (SELECT id from users WHERE fname = 'Aakash'), "Reply 2"),
((SELECT id from questions WHERE title = 'Join'), NULL, (SELECT id from users WHERE fname = 'Whatever'), "Reply 3"),
((SELECT id from questions WHERE title = 'Join'), 3, (SELECT id from users WHERE fname = 'Whatever'), "Reply 4");
--

INSERT INTO
questions_like(user_id, question_id)
VALUES
((SELECT id from users WHERE fname = 'Aakash'),(SELECT id from questions WHERE title = 'Life')),
((SELECT id from users WHERE fname = 'Aakash'),(SELECT id from questions WHERE title = 'everything')),
((SELECT id from users WHERE fname = 'Kahaan'),(SELECT id from questions WHERE title = 'Life')),
((SELECT id from users WHERE fname = 'Whatever'),(SELECT id from questions WHERE title = 'Join')),
((SELECT id from users WHERE fname = 'Whatever'),(SELECT id from questions WHERE title = 'Life')),
((SELECT id from users WHERE fname = 'Whatever'),(SELECT id from questions WHERE title = 'everything'));


-- CREATE TABLE replies (
-- id INTEGER PRIMARY KEY,
-- sub_ref VARCHAR(255) NOT NULL,
-- body TEXT,
--
--
-- );
--
-- SELECT
-- *
-- FROM
-- users
-- JOIN
-- questions
-- ON
-- users.id = questions.associated_author;
--
-- CREATE TABLE users (
-- id INTEGER PRIMARY KEY,
-- fname VARCHAR(255) NOT NULL,
-- lname VARCHAR(255) NOT NULL
--
-- );
