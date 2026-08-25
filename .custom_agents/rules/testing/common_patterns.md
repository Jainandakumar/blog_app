---
paths:
  - "spec/**"
last_reviewed: 2026-05-19
---

# Common testing patterns

Copy-paste-ready templates for the test scenarios that come up most often. Adapt to fit your case — these show the shape, not the exact data.

## Testing Validations

```ruby
RSpec.describe User do
  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_length_of(:name).is_at_most(100) }
  end
end
```

## Testing Associations

```ruby
RSpec.describe User do
  describe "associations" do
    it { should have_many(:enrollments) }
    it { should belong_to(:organization) }
  end
end
```

## Testing Scopes

```ruby
RSpec.describe User do
  describe ".active" do
    let!(:active_user)   { create(:user, status: "active") }
    let!(:inactive_user) { create(:user, status: "inactive") }

    it "returns only active users" do
      expect(User.active).to include(active_user)
      expect(User.active).not_to include(inactive_user)
    end
  end
end
```

## Testing Callbacks

```ruby
RSpec.describe User do
  describe "after_create callback" do
    it "sends a welcome email" do
      expect(UserMailer).to receive(:welcome).and_call_original

      create(:user)
    end
  end
end
```

## Testing Service Objects

```ruby
RSpec.describe EnrollmentService do
  describe "#call" do
    let(:subscriber) { create(:subscriber) }
    let(:plan)       { create(:benefit_plan) }
    let(:service)    { EnrollmentService.new(subscriber, plan) }

    context "when enrollment is successful" do
      it "creates an enrollment" do
        expect { service.call }.to change(Enrollment, :count).by(1)
      end

      it "returns success" do
        result = service.call
        expect(result[:success]).to be true
      end
    end

    context "when subscriber is invalid" do
      let(:subscriber) { build(:subscriber, first_name: nil) }

      it "does not create an enrollment" do
        expect { service.call }.not_to change(Enrollment, :count)
      end

      it "returns failure with error message" do
        result = service.call
        expect(result[:success]).to be false
        expect(result[:error]).to be_present
      end
    end
  end
end
```

## Testing API Endpoints

```ruby
RSpec.describe "Users API" do
  describe "POST /api/v1/users" do
    let(:valid_params) do
      {
        user: {
          first_name: "John",
          last_name: "Doe",
          email: "john@example.com"
        }
      }
    end

    context "with valid parameters" do
      it "creates a new user" do
        expect {
          post "/api/v1/users", params: valid_params
        }.to change(User, :count).by(1)
      end

      it "returns 201 created" do
        post "/api/v1/users", params: valid_params
        expect(response).to have_http_status(:created)
      end

      it "returns the created user" do
        post "/api/v1/users", params: valid_params
        expect(json_response[:email]).to eq("john@example.com")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { user: { email: "invalid" } } }

      it "does not create a user" do
        expect {
          post "/api/v1/users", params: invalid_params
        }.not_to change(User, :count)
      end

      it "returns 422 unprocessable entity" do
        post "/api/v1/users", params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns validation errors" do
        post "/api/v1/users", params: invalid_params
        expect(json_response[:errors]).to be_present
      end
    end
  end
end
```

## Testing Background Jobs

```ruby
RSpec.describe WelcomeEmailJob do
  describe "#perform" do
    let(:user) { create(:user) }

    it "sends the welcome email" do
      expect(UserMailer).to receive(:welcome).with(user).and_call_original

      WelcomeEmailJob.perform_now(user.id)
    end

    it "enqueues the job" do
      expect {
        WelcomeEmailJob.perform_later(user.id)
      }.to have_enqueued_job(WelcomeEmailJob).with(user.id)
    end
  end
end
```

## Related

- [`test_types.md`](test_types.md) — Picking the right kind of spec (unit/request/feature) for the scenario above.
- [`structure.md`](structure.md) — `describe`/`context`/`it` style that applies to every pattern here.
- [`factories.md`](factories.md) — The `create(:user)` and `create(:subscriber)` calls used in these examples.
- [`test_objects.md`](test_objects.md) — When `expect(...).to receive` is OK vs. when to use a factory.
