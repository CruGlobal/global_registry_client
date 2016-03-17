module GlobalRegistry
  class Subscription < Base
    def self.all
      get_all_pages['subscriptions']
    end

    def self.create(params)
      post(subscription: params)
    end
  end
end
