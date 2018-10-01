require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsOctomail
  class Application < Rails::Application
    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Initialize configuration for rack-cors
    config.middleware.insert_before 0, Rack::Cors do
      # react frontend
      allow do
        origins "localhost:4000", # local
          "https://gitmailz.herokuapp.com", # heroku default
          # "*.gitmailz.com", # any subdomain
          "https://gitmailz.com" # apex (top level) domain
        resource "*",
                 headers: :any,
                 credentials: true,
                 methods: [
                   :get #,
                 # :post,
                 # :put, # enable this when you need to make an UPDATE api call, from your react app
                 # :delete
                 ]
      end
    end
  end
end
