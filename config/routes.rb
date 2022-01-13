Rails.application.routes.draw do
  root to: 'view_points#account_dashboard'
  devise_for :users
  ActiveAdmin.routes(self)

  resources :statement_money_lines
  resources :statement_position_nettings
  resources :statement_positions
  resources :statement_deal_leg_fills
  resources :statement_charges
  resources :statement_adjustments
  resources :accounts
  resources :claim_sets
  resources :claims

  get 'view_point/seasonal_spreads' => 'view_points#seasonal_spreads', as: :seasonal_spreads
  get 'view_point/seasonal_spreads_data' => 'view_points#seasonal_spreads_data', as: :seasonal_spreads_data

  get 'view_point/seasonal_spread_sets' => 'view_points#seasonal_spread_sets', as: :seasonal_spread_sets
  get 'view_point/seasonal_spread_sets_data' => 'view_points#seasonal_spread_sets_data', as: :seasonal_spread_sets_data

  get 'view_point/firm_dashboard' => 'view_points#firm_dashboard', as: :firm_dashboard
  get 'view_point/account_dashboard' => 'view_points#account_dashboard', as: :account_dashboard

  get 'view_point/who_what_when' => 'view_points#who_what_when', as: :who_what_when
  post 'view_point/who_what_when_range'  => 'view_points#who_what_when_range',  as: :who_what_when_post
  post 'view_point/firm_what_when_range' => 'view_points#firm_what_when_range', as: :firm_what_when_post
  match 'view_point/firm_what_when' => 'view_points#firm_what_when', as: :firm_what_when, via: [:get, :post]

  #
  get 'view_point/firm_positions_by_claim' => 'view_points#firm_positions_by_claim'
  get 'view_point/firm_statement_positions_by_claim_on' => 'view_points#firm_statement_positions_by_claim_on'
  get 'view_point/firm_statement_money_lines_since' => 'view_points#firm_statement_money_lines_since'

  get 'view_point/positions_by_claim' => 'view_points#positions_by_claim'
  get 'view_point/statement_positions_by_claim_on' => 'view_points#statement_positions_by_claim_on'
  get 'view_point/statement_money_lines_since' => 'view_points#statement_money_lines_since'

  get 'view_point/income_to_expense_ratio_by_claim_set' => 'view_points#income_to_expense_ratio_by_claim_set'
  get 'view_point/income_to_expense_ratio_by_claim_set_for_firm' => 'view_points#income_to_expense_ratio_by_claim_set_for_firm'

  get 'view_point/positions' => 'view_points#positions'

  get 'view_point/statement_money_lines_ytd' => 'view_points#statement_money_lines_ytd', as: :statement_money_lines_ytd

  get 'view_point/positions_by_claim_set' => 'view_points#positions_by_claim_set'
end
