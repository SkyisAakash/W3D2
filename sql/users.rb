require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('users.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Questions

  attr_accessor :id, :title, :body, :associated_author

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @associated_author = options['associated_author']
  end

  def self.find_by_id(id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
      *
      FROM
      questions
      WHERE
      id = ?
    SQL

    return nil if questions.empty?
    Questions.new(questions.first)
  end

  def self.find_by_author_id(authorid)
    query = QuestionsDatabase.instance.execute(<<-SQL, authorid)
      SELECT
      *
      FROM
      questions
      WHERE
      associated_author = ?
    SQL
    return nil if query.empty?
    Questions.new(query.first)
  end

  def author
    Users.find_by_id(@associated_author)
  end

  def followers
    Question_follows.followers_for_question_id(@id)
  end


end

class Users

    attr_accessor :id, :fname, :lname

    def initialize(options)
      @id = options['id']
      @firstname = options['fname']
      @lastname = options['lname']
    end

    def self.find_by_id(id)
      users = QuestionsDatabase.instance.execute(<<-SQL, id)
        SELECT
        *
        FROM
        users
        WHERE
        id = ?
      SQL
      return nil if users.empty?
      Users.new(users.first)
    end

    def self.find_by_name(fname, lname)
      users = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
        SELECT
        *
        FROM
        users
        WHERE
        fname = ? AND lname = ?
      SQL
      return nil if users.empty?
      Users.new(users.first)
    end

    def authored_questions
      Question.find_by_author_id(self.id)
    end

    def authored_replies
      Reply.find_by_user_id(self.id)
    end

    def followed_questions
      Question_follows.followed_questions_for_user_id(self.id)
    end



end

class Reply

    attr_accessor :id, :fname, :lname

    def initialize(options)
      @id = options['id']
      @sub_ques_id = options['sub_ques_id']
      @parent_reply_id = options['parent_reply_id']
      @author_of_reply_id = options['author_of_reply_id']
      @body = options['body']
    end

    def self.find_by_user_id(userid)
      users = QuestionsDatabase.instance.execute(<<-SQL, userid)
        SELECT
        *
        FROM
        replies
        WHERE
        author_of_reply_id = ?
      SQL
      return nil if users.empty?
      users.map {|user| Reply.new(user)}
    end

    def self.find_by_question_id(question_id)
      question = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
      *
      FROM
      replies
      WHERE
      sub_ques_id = ?

      SQL

      return nil if question.empty?
      question.map {|question| Reply.new(question)}
    end

    def author
      Users.find_by_id(@author_of_reply_id)
    end

    def question
      Questions.find_by_id(@sub_ques_id)
    end

    def parent_reply
      Reply.find_by_user_id(@parent_reply_id)
    end

    def child_replies
      replies = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
      *
      FROM
      replies
      WHERE
      parent_reply_id = @id
      SQL

      return nil if replies.empty?
      replies.map {|reply| Reply.new(reply)}
    end

end

class Question_follows
attr_accessor :id, :usr_id, :ques_id

  def initialize(options)
    @id = options['id']
    @usr_id = options['usr_id']
    @ques_id = options['ques_id']
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
    fname, lname
    FROM
    question_follows
    JOIN
    users
    ON
    question_follows.usr_id = users.id
    WHERE
    question_follows.ques_id = ?
    SQL
    followers.map {|follower| Users.find_by_name(follower[0],follower[1])}
  end


    def self.followed_questions_for_user_id(user_id)
      questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
      ques_id
      FROM
      question_follows
      JOIN
      questions
      ON
      question_follows.ques_id = questions.id
      WHERE
      question_follows.usr_id = ?
      SQL
      questions.map {|question| Questions.find_by_id(question['ques_id'])}
    end

    def self.most_followed_questions(n)
      questions = QuestionsDatabase.instance.execute(<<-SQL, n)
          SELECT
          ques_id, COUNT(*) AS followers
          FROM
          question_follows
          GROUP BY
          ques_id
          ORDER BY
           followers DESC
          LIMIT
          ?
          SQL
          questions.map {|question| Questions.find_by_id(question['ques_id'])}

    end

end

# a = Questions.new({'id'=>'4','title'=>'new question','body'=>'its a bad question','associated_author'=>'1'})
# b = Reply.new({'id'=>'5','sub_ques_id'=>'2','author_of_reply_id'=>'1','body'=>'this is annoying'})
