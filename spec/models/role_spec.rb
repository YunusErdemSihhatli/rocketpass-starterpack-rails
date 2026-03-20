require "rails_helper"

RSpec.describe Role, type: :model do
  around do |example|
    previous_tenant = ActsAsTenant.current_tenant
    ActsAsTenant.current_tenant = nil
    example.run
    ActsAsTenant.current_tenant = previous_tenant
  end

  it "allows a global superadmin role without an account" do
    role = described_class.new(name: "superadmin", account: nil)

    expect(role).to be_valid
  end
end
