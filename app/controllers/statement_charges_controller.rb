class StatementChargesController < InheritedResources::Base
  before_action :trap_request, only: [:edit, :update, :destroy]

  def index
    if params[:q].blank? and current_user.accounts.count > 0
      params[:q] = {}
      params[:q][:account_id_eq] = current_user.accounts.order(:code).first.id
    end
    @q = StatementCharge.order("id desc").ransack(params[:q])
    @statement_charges = @q.result.page(params[:page]).per(20)
  end

  private

  def statement_charge_params
    params.require(:statement_charge).permit(:posted_on, :stated_on, :account_id, :account_code, :charge_code, :journal_code, :currency_code, :amount, :memo)
  end

  def trap_request
    flash[:danger] = "Changes are not allowed"
    redirect_to statement_charges_path
  end

end

