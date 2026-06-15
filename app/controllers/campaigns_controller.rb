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
    @campaign.recipients.build
  end

  def create
    @campaign = Campaign.new(campaign_params)

    if @campaign.save
      DispatchCampaignJob.perform_later(@campaign.id)

      redirect_to @campaign, notice: "Campaign created and dispatching..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def campaign_params
    params.require(:campaign).permit(:title, recipients_attributes: %i[id name email _destroy])
  end
end
