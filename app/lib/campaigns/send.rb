# frozen_string_literal: true

class Campaigns::Send
  def self.call(campaign)
    new(campaign).call
  end

  def initialize(campaign)
    @campaign = campaign
  end

  def call
    return if campaign.delivered_at.present?

    Membership.current.each do |membership|
      delivery = delivery_for membership
      next if delivery.delivered_at.present?

      CampaignsMailer.campaign_email(campaign, membership).deliver_now

      delivery.delivered_at = Time.current
      delivery.save!
    end

    campaign.update delivered_at: Time.current
  end

  private

  attr_reader :campaign

  def delivery_for(membership)
    CampaignDelivery.find_or_initialize_by(
      campaign: campaign,
      membership: membership
    )
  end
end
