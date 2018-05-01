require 'sqlite3'
require 'singleton'

class QuestionsDatabase << SQLite3::Database
  include Singleton

  def initialize
    super('users.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Questions

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
    return nil unless id.is_a?(Integer)
    Questions.new(questions.first)
  end

end
