require 'twitter/api/utils'
require 'twitter/tweet'
require 'twitter/user'

module Twitter
  module API
    module Timelines
      include Twitter::API::Utils
      DEFAULT_TWEETS_PER_REQUEST = 20
      MAX_TWEETS_PER_REQUEST = 200

      # Returns the 20 most recent mentions (statuses containing @username) for the authenticating user
      #
      # @see https://dev.twitter.com/docs/api/1.1/get/statuses/mentions_timeline
      # @note This method can only return up to 800 Tweets.
      # @rate_limited Yes
      # @authentication_required Requires user context
      # @raise [Twitter::Error::Unauthorized] Error raised when supplied user credentials are not valid.
      # @return [Array<Twitter::Tweet>]
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @example Return the 20 most recent mentions (statuses containing @username) for the authenticating user
      #   Twitter.mentions
      def mentions_timeline(options={})
        collection_from_response(Twitter::Tweet, :get, "/1.1/statuses/mentions_timeline.json", options)
      end
      alias mentions mentions_timeline

      # Returns the 20 most recent Tweets posted by the specified user
      #
      # @see https://dev.twitter.com/docs/api/1.1/get/statuses/user_timeline
      # @note This method can only return up to 3,200 Tweets.
      # @rate_limited Yes
      # @authentication_required Requires user context
      # @raise [Twitter::Error::Unauthorized] Error raised when supplied user credentials are not valid.
      # @return [Array<Twitter::Tweet>]
      # @overload user_timeline(user, options={})
      #   @param user [Integer, String, Twitter::User] A Twitter user ID, screen name, or object.
      #   @param options [Hash] A customizable set of options.
      #   @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      #   @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      #   @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      #   @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      #   @option options [Boolean, String, Integer] :exclude_replies This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count tweets - this is because the count parameter retrieves that many tweets before filtering out retweets and replies.
      #   @option options [Boolean, String, Integer] :contributor_details Specifies that the contributors element should be enhanced to include the screen_name of the contributor.
      #   @option options [Boolean, String, Integer] :include_rts Specifies that the timeline should include native retweets in addition to regular tweets. Note: If you're using the trim_user parameter in conjunction with include_rts, the retweets will no longer contain a full user object.
      #   @example Return the 20 most recent Tweets posted by @sferik
      #     Twitter.user_timeline('sferik')
      def user_timeline(*args)
        objects_from_response(Twitter::Tweet, :get, "/1.1/statuses/user_timeline.json", args)
      end

      # Returns the 20 most recent retweets posted by the specified user
      #
      # @see https://dev.twitter.com/docs/api/1.1/get/statuses/user_timeline
      # @note This method can only return up to 3,200 Tweets.
      # @rate_limited Yes
      # @authentication_required Requires user context
      # @raise [Twitter::Error::Unauthorized] Error raised when supplied user credentials are not valid.
      # @return [Array<Twitter::Tweet>]
      # @param user [Integer, String, Twitter::User] A Twitter user ID, screen name, or object.
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :exclude_replies This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count tweets - this is because the count parameter retrieves that many tweets before filtering out retweets and replies.
      # @option options [Boolean, String, Integer] :contributor_details Specifies that the contributors element should be enhanced to include the screen_name of the contributor.
      # @example Return the 20 most recent retweets posted by @sferik
      #   Twitter.retweeted_by_user('sferik')
      def retweeted_by_user(user, options={})
        options[:include_rts] = true
        count = options[:count] || DEFAULT_TWEETS_PER_REQUEST
        collect_with_count(count) do |count_options|
          select_retweets(user_timeline(user, options.merge(count_options)))
        end
      end
      alias retweeted_by retweeted_by_user

      # Returns the 20 most recent retweets posted by the authenticating user
      #
      # @see https://dev.twitter.com/docs/api/1.1/get/statuses/user_timeline
      # @note This method can only return up to 3,200 Tweets.
      # @rate_limited Yes
      # @authentication_required Requires user context
      # @raise [Twitter::Error::Unauthorized] Error raised when supplied user credentials are not valid.
      # @return [Array<Twitter::Tweet>]
      # @param user [Integer, String, Twitter::User] A Twitter user ID, screen name, or object.
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :exclude_replies This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count tweets - this is because the count parameter retrieves that many tweets before filtering out retweets and replies.
      # @option options [Boolean, String, Integer] :contributor_details Specifies that the contributors element should be enhanced to include the screen_name of the contributor.
      # @example Return the 20 most recent retweets posted by the authenticating user
      #   Twitter.retweeted_by_me
      def retweeted_by_me(options={})
        retweets_from_timeline(options) do |options|
          user_timeline(options)
        end
      end

      # Returns the 20 most recent Tweets, including retweets if they exist, posted by the authenticating user and the users they follow
      #
      # @see https://dev.twitter.com/docs/api/1.1/get/statuses/home_timeline
      # @note This method can only return up to 800 Tweets, including retweets.
      # @rate_limited Yes
      # @authentication_required Requires user context
      # @raise [Twitter::Error::Unauthorized] Error raised when supplied user credentials are not valid.
      # @return [Array<Twitter::Tweet>]
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :exclude_replies This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count tweets - this is because the count parameter retrieves that many tweets before filtering out retweets and replies.
      # @option options [Boolean, String, Integer] :include_rts Specifies that the timeline should include native retweets in addition to regular tweets. Note: If you're using the trim_user parameter in conjunction with include_rts, the retweets will no longer contain a full user object.
      # @option options [Boolean, String, Integer] :contributor_details Specifies that the contributors element should be enhanced to include the screen_name of the contributor.
      # @option options [Boolean, String, Integer] :include_entities The tweet entities node will be disincluded when set to false.
      # @example Return the 20 most recent Tweets, including retweets if they exist, posted by the authenticating user and the users they follow
      #   Twitter.home_timeline
      def home_timeline(options={})
        collection_from_response(Twitter::Tweet, :get, "/1.1/statuses/home_timeline.json", options)
      end

      # Returns the 20 most recent retweets posted by users the authenticating user follow.
      #
      # @see https://dev.twitter.com/docs/api/1.1/get/statuses/home_timeline
      # @note This method can only return up to 800 Tweets, including retweets.
      # @rate_limited Yes
      # @authentication_required Requires user context
      # @raise [Twitter::Error::Unauthorized] Error raised when supplied user credentials are not valid.
      # @return [Array<Twitter::Tweet>]
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :exclude_replies This parameter will prevent replies from appearing in the returned timeline. Using exclude_replies with the count parameter will mean you will receive up-to count tweets - this is because the count parameter retrieves that many tweets before filtering out retweets and replies.
      # @option options [Boolean, String, Integer] :contributor_details Specifies that the contributors element should be enhanced to include the screen_name of the contributor.
      # @option options [Boolean, String, Integer] :include_entities The tweet entities node will be disincluded when set to false.
      # @example Return the 20 most recent retweets posted by users followed by the authenticating user
      #   Twitter.retweeted_to_me
      def retweeted_to_me(options={})
        retweets_from_timeline(options) do |options|
          home_timeline(options)
        end
      end

      # Returns the 20 most recent tweets of the authenticated user that have been retweeted by others
      #
      # @see https://dev.twitter.com/docs/api/1.1/get/statuses/retweets_of_me
      # @rate_limited Yes
      # @authentication_required Requires user context
      # @raise [Twitter::Error::Unauthorized] Error raised when supplied user credentials are not valid.
      # @return [Array<Twitter::Tweet>]
      # @param options [Hash] A customizable set of options.
      # @option options [Integer] :count Specifies the number of records to retrieve. Must be less than or equal to 200.
      # @option options [Integer] :since_id Returns results with an ID greater than (that is, more recent than) the specified ID.
      # @option options [Integer] :max_id Returns results with an ID less than (that is, older than) or equal to the specified ID.
      # @option options [Boolean, String, Integer] :trim_user Each tweet returned in a timeline will include a user object with only the author's numerical ID when set to true, 't' or 1.
      # @option options [Boolean, String, Integer] :include_entities The tweet entities node will be disincluded when set to false.
      # @option options [Boolean, String, Integer] :include_user_entities The user entities node will be disincluded when set to false.
      # @example Return the 20 most recent tweets of the authenticated user that have been retweeted by others
      #   Twitter.retweets_of_me
      def retweets_of_me(options={})
        collection_from_response(Twitter::Tweet, :get, "/1.1/statuses/retweets_of_me.json", options)
      end

    private

      # @param collection [Array]
      # @param max_id [Integer, NilClass]
      # @return [Array]
      def collect_with_max_id(collection=[], max_id=nil, &block)
        tweets = yield(max_id)
        return collection if tweets.nil?
        collection += tweets
        tweets.empty? ? collection.flatten : collect_with_max_id(collection, tweets.last.id - 1, &block)
      end

      # @param count [Integer]
      # @return [Array]
      def collect_with_count(count, &block)
        options = {}
        options[:count] = MAX_TWEETS_PER_REQUEST
        collect_with_max_id do |max_id|
          options[:max_id] = max_id unless max_id.nil?
          if count > 0
            tweets = yield(options)
            count -= tweets.length
            tweets
          end
        end.flatten.compact[0...count]
      end

      def retweets_from_timeline(options)
        options[:include_rts] = true
        count = options[:count] || DEFAULT_TWEETS_PER_REQUEST
        collect_with_count(count) do |count_options|
          select_retweets(yield(options.merge(count_options)))
        end
      end

      # @param tweets [Array]
      # @return [Array]
      def select_retweets(tweets)
        tweets.select(&:retweet?)
      end

    end
  end
end
