require 'rails_helper'

RSpec.describe Resources::UpdateService, type: :service do
  let(:account) { Account.create!(name: 'Acme') }
  let(:user) { User.create!(email: 'user2@example.com', password: 'password', account: account) }
  let(:profile) { Profile.create!(account: account, user: user, first_name: 'Grace', last_name: 'Hopper', bio: 'COBOL') }

  before { ActsAsTenant.current_tenant = account }
  after { ActsAsTenant.current_tenant = nil }

  it 'updates record with valid attributes' do
    result = described_class.call(record: profile, attributes: { last_name: 'Updated' })

    expect(result).to be_success
    expect(result.value.last_name).to eq('Updated')
  end

  it 'returns failure on invalid update' do
    result = described_class.call(record: profile, attributes: { last_name: '' })

    expect(result).to be_failure
    expect(result.error).to include("Last name can't be blank")
  end
end

