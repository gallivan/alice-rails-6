class StudiesController < ApplicationController

  def gross_by_tradeable_set
    @data = params[:format] ? Study.gross_by_tradeable_set : []

    respond_to do |format|
      format.html
      format.xml { render :xml => @data }
      format.json { render :json => @data }
    end
  end

  def matches
    @data = params[:format] ? Study.matches : []

    respond_to do |format|
      format.html
      format.xml { render :xml => @data }
      format.json { render :json => @data }
    end
  end

  def offset_flows
    @account_code = params[:account_code].blank? ? Account.first.code : params[:account_code]
    @tradeable_code = params[:tradeable_code].blank? ? 'EDH4' : params[:tradeable_code]
    @tradeable_set_code = params[:tradeable_set_code].blank? ? 'ED' : params[:tradeable_set_code]
    @posting_date = params[:posting_date].blank? ? Posting.maximum(:posting_date) : Date.parse(params[:posting_date])

    @offset_flows = Study.offset_flows(@account_code, @tradeable_code, @tradeable_set_code, @posting_date)
    respond_to do |format|
      format.html
      format.xml { render :xml => @offset_flows }
      format.json { render :json => @offset_flows }
    end
  end

  def offset_flows_by_hour
    @account_code = params[:account_code].blank? ? Account.first.code : params[:account_code]
    @tradeable_code = params[:tradeable_code].blank? ? 'EDH4' : params[:tradeable_code]
    @tradeable_set_code = params[:tradeable_set_code].blank? ? 'ED' : params[:tradeable_set_code]
    @posting_date = params[:posting_date].blank? ? Posting.maximum(:posting_date) : Date.parse(params[:posting_date])

    @offset_flows = OffsetFlow.by_hour(@account_code, @tradeable_code, @tradeable_set_code, @posting_date)
    respond_to do |format|
      format.html
      format.xml { render :xml => @offset_flows }
      format.json { render :json => @offset_flows }
    end
  end

end

