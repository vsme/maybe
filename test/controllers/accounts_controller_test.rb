require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in @user = users(:family_admin)
    @account = accounts(:checking)
  end

  test "gets accounts list" do
    get accounts_url
    assert_response :success

    @user.family.accounts.each do |account|
      assert_dom "#" + dom_id(account), count: 1
    end
  end

  test "new" do
    get new_account_path
    assert_response :ok
  end

  test "show" do
    get account_path(@account)
    assert_response :ok
  end

  test "can sync an account" do
    post sync_account_path(@account)
    assert_redirected_to account_url(@account)
  end

  test "should update account" do
    patch account_url(@account), params: {
      account: {
        name: "Updated name",
        is_active: "0",
        institution_id: institutions(:chase).id
      }
    }

    assert_redirected_to account_url(@account)
    assert_equal "Account updated", flash[:notice]
  end

  test "should create an account" do
    assert_difference [ "Account.count", "Account::Valuation.count", "Account::Entry.count" ], 1 do
      post accounts_path, params: {
        account: {
          accountable_type: "Depository",
          balance: 200,
          subtype: "checking",
          institution_id: institutions(:chase).id
        }
      }

      assert_equal "New account created successfully", flash[:notice]
      assert_redirected_to account_url(Account.order(:created_at).last)
    end
  end

  test "can add optional start date and balance to an account on create" do
    assert_difference -> { Account.count } => 1, -> { Account::Valuation.count } => 2 do
      post accounts_path, params: {
        account: {
          accountable_type: "Depository",
          balance: 200,
          subtype: "checking",
          institution_id: institutions(:chase).id,
          start_balance: 100,
          start_date: 10.days.ago
        }
      }

      assert_equal "New account created successfully", flash[:notice]
      assert_redirected_to account_url(Account.order(:created_at).last)
    end
  end
end
