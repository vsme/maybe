require "test_helper"

class Account::TransfersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:family_admin)
  end

  test "should get new" do
    get new_account_transfer_url
    assert_response :success
  end

  test "can create transfers" do
    assert_difference "Account::Transfer.count", 1 do
      post account_transfers_url, params: {
        account_transfer: {
          from_account_id: accounts(:checking).id,
          to_account_id: accounts(:savings).id,
          date: Date.current,
          amount: 100,
          currency: "USD",
          name: "Test Transfer"
        }
      }
      assert_enqueued_with job: AccountSyncJob
    end
  end

  test "can destroy transfer" do
    assert_difference -> { Account::Transfer.count } => -1, -> { Account::Transaction.count } => 0 do
      delete account_transfer_url(account_transfers(:credit_card_payment))
    end
  end
end
