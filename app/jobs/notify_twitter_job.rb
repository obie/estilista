class NotifyTwitterJob < ApplicationJob
  queue_as :default

  def perform(post)
    return if post.draft? || post.tweeted?
    if ENV['update_twitter_with_post'] == 'true'
      TwitterClient.update(status(post))
      post.tweeted = true
      post.save
    end
  end

  private

  def title
    post.title
  end

  def name
    post.twitter_handle
  end

  def category
    post.channel.twitter_hashtag
  end

  def host
    ENV.fetch('host')
  end

  def status(post)
    "#{post.title} #{Rails.application.routes.url_helpers.post_url(titled_slug: post.to_param, host: host)} via @#{post.twitter_handle} #til ##{post.channel.twitter_hashtag}"
  end
end