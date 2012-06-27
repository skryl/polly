require 'polly'

class ApprovalCalcVersion1 < Polly::Calculation
  version 1

  # constants
  const :pmt_to_income_cap, 14.percent
  const :max_pmt, 2000
  const :l2v_cap, 70.percent
  const :max_loan_size, 5000
  const :apr, 150
  const :max_duration, 12

  # inputs
  var :pay_per_check
  var :freq_per_month
  var :kbb_auction_good
  # input :value_adjustment
  # input :repair_costs

  # eq can nest other equations or vars
  eq :monthly_income, pay_per_check * freq_per_month
  eq :max_monthly_pmt, monthly_income * pmt_to_income_cap
  eq :credit_cap,  ceil(npv(apr, max_duration, max_monthly_pmt), 50)
  eq :net_asset_value, kbb_auction_good
  eq :asset_cap, net_asset_value * l2v_cap

  eq :approval_amount, min(credit_cap, asset_cap)
end

# Usage

a = ApprovalCalcVersion1.new(loan_app, :persist => true)
simple = a.simplify
amount = a.result


# Initializer

Polly.persist_equation_results = true
Polly.persistance_class(Calculation)
