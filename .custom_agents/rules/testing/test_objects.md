---
paths:
  - "spec/**"
last_reviewed: 2026-05-19
---

# Test object preference hierarchy

When setting up test data, use real objects whenever possible. The strict preference order is **factories/real > doubles > mocks/stubs**.

This codebase follows **Detroit School (classicist) TDD** — not London School (mockist). We use real collaborators and test outcomes, not message passing.

## 1. Factories (Strongly Preferred) or Real Objects

Use `FactoryBot.create` / `FactoryBot.build` for all objects that exist in our application. This ensures tests exercise real application behavior including actual dependencies. Application classes that do not have existing factories should have those factories added (see [`factories.md`](factories.md)).

When a factory is not available, instantiating a real instance of an object is a valid alternative.

```ruby
# GOOD — tests real behavior, catches interface changes
let(:organization) { create(:organization) }
let(:subscriber)   { create(:subscriber, organization: organization) }
let(:qr_code)      { RQRCodeCore::QRCode.new(url) }
```

## 2. Test Doubles (Only When a Factory Is Not Possible)

Use `instance_double` / `double` only when the interaction with the object is not part of the functionality being tested (in Detroit School [classicist] terms: it is not a functional collaborator, is outside a system boundary, or is not part of the "promise" of the code).

```ruby
# ACCEPTABLE — no factory exists for an external client object
let(:system_logger) { instance_double(TestLogger, post: response) }
```

## 3. Mocks/Stubs (Only When a Real Object Is Unavailable)

Use `allow` / `expect(...).to receive` only when the real operation genuinely cannot run in the test environment — such as external HTTP calls, payment gateways, or third-party APIs where real connections are unavailable.

```ruby
# ACCEPTABLE — real HTTP to external service is not available in test env
allow(PaymentGateway).to receive(:charge).and_return(true)

# ACCEPTABLE — we don't send real emails in tests
allow(UserMailer).to receive(:deliver_later)
```

## Why This Matters

Real collaborators catch interface drift, real validation behavior, and integration issues that mocks paper over. Heavy mocking decouples tests from the code so completely that the test suite can stay green while the code breaks.

**Code Review:** Unnecessary use of test doubles or mocks when a factory could be used is a **Warning**.

## RSpec Mocking Syntax Reference

```ruby
# Stub a method
allow(object).to receive(:method).and_return(value)

# Stub with arguments
allow(object).to receive(:method).with(arg1, arg2).and_return(value)

# Expect a method to be called
expect(object).to receive(:method).with(args)

# Stub chain
allow(User).to receive_message_chain(:active, :where).and_return([user])

# Create a double
payment_gateway = double("PaymentGateway", charge: true)
```

## Related

- [`factories.md`](factories.md) — Authoring the factories this rule prefers.
- [`philosophy.md`](philosophy.md) — Why we test behavior (outcomes) over implementation (messages).
- [`common_patterns.md`](common_patterns.md) — Service-object and API-endpoint patterns showing factories in use.
