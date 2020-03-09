class NotifySlackJob < ApplicationJob
  queue_as :default

  SLACK_CHANNEL = ENV['SLACK_CHANNEL']
  SLACK_WEBHOOK_URL = ENV['SLACK_WEBHOOK_URL']
  SLACK_USERNAME = ENV['SLACK_USERNAME']

  def perform(post)
    return if SLACK_CHANNEL.blank?

    # todo: format properly
    slack.post(text: post.to_s)
  end

  def slack
    Slack::Notifier.new(SLACK_WEBHOOK_URL, channel: SLACK_CHANNEL, username: SLACK_USERNAME)
  end
end
