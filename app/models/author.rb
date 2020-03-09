class Author < ApplicationRecord

  has_many :posts

  validates :editor, inclusion: { in: editor_options, message: "%{value} is not a valid editor" }
  validates :email, presence: true, format: { with: Proc.new { /\A(.+@(#{ENV['permitted_domains']}))\z/ } }
  validates :twitter_handle, length: { maximum: 15 }, format: { with: /\A(?=.*[a-z])[a-z_\d]+\Z/i }, allow_blank: true

  def self.editor_options
    ['Text Field', 'Ace (w/ Vim)', 'Ace'].freeze
  end

  def to_param
    username
  end

  def twitter_handle=(handle)
    self[:twitter_handle] = handle.gsub(/^@+/, '').presence
  end

  def posts_count
    posts.published.count
  end

end
