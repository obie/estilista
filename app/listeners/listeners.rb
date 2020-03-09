module Listeners
  extend self

  ##
  # Make sure to subscribe global listeners in this method. It gets called
  # inside of `config/initializers/wisper.rb` once in production, and once
  # per request in development using `Rails.application.config.to_prepare`
  # and also in the setup for feature specs.
  #
  def register_global_listeners
    Wisper.clear
    Wisper.subscribe(AdminNotifier.new)
    Wisper.subscribe(SlackNotifications.new)
    Wisper.subscribe(UserEmails.new)
  end
end
