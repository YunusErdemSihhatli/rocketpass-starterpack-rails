require 'rails_helper'

RSpec.describe Resources::DestroyService, type: :service do
  let(:account) { Account.create!(name: 'Acme') }
  let(:user) { User.create!(email: 'user3@example.com', password: 'password', account: account) }

  before { ActsAsTenant.current_tenant = account }
  after { ActsAsTenant.current_tenant = nil }

  it 'destroys the record' do
    profile = Profile.create!(account: account, user: user, first_name: 'Alan', last_name: 'Turing', bio: 'AI')

    expect {
      described_class.call(record: profile)
    }.to change { Profile.count }.by(-1)
  end
end

