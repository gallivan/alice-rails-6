class PositionTransfersController < InheritedResources::Base

  # GET /position_transfer/new
  def new
    puts params
    @position_transfer = PositionTransfer.new
    @position_transfer.fm_position = Position.find(params[:fm_position_id]) if params[:fm_position_id]
  end
  
  # POST /position_transfers
  # POST /position_transfers.json
  def create

    #
    # TODO needs something more idiomatic
    #

    fm_position = Position.find(params[:position_transfer][:fm_position_id])
    to_account = Account.find(params[:position_transfer][:to_account_id])
    bot_transfered = params[:position_transfer][:bot_transfered].to_i
    sld_transfered = params[:position_transfer][:sld_transfered].to_i

    @position_transfer = Builders::PositionTransferBuilder.build(current_user, fm_position, to_account, bot_transfered, sld_transfered, 'by controller')

    respond_to do |format|
      if @position_transfer.save
        format.html { redirect_to post_url(@position_transfer), notice: 'Position transfer was successfully created.' }
        format.json { render :show, status: :created, location: @position_transfer }
      else
        format.html { render :new }
        format.json { render json: @position_transfer.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def position_transfer_params
      params.require(:position_transfer).permit(:fm_position, :to_account_id, :bot_transfered, :sld_transfered)
    end
end

