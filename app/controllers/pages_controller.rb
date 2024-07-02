class PagesController < ApplicationController
  layout "with_sidebar"

  include Filterable

  def dashboard
    snapshot = Current.family.snapshot(@period)
    @net_worth_series = snapshot[:net_worth_series]
    @asset_series = snapshot[:asset_series]
    @liability_series = snapshot[:liability_series]

    snapshot_transactions = Current.family.snapshot_transactions
    @income_series = snapshot_transactions[:income_series]
    @spending_series = snapshot_transactions[:spending_series]
    @savings_rate_series = snapshot_transactions[:savings_rate_series]

    snapshot_account_transactions = Current.family.snapshot_account_transactions
    @top_spenders = snapshot_account_transactions[:top_spenders]
    @top_earners = snapshot_account_transactions[:top_earners]
    @top_savers = snapshot_account_transactions[:top_savers]

    @accounts = Current.family.accounts
    @account_groups = @accounts.by_group(period: @period, currency: Current.family.currency)
    @transaction_entries = Current.family.entries.account_transactions.limit(6).reverse_chronological

    # TODO: Placeholders for trendlines
    placeholder_series_data = 10.times.map do |i|
      { date: Date.current - i.days, value: Money.new(0) }
    end
    @investing_series = TimeSeries.new(placeholder_series_data)
  end

  def changelog
    @releases_notes = Provider::Github.new.fetch_latest_releases_notes
  end

  def feedback
  end

  def invites
  end
end
