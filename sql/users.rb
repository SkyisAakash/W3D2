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

end
