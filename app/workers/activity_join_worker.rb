class ActivityJoinWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(activity_id, user_id, account_id, message, join_result)
    user = User.find(user_id)
    message = remarshal_message message
    account = PublicAccount.fetch(account_id)
    api = WechatService.instance.account_api account
    activity = Activity.fetch(activity_id)

    activity = "Activity#{activity_id}".constantize.new(
        activity,
        user, api, account, message, join_result
    )
    activity.start
  end

  private
  def remarshal_message(message_string)
    Wechat::Message.from_hash(Hash.from_xml(message_string)['xml'].symbolize_keys)
  end
end