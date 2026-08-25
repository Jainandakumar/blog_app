---
paths:
  - "**/*.rb"
last_reviewed: 2026-05-19
---

# SOLID Principles

Follow SOLID principles as defined by Robert C. Martin (Uncle Bob). These are foundational to object-oriented design.

**References:**
- [Single Responsibility Principle - Wikipedia](https://en.wikipedia.org/wiki/Single-responsibility_principle)
- [SOLID Principles - Wikipedia](https://en.wikipedia.org/wiki/SOLID)
- **Practical Object-Oriented Design in Ruby (POODR)** by Sandi Metz
- [Free POODR Summary](https://github.com/serodriguez68/poodr-notes) (community notes)
- [DDD Reference](https://www.domainlanguage.com/ddd/reference/) (free from Eric Evans)

---

## CRITICAL: Single Responsibility Principle Misconception

**THE MOST COMMON MISUNDERSTANDING:**

WRONG: "Single Responsibility means the class does ONE THING"

CORRECT: "Single Responsibility means the class has ONE REASON TO CHANGE (one actor/stakeholder)"

**This misconception leads to:**
- Fragmented, overly complex code
- Redundant/repeating code
- Classes that are artificially small but coupled together
- Poor encapsulation

**Example of the misconception:**

```ruby
# WRONG interpretation: "Each class does one thing"
class EnrollmentEligibilityChecker
  def check(subscriber, plan)
    # Only checks eligibility - "single responsibility"
  end
end

class EnrollmentCreator
  def create(subscriber, plan)
    # Only creates enrollment - "single responsibility"
  end
end

class EnrollmentNotifier
  def notify(enrollment)
    # Only notifies - "single responsibility"
  end
end

# This is FRAGMENTED code, not good SRP!
# These classes are artificially split and likely change together.
```

**If you find yourself thinking "this class should only do one thing," STOP and re-read the SRP definition below.**

---

## Single Responsibility Principle - The Actual Definition

**From Wikipedia (https://en.wikipedia.org/wiki/Single-responsibility_principle):**

> "The single-responsibility principle (SRP) is a computer programming principle that states that 'A module should be responsible to one, and only one, actor.'"
>
> **Definition:** A class should have only one reason to change, meaning it should have only one job or responsibility that can be changed by one actor (a person or group of people who require the change).

**Wikipedia Example (reproduced verbatim):**

```java
// Violation of SRP - This class has multiple reasons to change
class Employee {
    public Money calculatePay() {
        // Reason to change #1: CFO's office (pay calculation policy)
    }

    public String reportHours() {
        // Reason to change #2: COO's office (hour reporting format)
    }

    public void save() {
        // Reason to change #3: CTO's office (database schema)
    }
}

// Corrected - Each class has one reason to change (one actor)
class PayCalculator {
    public Money calculatePay(Employee e) {
        // Only CFO's office requests changes to this
    }
}

class HourReporter {
    public String reportHours(Employee e) {
        // Only COO's office requests changes to this
    }
}

class EmployeeRepository {
    public void save(Employee e) {
        // Only CTO's office requests changes to this
    }
}
```

**The key insight:** SRP is about **WHO** owns the logic (which stakeholder), not **WHAT** the code does.

**A class can do MANY things** and still follow SRP, as long as all those things serve the same actor/stakeholder and would change together when that actor's needs change.

---

## Other SOLID Principles

**We will not attempt to summarize these.** Consult the references above if you need clarification.

- **Open/Closed Principle:** Open for extension, closed for modification
- **Liskov Substitution Principle:** Subtypes must be substitutable for their base types
- **Interface Segregation Principle:** Clients shouldn't depend on interfaces they don't use
- **Dependency Inversion Principle:** Depend on abstractions, not concretions

**If you don't understand these principles deeply, consult POODR or the Wikipedia articles. Don't guess.**

---

## Related

- [principles.md](principles.md) — the three core principles SOLID builds on.
- [anti_patterns.md](anti_patterns.md) — patterns that violate SOLID (utility classes, repository pattern).
- [refactoring.md](refactoring.md) — applying SOLID when refactoring.
