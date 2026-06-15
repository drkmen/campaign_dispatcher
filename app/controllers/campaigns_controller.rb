class CampaignsController < ApplicationController
  def index
    @campaigns = Campaign.order(created_at: :desc)
  end

  def show
    @campaign = Campaign.find(params[:id])
    @recipients = @campaign.recipients.order(:id)
  end

  def new
    @campaign = Campaign.new
  end

  def create
    @campaign = Campaign.new(campaign_params)
    
    if @campaign.save
      parse_recipients
      DispatchCampaignJob.perform_later(@campaign.id)

      redirect_to @campaign, notice: "Campaign created and dispatching..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def campaign_params
    params.require(:campaign).permit(:title)
  end

  def parse_recipients
    recipients_data = params[:recipients_data]
    return if recipients_data.blank?

    recipients_data.each_line do |line|
      name, email = line.split(",").map(&:strip)
      next if name.blank? || email.blank?

      @campaign.recipients.create(name: name, email: email)
    end
  end
end
