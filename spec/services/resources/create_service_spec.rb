require 'rails_helper'

RSpec.describe Resources::CreateService, type: :service do
  let(:account) { Account.create!(name: 'Acme') }
  let(:user) { User.create!(email: 'user@example.com', password: 'password', account: account) }

  before { ActsAsTenant.current_tenant = account }
  after { ActsAsTenant.current_tenant = nil }

  it 'creates record with valid attributes' do
    record = Profile.new(account: account, user: user, first_name: 'Ada', last_name: 'Lovelace', bio: 'Pioneer')

    result = described_class.call(record: record)

    expect(result).to be_success
    expect(result.value).to be_persisted
  end

  it 'returns failure with validation errors' do
    record = Profile.new(account: account, user: user, first_name: '', last_name: 'Valid')

    result = described_class.call(record: record)

    expect(result).to be_failure
    expect(result.error).to include("First name can't be blank")
  end
end

